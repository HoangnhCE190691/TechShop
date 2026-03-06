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
        String headerComponent = "/components/navbar.jsp";
        String footerComponent = "/components/footer.jsp";
        String page = "/pages/MainPage/cartPage.jsp";

        int customerId = getCustomerIdFromCookie(request);
        List<CartItemDisplay> listCart = new java.util.ArrayList<>();
        if (customerId > 0) {
            CartItemDAO cartDao = new CartItemDAO();
            listCart = cartDao.getCartDisplayByCustomerId(customerId);
        }

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

        if ("add".equals(action)) {
            int customerId = getCustomerIdFromCookie(request);
            if (customerId <= 0) {
                response.sendRedirect(request.getContextPath() + "/userservlet?action=loginPage&from=cart");
                return;
            }

            String vParam = request.getParameter("variant_id");
            String qParam = request.getParameter("quantity");
            if (vParam == null || vParam.isEmpty() || qParam == null || qParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/cartservlet");
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
                response.sendRedirect(request.getContextPath() + "/cartservlet");
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

            response.sendRedirect(request.getContextPath() + "/cartservlet");
            return;
        }

        if ("update".equals(action)) {
            int customerId = getCustomerIdFromCookie(request);
            boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"))
                    || "1".equals(request.getParameter("ajax"));
            if (customerId <= 0) {
                if (isAjax) {
                    sendJson(response, false, 0);
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
                for (CartItemDisplay d : list) {
                    totalAmount += d.getSubtotal();
                }
                sendJson(response, true, totalAmount);
            } else {
                response.sendRedirect(request.getContextPath() + "/cartservlet");
            }
            return;
        }

        if ("remove".equals(action)) {
            int customerId = getCustomerIdFromCookie(request);
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
     * Trả JSON cho AJAX: { "success": true/false, "totalAmount": number }
     */
    private void sendJson(HttpServletResponse response, boolean success, long totalAmount) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().print("{\"success\":" + success + ",\"totalAmount\":" + totalAmount + "}");
    }
}
