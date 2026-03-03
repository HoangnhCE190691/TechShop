/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.admin;

import dao.ProductDAO;
import dao.ProductSpecificationValueDAO;
import dao.SpecificationDefinitionDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ProductSpecificationValues;

/**
 *
 * @author CaoTram
 */
@WebServlet(name = "specificationValueServlet", urlPatterns = {"/specificationValueServlet"})
public class specificationValueServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
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
            out.println("<title>Servlet specificationValueServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet specificationValueServlet at " + request.getContextPath() + "</h1>");
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
        String page = "/pages/SpecificationValueManagementPage/specificationValueManagement.jsp";

        ProductSpecificationValueDAO vdao = new ProductSpecificationValueDAO();
        ProductDAO pdao = new ProductDAO();
        SpecificationDefinitionDAO sdao = new SpecificationDefinitionDAO();

        if (action != null) {
            switch (action) {
                case "add":
                    request.setAttribute("products", pdao.getAllProduct());
                    request.setAttribute("specs", sdao.getAllSpecs());
                    page = "/pages/SpecificationValueManagementPage/addSpecificationValue.jsp";
                    break;
                case "edit":
                    int pId = Integer.parseInt(request.getParameter("pid"));
                    int sId = Integer.parseInt(request.getParameter("sid"));
                    request.setAttribute("val", vdao.getSpecValueById(pId, sId));
                    page = "/pages/SpecificationValueManagementPage/editSpecificationValue.jsp";
                    break;
                case "delete":
                    int delPid = Integer.parseInt(request.getParameter("pid"));
                    int delSid = Integer.parseInt(request.getParameter("sid"));
                    request.setAttribute("val", vdao.getSpecValueById(delPid, delSid));
                    page = "/pages/SpecificationValueManagementPage/deleteSpecificationValue.jsp";
                    break;
                case "detail":
                    int detPid = Integer.parseInt(request.getParameter("pid"));
                    int detSid = Integer.parseInt(request.getParameter("sid"));
                    request.setAttribute("val", vdao.getSpecValueById(detPid, detSid));
                    page = "/pages/SpecificationValueManagementPage/detailSpecificationValue.jsp";
                    break;
                case "all":
                default:
                    request.setAttribute("listdata", vdao.getAllProductSpecs());
                    request.setAttribute("specs", sdao.getAllSpecs());
                    break;
            }
        } else {
            request.setAttribute("listdata", vdao.getAllProductSpecs());
        }

        request.setAttribute("contentPage", page);
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
        ProductSpecificationValueDAO vdao = new ProductSpecificationValueDAO();
        HttpSession session = request.getSession();

        try {
            if ("add".equals(action)) {
                ProductSpecificationValues v = new ProductSpecificationValues();
                v.setProductId(Integer.parseInt(request.getParameter("productId")));
                v.setSpecId(Integer.parseInt(request.getParameter("specId")));
                v.setSpecValue(request.getParameter("specValue").trim());

                vdao.insertProductSpec(v);
                session.setAttribute("msg", "Value assigned successfully!");
            } else if ("update".equals(action)) {
                ProductSpecificationValues v = new ProductSpecificationValues();
                v.setProductId(Integer.parseInt(request.getParameter("productId")));
                v.setSpecId(Integer.parseInt(request.getParameter("specId")));
                v.setSpecValue(request.getParameter("specValue").trim());

                vdao.updateProductSpec(v);
                session.setAttribute("msg", "Specification value updated!");
            } else if ("delete".equals(action)) {
                int pId = Integer.parseInt(request.getParameter("productId"));
                int sId = Integer.parseInt(request.getParameter("specId"));
                vdao.deleteProductSpec(pId, sId);
                session.setAttribute("msg", "Removed specification from product!");
            }
            session.setAttribute("msgType", "success");
        } catch (Exception e) {
            session.setAttribute("msg", "Error: Duplicate or invalid data!");
            session.setAttribute("msgType", "danger");
        }
        response.sendRedirect("specificationValueServlet?action=all");
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
