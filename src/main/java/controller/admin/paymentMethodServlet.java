/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.admin;

import dao.PaymentMethodDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.PaymentMethod;

/**
 *
 * @author WIN11
 */
@WebServlet(name = "paymentMethodServlet", urlPatterns = {"/paymentMethodServlet"})
public class paymentMethodServlet extends HttpServlet {

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
            out.println("<title>Servlet paymentMethodServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet paymentMethodServlet at " + request.getContextPath() + "</h1>");
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
        String page = "/pages/paymentMethodManagement.jsp";
        List<?> listData = null;
        PaymentMethodDAO pdao = new PaymentMethodDAO();

        if (action != null) {
            switch (action) {
                case "add":
                    page = "/pages/PaymentMethodManagementPage/addPaymentMethod.jsp";
                    break;
                case "delete":
                    int idDel = Integer.parseInt(request.getParameter("id"));
                    PaymentMethod pm = pdao.getPaymentMethodById(idDel);
                    int orderCount = pdao.countOrdersByPaymentMethodId(idDel);
                    request.setAttribute("payment", pm);
                    request.setAttribute("orderCount", orderCount);
                    page = "/pages/PaymentMethodManagementPage/deletePaymentMethod.jsp";
                    break;
                case "edit":
                    int idEdit = Integer.parseInt(request.getParameter("id"));
                    PaymentMethod pmEdit = pdao.getPaymentMethodById(idEdit);
                    request.setAttribute("payment", pmEdit);
                    page = "/pages/PaymentMethodManagementPage/editPaymentMethod.jsp";
                    break;
                case "all":
                    page = "/pages/PaymentMethodManagementPage/paymentMethodManagement.jsp";
                    listData = pdao.getAllPaymentMethods();
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
        PaymentMethodDAO pdao = new PaymentMethodDAO();

        if ("add".equals(action)) {
            String name = request.getParameter("method_name");
            String statusRaw = request.getParameter("is_active");
            boolean status = "1".equals(statusRaw);
            pdao.insertPaymentMethod(name, status);
        }
        if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("method_id"));
            String name = request.getParameter("method_name");
            boolean status = "1".equals(request.getParameter("is_active"));

            PaymentMethod pm = new PaymentMethod(id, name, status);
            pdao.updatePaymentMethod(pm);
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("method_id"));
            int count = pdao.countOrdersByPaymentMethodId(id);

            if (count > 0) {
                pdao.deactivatePaymentMethod(id);
                request.getSession().setAttribute("msg", "Payment method is linked to " + count + " order(s). Switched to INACTIVE.");
            } else {
                pdao.deletePaymentMethod(id);
                request.getSession().setAttribute("msg", "Payment method deleted successfully!");
            }
            request.getSession().setAttribute("msgType", "success");
        }

        response.sendRedirect("paymentMethodServlet?action=all");
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
