package controller.User;

import dao.CartItemDAO;
import dao.CustomerDAO;
import dao.InventoryItemDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.CartItem;
import model.CartItemDisplay;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "cartServlet", urlPatterns = {"/cartservlet"})
// Giỏ hàng khách: truy vấn hiển thị danh sách và số hàng còn kho theo từng biến thể.
// Gửi bằng phương thức thêm, đổi số lượng, xóa; trình duyệt có thể gọi dạng không tải lại trang để nhận dữ liệu dạng chữ cho máy đọc.
public class cartServlet extends HttpServlet {

    private void redirectToCart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/cartservlet");
    }

    /** Chuyển sang đăng nhập, có thể kèm tham số để sau đăng nhập quay lại giỏ. */
    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response, String from) throws IOException {
        String url = request.getContextPath() + "/userservlet?action=loginPage";
        if (from != null && !from.isBlank()) {
            url += "&from=" + from;
        }
        response.sendRedirect(url);
    }

    /** Thông báo tạm trên phiên làm việc. */
    private void setMsg(HttpServletRequest request, String msg, String type) {
        request.getSession().setAttribute("msg", msg);
        request.getSession().setAttribute("msgType", type);
    }

    /** Đọc số nguyên an toàn. */
    private int parseIntSafe(String s, int defaultValue) {
        if (s == null) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /** Xem có phải yêu cầu từ script trên trang (cần trả lời dạng chữ máy đọc). */
    private boolean isAjax(HttpServletRequest request) {
        return "XMLHttpRequest".equals(request.getHeader("X-Requested-With"))
                || "1".equals(request.getParameter("ajax"));
    }

    /** Mã khách trong phiên; không có thì đọc cookie đăng nhập khách (cùng cách các trang người dùng khác). */
    private int getCustomerId(HttpServletRequest request) {
        Object sid = request.getSession(false) != null ? request.getSession().getAttribute("customerId") : null;
        if (sid instanceof Integer) {
            return (Integer) sid;
        }
        if (sid != null) {
            try {
                return Integer.parseInt(sid.toString());
            } catch (NumberFormatException ignored) {
            }
        }
        int fromCookie = getCustomerIdFromCookie(request);
        if (fromCookie > 0) {
            request.getSession(true).setAttribute("customerId", fromCookie);
        }
        return fromCookie;
    }

    /** Đọc mã khách và vai trò từ cookie trình duyệt. */
    private int getCustomerIdFromCookie(HttpServletRequest request) {
        jakarta.servlet.http.Cookie[] cookies = request.getCookies();
        if (cookies == null) {
            return -1;
        }
        boolean isCustomer = false;
        String idVal = null;
        for (jakarta.servlet.http.Cookie c : cookies) {
            if ("cookieID".equals(c.getName())) {
                idVal = c.getValue();
            }
            if ("cookieRole".equals(c.getName()) && "customer".equals(c.getValue())) {
                isCustomer = true;
            }
        }
        if (!isCustomer || idVal == null || idVal.isEmpty()) {
            return -1;
        }
        try {
            return Integer.parseInt(idVal);
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    /**
     * Chỉ trả về mã khách thật sự còn trong hệ thống; phiên hoặc cookie lỗi thời thì xóa và trả về âm một.
     */
    private int getValidCustomerId(HttpServletRequest request) {
        int customerId = getCustomerId(request);
        if (customerId <= 0) {
            return -1;
        }
        if (new CustomerDAO().getCustomerById(customerId) == null) {
            request.getSession().removeAttribute("customerId");
            return -1;
        }
        return customerId;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        int customerId = getValidCustomerId(request);
        List<CartItemDisplay> listCart = new java.util.ArrayList<>();
        // Số chiếc còn trong kho theo từng biến thể — trang giỏ dùng để không cho tăng quá tồn (cả trên máy khách và máy chủ).
        Map<Integer, Integer> variantStockMap = new HashMap<>();
        if (customerId > 0) {
            CartItemDAO cartDao = new CartItemDAO();
            listCart = cartDao.getCartDisplayByCustomerId(customerId);
            InventoryItemDAO invDao = new InventoryItemDAO();
            for (CartItemDisplay item : listCart) {
                variantStockMap.put(item.getVariantId(), invDao.countAvailableByVariantId(item.getVariantId()));
            }
        }
        int cartCount = listCart.size();

        // Một số trang chỉ cần biết có bao nhiêu dòng trong giỏ để hiển thị số trên menu.
        if ("count".equals(request.getParameter("action"))) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().print("{\"cartCount\":" + cartCount + "}");
            return;
        }

        String headerComponent = "/components/navbar.jsp";
        String footerComponent = "/components/footer.jsp";
        String page = "/pages/MainPage/cartPage.jsp";

        request.setAttribute("cartCount", cartCount);
        request.getSession().setAttribute("cartCount", cartCount);

        request.setAttribute("listCart", listCart);
        request.setAttribute("variantStockMap", variantStockMap);
        request.setAttribute("HeaderComponent", headerComponent);
        request.setAttribute("FooterComponent", footerComponent);
        request.setAttribute("ContentPage", page);
        request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        boolean ajax = isAjax(request);

        if (action == null || action.isBlank()) {
            redirectToCart(request, response);
            return;
        }

        switch (action) {
            // Thêm vào giỏ: gộp số lượng nếu đã có cùng biến thể; không vượt tồn kho.
            case "add": {
                int customerId = getValidCustomerId(request);
                if (customerId <= 0) {
                    if (ajax) {
                        sendJson(response, false, 0, 0, "Please log in to add items to your cart.");
                    } else {
                        redirectToLogin(request, response, "cart");
                    }
                    return;
                }

                int variantId = parseIntSafe(request.getParameter("variant_id"), 0);
                int quantity = parseIntSafe(request.getParameter("quantity"), 1);
                if (quantity < 1) {
                    quantity = 1;
                }
                if (variantId <= 0) {
                    if (ajax) {
                        sendJson(response, false, 0, 0, "Invalid product data.");
                    } else {
                        redirectToCart(request, response);
                    }
                    return;
                }

                CartItemDAO cartDao = new CartItemDAO();
                CartItem existing = cartDao.getByCustomerAndVariant(customerId, variantId);
                int available = new InventoryItemDAO().countAvailableByVariantId(variantId);
                if (available <= 0) {
                    String msg = "This product is out of stock. Please choose another.";
                    if (ajax) {
                        sendJson(response, false, 0, 0, msg);
                    } else {
                        setMsg(request, msg, "danger");
                        redirectToCart(request, response);
                    }
                    return;
                }

                int currentQty = (existing != null) ? existing.getQuantity() : 0;
                int targetQty = currentQty + quantity;
                if (targetQty > available) {
                    targetQty = available;
                }

                boolean saved;
                if (existing != null) {
                    existing.setQuantity(targetQty);
                    saved = cartDao.updateCartItem(existing);
                } else {
                    saved = cartDao.insertCartItem(new CartItem(0, customerId, variantId, targetQty, null));
                }

                if (!saved) {
                    String msg = "Could not add item to cart. Please try again.";
                    if (ajax) {
                        sendJson(response, false, 0, 0, msg);
                    } else {
                        setMsg(request, msg, "danger");
                        redirectToCart(request, response);
                    }
                    return;
                }

                // Trả lời dạng chữ máy đọc: tổng tiền và số dòng để giao diện cập nhật không tải lại trang.
                List<CartItemDisplay> list = cartDao.getCartDisplayByCustomerId(customerId);
                int cartCount = (list != null) ? list.size() : 0;
                long totalAmount = 0;
                if (list != null) {
                    for (CartItemDisplay d : list) {
                        totalAmount += d.getSubtotal();
                    }
                }
                request.getSession().setAttribute("cartCount", cartCount);

                boolean clippedToStock = (currentQty + quantity) > available;
                String addMsg = clippedToStock
                        ? "Added to cart with maximum available quantity (" + targetQty + " item(s))."
                        : "Added to cart.";

                if (ajax) {
                    sendJson(response, true, totalAmount, cartCount, addMsg);
                } else {
                    setMsg(request, addMsg, clippedToStock ? "danger" : "success");
                    redirectToCart(request, response);
                }
                return;
            }
            // Đổi số lượng một dòng; kiểm tra tồn kho và đúng chủ giỏ.
            case "update": {
                int customerId = getValidCustomerId(request);
                if (customerId <= 0) {
                    if (ajax) {
                        sendJson(response, false, 0, 0, "Please log in again to update your cart.");
                    } else {
                        redirectToCart(request, response);
                    }
                    return;
                }

                CartItemDAO cartDao = new CartItemDAO();
                int cartItemId = parseIntSafe(request.getParameter("cart_item_id"), 0);
                int quantity = parseIntSafe(request.getParameter("quantity"), 0);

                if (cartItemId > 0 && quantity >= 1) {
                    CartItem item = cartDao.getCartItemById(cartItemId);
                    if (item != null && item.getCustomer_id() == customerId) {
                        int available = new InventoryItemDAO().countAvailableByVariantId(item.getVariant_id());
                        if (ajax) {
                            if (available <= 0 || quantity > available) {
                                sendJson(response, false, 0, 0, "Not enough stock for this product.");
                                return;
                            }
                            item.setQuantity(quantity);
                            if (!cartDao.updateCartItem(item)) {
                                sendJson(response, false, 0, 0, "Could not update cart. Please try again.");
                                return;
                            }
                        } else {
                            if (available <= 0) {
                                cartDao.deleteCartItem(cartItemId);
                                setMsg(request, "Item is out of stock and has been removed from your cart.", "danger");
                            } else {
                                item.setQuantity(Math.min(quantity, available));
                                if (quantity > available) {
                                    setMsg(request, "Quantity adjusted to available stock (" + available + ").", "danger");
                                }
                                if (!cartDao.updateCartItem(item)) {
                                    setMsg(request, "Could not update cart. Please try again.", "danger");
                                }
                            }
                        }
                    }
                }

                if (ajax) {
                    List<CartItemDisplay> list = cartDao.getCartDisplayByCustomerId(customerId);
                    int cartCount = (list != null) ? list.size() : 0;
                    long totalAmount = 0;
                    if (list != null) {
                        for (CartItemDisplay d : list) {
                            totalAmount += d.getSubtotal();
                        }
                    }
                    request.getSession().setAttribute("cartCount", cartCount);
                    sendJson(response, true, totalAmount, cartCount, null);
                } else {
                    redirectToCart(request, response);
                }
                return;
            }
            // Xóa một dòng giỏ khi đúng chủ.
            case "remove": {
                int customerId = getValidCustomerId(request);
                if (customerId <= 0) {
                    redirectToCart(request, response);
                    return;
                }

                int cartItemId = parseIntSafe(request.getParameter("cart_item_id"), 0);
                if (cartItemId > 0) {
                    CartItemDAO cartDao = new CartItemDAO();
                    CartItem item = cartDao.getCartItemById(cartItemId);
                    if (item != null && item.getCustomer_id() == customerId) {
                        cartDao.deleteCartItem(cartItemId);
                    }
                }
                redirectToCart(request, response);
                return;
            }
            default:
                redirectToCart(request, response);
                return;
        }
    }

    /** Gửi câu trả lời dạng chữ máy đọc: thành công hay không, tổng tiền, số dòng, thông báo. */
    private void sendJson(HttpServletResponse response, boolean success, long totalAmount, int cartCount, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String safeMessage = escapeJson(message == null ? "" : message);

        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":").append(success).append(",");
        json.append("\"totalAmount\":").append(totalAmount).append(",");
        json.append("\"cartCount\":").append(cartCount).append(",");
        json.append("\"message\":\"").append(safeMessage).append("\"");
        json.append("}");

        response.getWriter().print(json.toString());
    }

    private String escapeJson(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }

}
