package controller.admin;

import dao.CategoryDAO;
import dao.ProductDAO;
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
            String specName = request.getParameter("specName").trim();
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            boolean isVariantRequested = "1".equals(request.getParameter("isVariant"));

            // Kiểm tra trùng tên thông số
            if (sdao.isSpecDuplicate(specName, categoryId, 0)) {
                session.setAttribute("msg", "Error: Parameter name already exists in this category!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect("specificationServlet?action=add");
                return;
            }

            if (isVariantRequested) {
                // RÀNG BUỘC 1: Nếu đã có sản phẩm thì không cho thêm Variant mới (tránh hỏng dữ liệu cũ)
                int productCount = sdao.countProductsInCategory(categoryId);
                if (productCount > 0) {
                    session.setAttribute("msg", "ERROR: Cannot add a variant because this category already contains " + productCount + " products!");
                    session.setAttribute("msgType", "danger");
                    response.sendRedirect("specificationServlet?action=add");
                    return;
                }

                // RÀNG BUỘC 2: CHỖ BỊ THIẾU - Kiểm tra xem Category này đã có Variant nào chưa
                if (sdao.hasExistingVariantInCategory(categoryId, 0)) {
                    session.setAttribute("msg", "ERROR: This category already has a variant specification! (Only 1 variant per category allowed)");
                    session.setAttribute("msgType", "danger");
                    response.sendRedirect("specificationServlet?action=add");
                    return;
                }
            }

            // Nếu ok hết thì mới Insert
            SpecificationDefinition s = new SpecificationDefinition();
            s.setCategoryId(categoryId);
            s.setSpecName(specName);
            s.setUnit(request.getParameter("unit"));
            s.setIsActive(true);
            s.setIsVariant(isVariantRequested);

            sdao.insertSpec(s);
            session.setAttribute("msg", "Specification added successfully!");
            session.setAttribute("msgType", "success");
        } else if ("update".equals(action)) {
            int specId = Integer.parseInt(request.getParameter("specId"));
            String specName = request.getParameter("specName").trim();
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            boolean isVariantRequested = "1".equals(request.getParameter("isVariant"));

            SpecificationDefinition oldSpec = sdao.getSpecById(specId);

            if (oldSpec.isIsVariant() != isVariantRequested) {
                int productCount = sdao.countProductsInCategory(categoryId);
                if (productCount > 0) {
                    session.setAttribute("msg", "ERROR: Cannot change Spec Type! This category already contains " + productCount + " products.");
                    session.setAttribute("msgType", "danger");
                    response.sendRedirect("specificationServlet?action=edit&id=" + specId);
                    return; // Dừng xử lý ngay lập tức
                }
            }

            if (oldSpec.isIsVariant() && !isVariantRequested) {
                int usedCount = sdao.countSpecUsedAsVariant(specId);
                if (usedCount > 0) {
                    session.setAttribute("msg", "Error: Cannot change to General Spec! This variant is already assigned to " + usedCount + " product variants.");
                    session.setAttribute("msgType", "danger");
                    response.sendRedirect("specificationServlet?action=edit&id=" + specId);
                    return;
                }
            }

            if (sdao.isSpecDuplicate(specName, categoryId, specId)) {
                session.setAttribute("msg", "Error: Parameter name already exists in this category!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect("specificationServlet?action=edit&id=" + specId);
                return;
            }

            if (isVariantRequested && sdao.hasExistingVariantInCategory(categoryId, specId)) {
                session.setAttribute("msg", "Error: This category already has a variant specification!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect("specificationServlet?action=edit&id=" + specId);
                return;
            }

            SpecificationDefinition s = new SpecificationDefinition();
            s.setSpecId(specId);
            s.setCategoryId(categoryId);
            s.setSpecName(specName);
            s.setUnit(request.getParameter("unit"));
            s.setIsActive("1".equals(request.getParameter("isActive")));
            s.setIsVariant(isVariantRequested);

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
