package controller.admin;

import dao.CategoryDAO;
import dao.SpecificationDefinitionDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.SpecificationDefinition;

/**
 *
 * @author Hong Kieu
 */
@WebServlet(name = "specificationServlet", urlPatterns = {"/specificationServlet"})
public class specificationServlet extends HttpServlet {

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
            out.println("<title>Servlet specificationServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet specificationServlet at " + request.getContextPath() + "</h1>");
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
        String page = "/pages/SpecificationDefinitionManagementPage/specificationDefinitionManagement.jsp";
        List<SpecificationDefinition> listData = null;

        SpecificationDefinitionDAO sdao = new SpecificationDefinitionDAO();
        CategoryDAO cdao = new CategoryDAO();

        if (action != null) {
            switch (action) {
                case "add":
                    request.setAttribute("categories", cdao.getAllCategory());
                    page = "/pages/SpecificationDefinitionManagementPage/addSpecification.jsp";
                    break;
                case "edit":
                    int idEdit = Integer.parseInt(request.getParameter("id"));
                    request.setAttribute("spec", sdao.getSpecById(idEdit));
                    request.setAttribute("categories", cdao.getAllCategory());
                    page = "/pages/SpecificationDefinitionManagementPage/editSpecification.jsp";
                    break;
                case "detail":
                    int idDetail = Integer.parseInt(request.getParameter("id"));
                    request.setAttribute("spec", sdao.getSpecById(idDetail));
                    request.setAttribute("usageCount", sdao.countSpecUsedInProducts(idDetail));
                    page = "/pages/SpecificationDefinitionManagementPage/detailSpecification.jsp";
                    break;
                case "delete":
                    int idDel = Integer.parseInt(request.getParameter("id"));
                    request.setAttribute("spec", sdao.getSpecById(idDel));
                    request.setAttribute("usageCount", sdao.countSpecUsedInProducts(idDel));
                    page = "/pages/SpecificationDefinitionManagementPage/deleteSpecification.jsp";
                    break;
                case "all":
                default:
                    request.setAttribute("categories", cdao.getAllCategory());
                    listData = sdao.getAllSpecs();
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
        SpecificationDefinitionDAO sdao = new SpecificationDefinitionDAO();
        HttpSession session = request.getSession();

        if ("add".equals(action)) {
            SpecificationDefinition s = new SpecificationDefinition();
            s.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            s.setSpecName(request.getParameter("specName").trim());
            s.setUnit(request.getParameter("unit"));
            s.setIsActive(true);
            s.setIsVariant("1".equals(request.getParameter("isVariant")));

            sdao.insertSpec(s);
            session.setAttribute("msg", "Specification added successfully!");
            session.setAttribute("msgType", "success");

        } else if ("update".equals(action)) {
            SpecificationDefinition s = new SpecificationDefinition();
            s.setSpecId(Integer.parseInt(request.getParameter("specId")));
            s.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            s.setSpecName(request.getParameter("specName").trim());
            s.setUnit(request.getParameter("unit"));
            s.setIsActive("1".equals(request.getParameter("isActive")));
            s.setIsVariant("1".equals(request.getParameter("isVariant")));

            sdao.updateSpec(s);
            session.setAttribute("msg", "Specification updated successfully!");
            session.setAttribute("msgType", "success");

        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("specId"));
            if (sdao.countSpecUsedInProducts(id) > 0) {
                sdao.softDeleteSpec(id);
                session.setAttribute("msg", "Spec in use. Deactivated instead of deleted.");
            } else {
                sdao.deleteSpec(id);
                session.setAttribute("msg", "Spec deleted successfully!");
            }
            session.setAttribute("msgType", "success");
        }
        response.sendRedirect("specificationServlet?action=all");
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
