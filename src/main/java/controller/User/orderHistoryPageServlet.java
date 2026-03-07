/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import dao.OrderDAO;
import dao.OrderStatusDAO;

import model.Order;
import model.OrderStatus;

@WebServlet(name = "orderHistoryPageServlet", urlPatterns = {"/orderhistorypageservlet"})
public class orderHistoryPageServlet extends HttpServlet {

    private static final String NAVBAR = "/components/navbar.jsp";
    private static final String FOOTER = "/components/footer.jsp";
    private static final String TEMPLATE = "/template/userTemplate.jsp";

    private static final String PAGE_HISTORY = "/pages/MainPage/orderHistoryPage.jsp";
    private static final String PAGE_DETAIL = "/pages/MainPage/orderDetailCustomer.jsp";

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
            out.println("<title>Servlet orderHistoryPageServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet orderHistoryPageServlet at " + request.getContextPath() + "</h1>");
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

        // 1. Xác thực người dùng
        int currentUserId = getCurrentUserId(request);
        if (currentUserId == -1) {
            response.sendRedirect("userservlet?action=loginPage");
            return;
        }

        // 2. Điều hướng theo action
        String action = request.getParameter("action");
        if ("orderDetail".equals(action)) {
            handleOrderDetail(request, response, currentUserId);
        } else {
            handleOrderHistory(request, response, currentUserId);
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

    /**
     * Xử lý xem chi tiết một đơn hàng cụ thể. Kiểm tra quyền: chỉ chủ đơn hàng mới được xem.
     */
    private void handleOrderDetail(HttpServletRequest request, HttpServletResponse response,
            int currentUserId) throws ServletException, IOException {

        String orderIdParam = request.getParameter("id");
        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            handleOrderHistory(request, response, currentUserId);
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdParam);
            OrderDAO orderDao = new OrderDAO();
            Order order = orderDao.getOrderById(orderId);

            // Kiểm tra quyền: đơn tồn tại và thuộc về user hiện tại
            if (order != null && order.getCustomerId() == currentUserId) {
                List<Map<String, Object>> items = orderDao.getOrderDetails(orderId);
                request.setAttribute("order", order);
                request.setAttribute("items", items);
                forwardToTemplate(request, response, PAGE_DETAIL);
            } else {
                response.sendRedirect("orderhistorypageservlet?error=access_denied");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("orderhistorypageservlet?error=invalid_id");
        }
    }

    /**
     * Xử lý trang danh sách lịch sử đơn hàng, có lọc theo trạng thái.
     */
    private void handleOrderHistory(HttpServletRequest request, HttpServletResponse response,
            int currentUserId) throws ServletException, IOException {

        String statusFilter = request.getParameter("status");
        boolean isFilterAll = (statusFilter == null || statusFilter.trim().isEmpty()
                || "ALL".equalsIgnoreCase(statusFilter));

        // Lấy toàn bộ đơn hàng rồi lọc nếu cần
        OrderDAO orderDao = new OrderDAO();
        List<Order> allOrders = orderDao.getOrdersByCustomerWithSummary(currentUserId);
        List<Order> ordersToShow;

        if (isFilterAll) {
            ordersToShow = allOrders;
        } else {
            ordersToShow = new ArrayList<>();
            for (Order o : allOrders) {
                if (statusFilter.equalsIgnoreCase(o.getStatus())) {
                    ordersToShow.add(o);
                }
            }
        }

        List<OrderStatus> statusList = new OrderStatusDAO().getAllOrderStatuses();

        request.setAttribute("orders", ordersToShow);
        request.setAttribute("statusList", statusList);
        request.setAttribute("currentStatus", isFilterAll ? "ALL" : statusFilter);

        forwardToTemplate(request, response, PAGE_HISTORY);
    }

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

    /**
     * Set layout attributes và forward đến template duy nhất.
     */
    private void forwardToTemplate(HttpServletRequest request, HttpServletResponse response,
            String contentPage) throws ServletException, IOException {
        request.setAttribute("HeaderComponent", NAVBAR);
        request.setAttribute("FooterComponent", FOOTER);
        request.setAttribute("ContentPage", contentPage);
        request.getRequestDispatcher(TEMPLATE).forward(request, response);
    }
}
