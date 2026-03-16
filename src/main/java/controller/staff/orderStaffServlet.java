/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;

import dao.OrderDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;
import model.Order;

/**
 *
 * @author CaoTram
 */
@WebServlet(name = "orderStaffServlet", urlPatterns = {"/orderStaffServlet"})
public class orderStaffServlet extends HttpServlet {

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
            out.println("<title>Servlet orderStaffServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet orderStaffServlet at " + request.getContextPath() + "</h1>");
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
        String page = "/pages/OrderManagementPage/processOrderManagement.jsp";
        List<Order> listData = null;

        OrderDAO odao = new OrderDAO();
        List<Map<String, String>> statusList = odao.getAllOrderStatuses();

        if (action != null) {
            switch (action) {
                case "all":
                    listData = odao.getAllOrdersWithFullInfo();
                    request.setAttribute("statusList", statusList);
                    page = "/pages/OrderManagementPage/processOrderManagement.jsp";
                    break;

                case "orderDetail":
                    int idDetail = Integer.parseInt(request.getParameter("id"));
                    Order order = odao.getOrderById(idDetail);
                    List<Map<String, Object>> items = odao.getOrderDetailsWithIMEI(idDetail);

                    request.setAttribute("order", order);
                    request.setAttribute("items", items);
                    page = "/pages/OrderManagementPage/orderDetail.jsp";
                    break;
                case "editOrderPage":
                    int idEdit = Integer.parseInt(request.getParameter("id"));
                    Order orderToEdit = odao.getOrderById(idEdit);
                    String nextStatus = odao.getNextStatus(orderToEdit.getStatus());
                    String cancelledCode = odao.getCancelledStatusCode();
                    String nextOfNext = (nextStatus != null) ? odao.getNextStatus(nextStatus) : "";

                    request.setAttribute("order", orderToEdit);
                    request.setAttribute("nextStatus", nextStatus != null ? nextStatus : "");
                    request.setAttribute("cancelledCode", cancelledCode);
                    request.setAttribute("nextOfNext", nextOfNext != null ? nextOfNext : "");
                    page = "/pages/OrderManagementPage/editOrder.jsp";
                    break;
            }
        }

        request.setAttribute("contentPage", page);
        request.setAttribute("orderList", listData);
        request.getRequestDispatcher("/template/staffTemplate.jsp").forward(request, response);
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
        String action = request.getParameter("action");
        OrderDAO odao = new OrderDAO();
        HttpSession session = request.getSession();

        if ("updateOrder".equals(action)) {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String address = request.getParameter("shippingAddress");
            String status = request.getParameter("status");
            String paymentStatus = request.getParameter("paymentStatus");

            // Lấy status hiện tại trước khi update
            Order currentOrder = odao.getOrderById(orderId);
            String oldStatus = currentOrder != null ? currentOrder.getStatus() : "";

            boolean success = odao.updateOrderFull(orderId, address, status, paymentStatus);

            if (success) {
                // Nếu chuyển sang SHIPPED → set inventory SOLD
                String cancelledCode = odao.getCancelledStatusCode();
                if (!oldStatus.equalsIgnoreCase(status)) {
                    if (status.equalsIgnoreCase("SHIPPED")) {
                        odao.updateInventoryStatusByOrderId(orderId, "SOLD");
                    } else if (status.equalsIgnoreCase(cancelledCode)) {
                        odao.updateInventoryStatusByOrderId(orderId, "IN_STOCK");
                    }
                }
                session.setAttribute("msg", "Update order success!");
                session.setAttribute("msgType", "success");
            }
            response.sendRedirect("orderStaffServlet?action=all");
            return;
        }

        response.sendRedirect("orderStaffServlet?action=all");
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Order Management Servlet for Staff";
    }// </editor-fold>

}
