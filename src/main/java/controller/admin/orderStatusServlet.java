/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.admin;

import dao.OrderStatusDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.OrderStatus;

/**
 *
 * @author WIN11
 */
@WebServlet(name = "orderStatusServlet", urlPatterns = {"/orderStatusServlet"})
public class orderStatusServlet extends HttpServlet {

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
            out.println("<title>Servlet orderStatusServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet orderStatusServlet at " + request.getContextPath() + "</h1>");
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
        String page = "/pages/OrderStatusManagementPage/orderStatusManagement.jsp";
        List<?> listData = null;
        OrderStatusDAO osdao = new OrderStatusDAO();

        if (action != null) {
            switch (action) {
                case "add":
                    page = "/pages/OrderStatusManagementPage/addOrderStatus.jsp";
                    break;
                case "delete":
                    try {
                        int idDel = Integer.parseInt(request.getParameter("id"));
                        OrderStatus os = osdao.getOrderStatusById(idDel);
                        if (os == null) {
                            response.sendRedirect("orderStatusServlet?action=all");
                            return;
                        }
                        int orderCount = osdao.countOrdersByStatusId(idDel);
                        request.setAttribute("status", os);
                        request.setAttribute("orderCount", orderCount);
                        page = "/pages/OrderStatusManagementPage/deleteOrderStatus.jsp";
                    } catch (NumberFormatException e) {
                        response.sendRedirect("orderStatusServlet?action=all");
                        return;
                    }
                    break;
                case "edit":
                    try {
                        int idEdit = Integer.parseInt(request.getParameter("id"));

                        OrderStatus os = osdao.getOrderStatusById(idEdit);

                        if (os != null) {
                            request.setAttribute("status", os);
                            page = "/pages/OrderStatusManagementPage/editOrderStatus.jsp";
                        } else {
                            response.sendRedirect("adminservlet?action=orderStatusManagement");
                            return;
                        }
                    } catch (NumberFormatException e) {
                        response.sendRedirect("adminservlet?action=orderStatusManagement");
                        return;
                    }
                    break;
                case "all":
                default:
                    page = "/pages/OrderStatusManagementPage/orderStatusManagement.jsp";
                    listData = osdao.getAllOrderStatuses();
                    break;
            }
        }

        request.setAttribute("contentPage", page);
        request.setAttribute("listdata", listData);
        request.getRequestDispatcher("/template/adminTemplate.jsp").forward(request, response);
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
        OrderStatusDAO osdao = new OrderStatusDAO();

        if ("add".equals(action)) {
            String code = request.getParameter("status_code");
            String name = request.getParameter("status_name");
            int step = Integer.parseInt(request.getParameter("step_order"));
            boolean isFinal = "1".equals(request.getParameter("is_final"));

            osdao.insertOrderStatus(new OrderStatus(code, name, step, isFinal));
        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("status_id"));
            String code = request.getParameter("status_code");
            String name = request.getParameter("status_name");
            int step = Integer.parseInt(request.getParameter("step_order"));
            boolean isFinal = "1".equals(request.getParameter("is_final"));

            osdao.updateOrderStatus(new OrderStatus(id, code, name, step, isFinal));
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("status_id"));
            int count = osdao.countOrdersByStatusId(id);

            if (count > 0) {
                // CHẶN HOÀN TOÀN — không xóa, trả về trang confirm với thông báo lỗi
                OrderStatus os = osdao.getOrderStatusById(id);
                request.getSession().setAttribute("msg", "Cannot delete: this status is linked to " + count + " order(s). Remove all linked orders first.");
                request.getSession().setAttribute("msgType", "danger");
                response.sendRedirect("orderStatusServlet?action=delete&id=" + id);
                return;
            }

            // Không có order liên kết → hard delete bình thường
            osdao.deleteOrderStatus(id);
            request.getSession().setAttribute("msg", "Order status deleted successfully!");
            request.getSession().setAttribute("msgType", "success");
        }

        response.sendRedirect("orderStatusServlet?action=all");
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

}
