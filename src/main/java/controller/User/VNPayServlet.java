/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.User;

import dao.CartItemDAO;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.VNPayConfig;
import utils.VNPayUtils;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 *
 * @author WIN11
 */
@WebServlet(name = "vnpayservlet", urlPatterns = {"/vnpayservlet"})
public class VNPayServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
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
            out.println("<title>Servlet VNPayServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet VNPayServlet at " + request.getContextPath() + "</h1>");
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
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("pay".equals(action)) {
            handleCreatePayment(request, response);
        } else if ("return".equals(action)) {
            handleReturn(request, response);
        }
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
        processRequest(request, response);
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
// Tạo URL thanh toán và redirect sang VNPay

    private void handleCreatePayment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String orderIdParam = request.getParameter("orderId");
        String amountParam = request.getParameter("amount"); // số tiền (VND, chưa x100)

        // VNPay yêu cầu amount x100
        long amount = Long.parseLong(amountParam) * 100;

        String createDate = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
        String expireDate = new SimpleDateFormat("yyyyMMddHHmmss")
                .format(new Date(System.currentTimeMillis() + 15 * 60 * 1000)); // hết hạn 15 phút

        String ipAddr = request.getRemoteAddr();

        Map<String, String> vnpParams = new HashMap<>();
        vnpParams.put("vnp_Version", VNPayConfig.vnp_Version);
        vnpParams.put("vnp_Command", VNPayConfig.vnp_Command);
        vnpParams.put("vnp_TmnCode", VNPayConfig.vnp_TmnCode);
        vnpParams.put("vnp_Amount", String.valueOf(amount));
        vnpParams.put("vnp_CurrCode", VNPayConfig.vnp_CurrCode);
        vnpParams.put("vnp_TxnRef", orderIdParam);               // mã đơn hàng
        vnpParams.put("vnp_OrderInfo", "Thanh toan don hang #" + orderIdParam);
        vnpParams.put("vnp_OrderType", VNPayConfig.vnp_OrderType);
        vnpParams.put("vnp_Locale", VNPayConfig.vnp_Locale);
        vnpParams.put("vnp_ReturnUrl", VNPayConfig.vnp_ReturnUrl);
        vnpParams.put("vnp_IpAddr", ipAddr);
        vnpParams.put("vnp_CreateDate", createDate);
        vnpParams.put("vnp_ExpireDate", expireDate);

        String paymentUrl = VNPayUtils.buildPaymentUrl(vnpParams);
        response.sendRedirect(paymentUrl);
    }

    // Nhận kết quả từ VNPay sau khi thanh toán
    private void handleReturn(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Map<String, String> params = new HashMap<>();
        request.getParameterMap().forEach((k, v) -> params.put(k, v[0]));

        String orderId = params.get("vnp_TxnRef");
        String responseCode = params.get("vnp_ResponseCode");
        String transactionNo = params.get("vnp_TransactionNo");
        String amount = params.get("vnp_Amount");

        boolean validHash = VNPayUtils.verifySecureHash(new HashMap<>(params));
        boolean success = "00".equals(responseCode);

        if (success) {
            try {
                int id = Integer.parseInt(orderId);
                new OrderDAO().updateOrderPaymentStatus(id, "PAID");

                int customerId = new OrderDAO().getCustomerIdByOrderId(id);
                if (customerId > 0) {
                    new CartItemDAO().deleteCartByCustomerId(customerId);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            response.sendRedirect("orderpageservlet?orderSuccess=1&orderId=" + orderId);
            return;
        }

        // Thanh toán thất bại hoặc user hủy → xóa order khỏi DB
        try {
            int id = Integer.parseInt(orderId);
            OrderDAO orderDAO = new OrderDAO();
            orderDAO.cancelUnpaidOrder(id); // xóa order + hoàn inventory
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Hủy hoặc thất bại → quay về trang đặt hàng
        request.getSession().setAttribute("vnpayError", "24".equals(responseCode)
                ? "You have canceled your VNPAY payment or an error has occurred. Please try again. We apologize for the inconvenience."
                : "VNPay payment failed (Error code: " + responseCode + "). ");
        response.sendRedirect("orderpageservlet");
    }
}
