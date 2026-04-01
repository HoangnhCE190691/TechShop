/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;

import dao.OrderDAO;
import dao.OrderStatusDAO;
import dao.OrderStatusHistoryDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Order;
import model.OrderItem;
import model.OrderStatusHistory;

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

    private int getEmployeeIdFromCookie(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("cookieID".equals(c.getName())) {
                    try {
                        return Integer.parseInt(c.getValue());
                    } catch (NumberFormatException e) {
                        return 0;
                    }
                }
            }
        }
        return 0;
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
                    String cancelledStatusCode = odao.getCancelledStatusCode();
                    List<Map<String, Object>> items;
                    OrderStatusHistoryDAO historyDao = new OrderStatusHistoryDAO();
                    List<OrderStatusHistory> statusHistory = historyDao.getOrderStatusHistoryWithEmployeeName(idDetail);

                    if (order != null && cancelledStatusCode != null && cancelledStatusCode.equalsIgnoreCase(order.getStatus())) {
                        items = odao.getCancelledOrderDetailsWithIMEI(idDetail);
                        if (items == null || items.isEmpty()) {
                            items = odao.getOrderDetailsWithIMEI(idDetail);
                        }
                    } else {
                        items = odao.getOrderDetailsWithIMEI(idDetail);
                    }

                    request.setAttribute("order", order);
                    request.setAttribute("items", items);
                    request.setAttribute("statusHistory", statusHistory);
                    page = "/pages/OrderManagementPage/orderDetail.jsp";
                    break;
                case "editOrderPage":
                    int idEdit = Integer.parseInt(request.getParameter("id"));
                    Order orderToEdit = odao.getOrderById(idEdit);

                    List<OrderItem> orderItems = odao.getOrderItemsByOrderId(idEdit);
                    request.setAttribute("orderItems", orderItems);
                    request.setAttribute("odao", odao);

                    String currentStatus = (orderToEdit != null && orderToEdit.getStatus() != null)
                            ? orderToEdit.getStatus().trim()
                            : "";

                    String nextStatus = odao.getNextStatus(currentStatus);
                    if (nextStatus != null) {
                        nextStatus = nextStatus.trim();
                    }

                    String cancelledCode = odao.getCancelledStatusCode();
                    String nextOfNext = (nextStatus != null && !nextStatus.isEmpty())
                            ? odao.getNextStatus(nextStatus)
                            : "";

                    boolean showAllocation = "APPROVED".equalsIgnoreCase(currentStatus)
                            || "SHIPPING".equalsIgnoreCase(nextStatus);

                    request.setAttribute("order", orderToEdit);
                    request.setAttribute("nextStatus", nextStatus != null ? nextStatus : "");
                    request.setAttribute("cancelledCode", cancelledCode);
                    request.setAttribute("nextOfNext", nextOfNext != null ? nextOfNext : "");
                    request.setAttribute("showAllocation", showAllocation);

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

            // Get current status before update
            Order currentOrder = odao.getOrderById(orderId);
            String oldStatus = currentOrder != null ? currentOrder.getStatus() : "";

            // ============================================================
            // PRODUCT ALLOCATION LOGIC
            // ============================================================
            if ("SHIPPING".equalsIgnoreCase(status) && "APPROVED".equalsIgnoreCase(oldStatus)) {

                // BƯỚC 1: Kiểm tra số lượng tồn kho TRƯỚC
                if (!odao.hasEnoughStockForOrder(orderId)) {
                    session.setAttribute("msg", "Error: Khong du san pham trong kho de phan bo!");
                    session.setAttribute("msgType", "danger");
                    response.sendRedirect("orderStaffServlet?action=editOrderPage&id=" + orderId);
                    return;
                }

                // BƯỚC 2: Thu thap allocations tu form
                Map<Integer, Integer> allocations = new HashMap<>();
                Enumeration<String> params = request.getParameterNames();
                while (params.hasMoreElements()) {
                    String paramName = params.nextElement();
                    if (paramName.startsWith("assign_inv_")) {
                        int orderItemId = Integer.parseInt(paramName.replace("assign_inv_", ""));
                        String invIdValue = request.getParameter(paramName);
                        if (invIdValue != null && !invIdValue.isEmpty()) {
                            allocations.put(orderItemId, Integer.parseInt(invIdValue));
                        }
                    }
                }

                // BƯỚC 3: VALIDATION - Kiem tra TAT CA cac dropdown deu co gia tri
                List<OrderItem> itemsInOrder = odao.getOrderItemsByOrderId(orderId);
                int unselectedCount = 0;
                StringBuilder unselectedItems = new StringBuilder();

                for (OrderItem item : itemsInOrder) {
                    if (!allocations.containsKey(item.getOrderItemId()) || allocations.get(item.getOrderItemId()) == 0) {
                        unselectedCount++;
                        if (unselectedItems.length() > 0) {
                            unselectedItems.append(", ");
                        }
                        unselectedItems.append(item.getVariantName());
                    }
                }

                if (unselectedCount > 0) {
                    session.setAttribute("msg", "Error: Vui long CHON SERIAL cho tat ca san pham! Chua chon: " + unselectedItems);
                    session.setAttribute("msgType", "danger");
                    response.sendRedirect("orderStaffServlet?action=editOrderPage&id=" + orderId);
                    return;
                }

                // BƯỚC 4: Thuc hien phan bo
                if (!allocations.isEmpty()) {
                    boolean isAllocated = odao.allocateOrderItems(allocations, orderId, status);
                    if (!isAllocated) {
                        session.setAttribute("msg", "Error: He thong loi khi phan bo san pham!");
                        session.setAttribute("msgType", "danger");
                        response.sendRedirect("orderStaffServlet?action=editOrderPage&id=" + orderId);
                        return;
                    }
                }
            }
            // ============================================================

            String cancelReason = request.getParameter("cancelReason");
            if (cancelReason != null) {
                cancelReason = cancelReason.trim();
                if (cancelReason.isEmpty()) {
                    cancelReason = null;
                }
            }

            String cancelledCode = odao.getCancelledStatusCode();
            boolean isChangingToCancel = !oldStatus.equalsIgnoreCase(status)
                    && status.equalsIgnoreCase(cancelledCode);

            boolean success = odao.updateOrderFull(orderId, address, status, paymentStatus,
                    isChangingToCancel ? cancelReason : null);

            if (success) {
                if (!oldStatus.equalsIgnoreCase(status)) {
                    int employeeId = getEmployeeIdFromCookie(request);
                    int statusId = new OrderStatusDAO().getStatusIdByCode(status);
                    if (statusId > 0) {
                        new OrderStatusHistoryDAO().insertOrderStatusHistory(orderId, statusId, employeeId);
                    }

                    if (status.equalsIgnoreCase("SHIPPED")) {
                        odao.updateShippedDate(orderId, new java.sql.Timestamp(System.currentTimeMillis()));
                    } else if (isChangingToCancel) {
                        odao.updateInventoryStatusByOrderId(orderId, "IN_STOCK");
                    }
                }

                session.setAttribute("msg", "Update order success!");
                session.setAttribute("msgType", "success");

                if ("APPROVED".equalsIgnoreCase(status)) {
                    response.sendRedirect("orderStaffServlet?action=editOrderPage&id=" + orderId);
                    return;
                }
            } else {
                session.setAttribute("msg", "Update order failed!");
                session.setAttribute("msgType", "danger");
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
