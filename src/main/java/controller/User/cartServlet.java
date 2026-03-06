package controller.User;

import dao.CartItemDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.CartItem;
import model.CartItemDisplay;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "cartServlet", urlPatterns = {"/cartservlet"})
public class cartServlet extends HttpServlet {

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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        int customerId = getCustomerId(request);
        List<CartItemDisplay> listCart = new java.util.ArrayList<>();
        if (customerId > 0) {
            CartItemDAO cartDao = new CartItemDAO();
            listCart = cartDao.getCartDisplayByCustomerId(customerId);
        }
        int cartCount = listCart.size();

        // API chỉ trả số giỏ (JSON) để client cập nhật badge không cần F5
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
        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"))
                || "1".equals(request.getParameter("ajax"));

        if ("add".equals(action)) {
            int customerId = getCustomerId(request);
            if (customerId <= 0) {
                if (isAjax) {
                    sendJson(response, false, 0, 0, "Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.");
                } else {
                    response.sendRedirect(request.getContextPath() + "/userservlet?action=loginPage&from=cart");
                }
                return;
            }

            String vParam = request.getParameter("variant_id");
            String qParam = request.getParameter("quantity");
            if (vParam == null || vParam.isEmpty() || qParam == null || qParam.isEmpty()) {
                if (isAjax) {
                    sendJson(response, false, 0, 0, "Dữ liệu sản phẩm không hợp lệ.");
                } else {
                    response.sendRedirect(request.getContextPath() + "/cartservlet");
                }
                return;
            }

            int variantId;
            int quantity;
            try {
                variantId = Integer.parseInt(vParam);
                quantity = Integer.parseInt(qParam);
                if (quantity < 1) {
                    quantity = 1;
                }
            } catch (NumberFormatException e) {
                if (isAjax) {
                    sendJson(response, false, 0, 0, "Số lượng không hợp lệ.");
                } else {
                    response.sendRedirect(request.getContextPath() + "/cartservlet");
                }
                return;
            }

            CartItemDAO cartDao = new CartItemDAO();
            CartItem existing = cartDao.getByCustomerAndVariant(customerId, variantId);
            if (existing != null) {
                existing.setQuantity(existing.getQuantity() + quantity);
                cartDao.updateCartItem(existing);
            } else {
                CartItem newItem = new CartItem(0, customerId, variantId, quantity, null);
                cartDao.insertCartItem(newItem);
            }
            if (isAjax) {
                long totalAmount = 0;
                List<CartItemDisplay> list = cartDao.getCartDisplayByCustomerId(customerId);
                int cartCountAjax = (list != null) ? list.size() : 0; // Số sản phẩm khác nhau (như trong giỏ)
                for (CartItemDisplay d : list) {
                    totalAmount += d.getSubtotal();
                }
                request.getSession().setAttribute("cartCount", cartCountAjax);
                sendJson(response, true, totalAmount, cartCountAjax, "Đã thêm vào giỏ hàng.");
            } else {
                request.getSession().setAttribute("msg", "Đã thêm vào giỏ hàng.");
                request.getSession().setAttribute("msgType", "success");
                response.sendRedirect(request.getContextPath() + "/cartservlet");
            }
            return;
        }

        if ("update".equals(action)) {
            int customerId = getCustomerId(request);
            if (customerId <= 0) {
                if (isAjax) {
                    sendJson(response, false, 0, 0, "Vui lòng đăng nhập lại để cập nhật giỏ hàng.");
                } else {
                    response.sendRedirect(request.getContextPath() + "/cartservlet");
                }
                return;
            }
            CartItemDAO cartDao = new CartItemDAO();
            String idParam = request.getParameter("cart_item_id");
            String qParam = request.getParameter("quantity");
            if (idParam != null && qParam != null) {
                try {
                    int cartItemId = Integer.parseInt(idParam);
                    int quantity = Integer.parseInt(qParam);
                    if (quantity >= 1) {
                        CartItem item = cartDao.getCartItemById(cartItemId);
                        if (item != null && item.getCustomer_id() == customerId) {
                            item.setQuantity(quantity);
                            cartDao.updateCartItem(item);
                        }
                    }
                } catch (NumberFormatException ignored) {
                }
            }
            if (isAjax) {
                long totalAmount = 0;
                List<CartItemDisplay> list = cartDao.getCartDisplayByCustomerId(customerId);
                int cartCountAjax = (list != null) ? list.size() : 0; // Số sản phẩm khác nhau (như badge)
                for (CartItemDisplay d : list) {
                    totalAmount += d.getSubtotal();
                }
                request.getSession().setAttribute("cartCount", cartCountAjax);
                sendJson(response, true, totalAmount, cartCountAjax, null);
            } else {
                response.sendRedirect(request.getContextPath() + "/cartservlet");
            }
            return;
        }

        if ("remove".equals(action)) {
            int customerId = getCustomerId(request);
            if (customerId <= 0) {
                response.sendRedirect(request.getContextPath() + "/cartservlet");
                return;
            }
            String idParam = request.getParameter("cart_item_id");
            if (idParam != null) {
                try {
                    int cartItemId = Integer.parseInt(idParam);
                    CartItemDAO cartDao = new CartItemDAO();
                    CartItem item = cartDao.getCartItemById(cartItemId);
                    if (item != null && item.getCustomer_id() == customerId) {
                        cartDao.deleteCartItem(cartItemId);
                    }
                } catch (NumberFormatException ignored) {
                }
            }
            response.sendRedirect(request.getContextPath() + "/cartservlet");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/cartservlet");
    }

    /**
     * Trả JSON cho AJAX: { "success": true/false, "totalAmount": number,
     * "cartCount": number, "message": "..." }
     */
    private void sendJson(HttpServletResponse response, boolean success, long totalAmount, int cartCount) throws IOException {
        sendJson(response, success, totalAmount, cartCount, null);
    }

    private void sendJson(HttpServletResponse response, boolean success, long totalAmount, int cartCount, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String msg = message != null ? ",\"message\":\"" + message.replace("\\", "\\\\").replace("\"", "\\\"") + "\"" : "";
        response.getWriter().print("{\"success\":" + success + ",\"totalAmount\":" + totalAmount + ",\"cartCount\":" + cartCount + msg + "}");
    }

}
