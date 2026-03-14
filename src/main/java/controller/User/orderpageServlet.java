/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.User;

import dao.CartItemDAO;
import dao.CustomerAddressDAO;
import dao.CustomerDAO;
import dao.InventoryItemDAO;
import dao.OrderDAO;
import dao.OrderItemDAO;
import dao.PaymentMethodDAO;
import dao.VoucherDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.CartItemDisplay;
import model.OrderItem;
import model.PaymentMethod;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "orderpageServlet", urlPatterns = {"/orderpageservlet"})
public class orderpageServlet extends HttpServlet {

    /**
     * <<<<<<< Updated upstream Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods. ======= Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods. >>>>>>> Stashed changes
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet orderpageServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet orderpageServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
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
        return getCustomerIdFromCookie(request);
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
        // 1. Xác thực người dùng
        int currentUserId = getCurrentUserId(request);
        if (currentUserId == -1) {
            response.sendRedirect("userservlet?action=loginPage");
            return;
        }

        String orderSuccess = request.getParameter("orderSuccess");
        String orderIdParam = request.getParameter("orderId");
        if ("1".equals(orderSuccess) && orderIdParam != null) {
            request.setAttribute("newOrderId", orderIdParam);
            request.setAttribute("showSuccessModal", true);
        }

        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        int customerId = getCustomerId(request);
        List<CartItemDisplay> listCart = new java.util.ArrayList<>();
        long totalAmount = 0;
        if (customerId > 0) {
            CartItemDAO cartDao = new CartItemDAO();
            listCart = cartDao.getCartDisplayByCustomerId(customerId);
            for (CartItemDisplay d : listCart) {
                totalAmount += d.getSubtotal();
            }
        }
        CustomerDAO aO = new CustomerDAO();
        CustomerAddressDAO addressDAO = new CustomerAddressDAO();
        VoucherDAO vdao = new VoucherDAO();

        request.setAttribute("listaddress", addressDAO.getAddressesByCustomerId(customerId));
        request.setAttribute("listCart", listCart);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("listVoucher", vdao.getAllVoucher());

        String headerComponent = "/components/navbar.jsp";
        String footerComponent = "/components/footer.jsp";
        String page = "/pages/MainPage/orderPage.jsp";
        request.setAttribute("HeaderComponent", headerComponent);
        request.setAttribute("FooterComponent", footerComponent);
        request.setAttribute("ContentPage", page);

        PaymentMethodDAO pdao = new PaymentMethodDAO();
        List<PaymentMethod> activeMethods = pdao.getActivePaymentMethods();
        request.setAttribute("paymentMethods", activeMethods);
        // 5. Forward đến Template duy nhất

        request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int customerId = getCustomerId(request);
        if (customerId <= 0) {
            response.sendRedirect("userservlet?action=loginPage");
            return;
        }

        // Lấy địa chỉ giao hàng được chọn
        String addressIdRaw = request.getParameter("addressId");
        int addressId = -1;
        try {
            addressId = Integer.parseInt(addressIdRaw);
        } catch (NumberFormatException ignored) {
        }

        CustomerAddressDAO addressDAO = new CustomerAddressDAO();
        model.CustomerAddress shippingAddressObj = addressId > 0 ? addressDAO.getAddressById(addressId) : null;
        String shippingAddress = shippingAddressObj != null ? shippingAddressObj.getAddress() : "";

        // Lấy phương thức thanh toán
        String paymentMethodRaw = request.getParameter("paymentMethodId");
        int paymentMethodId = 0;
        try {
            paymentMethodId = Integer.parseInt(paymentMethodRaw);
        } catch (NumberFormatException ignored) {
        }

        // Tính lại tổng tiền từ giỏ hàng
        CartItemDAO cartDao = new CartItemDAO();
        List<CartItemDisplay> listCart = cartDao.getCartDisplayByCustomerId(customerId);
        long subtotal = 0;
        for (CartItemDisplay d : listCart) {
            subtotal += d.getSubtotal();
        }

        // Áp dụng voucher (nếu có)
        String appliedVoucherIdRaw = request.getParameter("appliedVoucherId");
        int voucherId = 0;
        try {
            voucherId = Integer.parseInt(appliedVoucherIdRaw);
        } catch (NumberFormatException ignored) {
        }

        model.Voucher appliedVoucher = null;
        double discount = 0;
        
        if (voucherId > 0) {
            VoucherDAO vdao = new VoucherDAO();
            appliedVoucher = vdao.getVoucherById(voucherId);
            if (appliedVoucher != null && appliedVoucher.isAvailable()
                    && subtotal >= appliedVoucher.getMinOrderValue()) {
                double calculatedDiscount = subtotal * (appliedVoucher.getDiscountPercent() / 100.0);
                double maxDiscount = appliedVoucher.getMaxDiscountAmount();
                if (maxDiscount > 0 && calculatedDiscount > maxDiscount) {
                    calculatedDiscount = maxDiscount;
                }
                if (calculatedDiscount > subtotal) {
                    calculatedDiscount = subtotal;
                }
                discount = calculatedDiscount;
            }
        }

        BigDecimal totalAmount = BigDecimal.valueOf(subtotal - Math.round(discount));

        // BƯỚC VALIDATE: Kiểm tra tồn kho trước khi tạo order
        // Nếu bất kỳ sản phẩm nào không đủ hàng IN_STOCK → báo lỗi, không tạo order
        InventoryItemDAO inventoryDAO = new InventoryItemDAO();
        for (CartItemDisplay item : listCart) {
            List<Integer> available = inventoryDAO.getAvailableInventoryIdsByVariantId(
                    item.getVariantId(), item.getQuantity());
            if (available.size() < item.getQuantity()) {
                // Không đủ hàng → redirect về trang order với thông báo lỗi
                response.sendRedirect("orderpageservlet?error=out_of_stock&product="
                        + java.net.URLEncoder.encode(item.getProductName(), "UTF-8"));
                return;
            }
        }

        // 1. Tạo đơn hàng (header) và lấy order_id
        OrderDAO orderDAO = new OrderDAO();
        model.Order newOrder = new model.Order(
                customerId,
                appliedVoucher,
                paymentMethodId,
                shippingAddress,
                totalAmount
        );
        int orderId = orderDAO.insertOrder(newOrder);
        if (orderId <= 0) {
            response.sendRedirect("orderpageservlet");
            return;
        }

        // 2. Thêm chi tiết đơn hàng (order_items) từ giỏ hàng, cập nhật tồn kho
        OrderItemDAO orderItemDAO = new OrderItemDAO();
        for (CartItemDisplay item : listCart) {
            int variantId = item.getVariantId();
            int qty = item.getQuantity();
            BigDecimal sellingPrice = BigDecimal.valueOf(item.getSellingPrice());
            List<Integer> inventoryIds = inventoryDAO.getAvailableInventoryIdsByVariantId(variantId, qty);
            for (Integer invId : inventoryIds) {
                orderItemDAO.insertOrderItem(new OrderItem(orderId, invId, sellingPrice));
                inventoryDAO.updateStatus(invId, "SOLD");
            }
        }

        // 3. Xóa giỏ hàng sau khi đặt hàng thành công
        cartDao.deleteCartByCustomerId(customerId);
        // 4. Cập nhật số lượng voucher đã sử dụng
        if (appliedVoucher != null) {
            VoucherDAO vdao = new VoucherDAO();
            vdao.incrementUsedQuantity(appliedVoucher.getVoucherId());
        }
        response.sendRedirect("orderpageservlet?orderSuccess=1&orderId=" + orderId);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

    /**
     * Lấy userId từ cookie "cookieID". Trả về -1 nếu không tìm thấy hoặc cookie không hợp lệ.
     */
    private int getCurrentUserId(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("cookieID".equals(cookie.getName())) {
                    try {
                        return Integer.parseInt(cookie.getValue());
                    } catch (NumberFormatException e) {
                        return -1;
                    }
                }
            }
        }
        return -1;
    }
}
