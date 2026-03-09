package controller.staff;

import dao.ProductDAO;
import dao.ProductVariantDAO;
import dao.VariantSpecValueDAO;
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
import model.ProductVariant;
import model.VariantSpecValue;
import model.SpecificationDefinition;
import model.Product;

/**
 *
 * @author CaoTram
 */
@WebServlet(name = "productVariantServlet", urlPatterns = { "/variantServlet" })
public class productVariantServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet productVariantServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet productVariantServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the
    // + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String page = "/pages/ProductVariantManagementPage/productVariantManagement.jsp";
        List<ProductVariant> listData = null;

        ProductVariantDAO vdao = new ProductVariantDAO();
        ProductDAO pdao = new ProductDAO();

        if (action != null) {
            switch (action) {
                case "add":
                    request.setAttribute("products", pdao.getAllProduct());
                    SpecificationDefinitionDAO sdDaoAdd = new SpecificationDefinitionDAO();
                    request.setAttribute("allVariantSpecs", sdDaoAdd.getAllVariantSpecs());
                    page = "/pages/ProductVariantManagementPage/addProductVariant.jsp";
                    break;
                case "edit":
                    int idEdit = Integer.parseInt(request.getParameter("id"));
                    ProductVariant editVariant = vdao.getVariantById(idEdit);
                    request.setAttribute("variant", editVariant);
                    request.setAttribute("products", pdao.getAllProduct());

                    // Load current variant spec values
                    VariantSpecValueDAO vsDao = new VariantSpecValueDAO();
                    List<VariantSpecValue> currentSpecs = vsDao.getSpecsByVariantId(idEdit);
                    request.setAttribute("currentVariantSpecs", currentSpecs);

                    // Load variant spec definitions based on product's category
                    if (editVariant != null) {
                        Product editProduct = pdao.getProductById(editVariant.getProductId());
                        if (editProduct != null) {
                            SpecificationDefinitionDAO sdDao = new SpecificationDefinitionDAO();
                            List<SpecificationDefinition> variantSpecDefs = sdDao
                                    .getVariantSpecsByCategoryId(editProduct.getCategoryId());
                            request.setAttribute("variantSpecDefs", variantSpecDefs);
                        }
                    }

                    page = "/pages/ProductVariantManagementPage/editProductVariant.jsp";
                    break;
                case "detail":
                    int idDetail = Integer.parseInt(request.getParameter("id"));
                    request.setAttribute("variant", vdao.getVariantById(idDetail));

                    // Load variant spec values for display
                    VariantSpecValueDAO vsDetailDao = new VariantSpecValueDAO();
                    request.setAttribute("detailVariantSpecs", vsDetailDao.getSpecsByVariantId(idDetail));

                    page = "/pages/ProductVariantManagementPage/detailProductVariant.jsp";
                    break;
                case "delete":
                    int idDel = Integer.parseInt(request.getParameter("id"));
                    request.setAttribute("variant", vdao.getVariantById(idDel));
                    request.setAttribute("inventoryCount", vdao.countInventoryByVariantId(idDel));
                    page = "/pages/ProductVariantManagementPage/deleteProductVariant.jsp";
                    break;
                case "all":
                    listData = vdao.getAllVariant();
                    break;
            }
        }
        request.setAttribute("contentPage", page);
        request.setAttribute("listdata", listData);
        request.getRequestDispatcher("/template/staffTemplate.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        ProductVariantDAO vdao = new ProductVariantDAO();
        HttpSession session = request.getSession();

        if ("add".equals(action)) {
            String sku = request.getParameter("sku").trim();
            int productId = Integer.parseInt(request.getParameter("productId"));
            long price = Long.parseLong(request.getParameter("sellingPrice"));
            boolean isActive = "1".equals(request.getParameter("isActive"));

            if (vdao.isSkuDuplicate(sku, 0)) {
                session.setAttribute("msg", "Error: SKU already exists!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect("variantServlet?action=add");
                return;
            }

            ProductVariant v = new ProductVariant(0, productId, sku, price, isActive);
            int newVariantId = vdao.insertVariant(v);

            // Insert variant_spec_values nếu newVariantId > 0
            if (newVariantId > 0) {
                VariantSpecValueDAO vsUpdateDao = new VariantSpecValueDAO();
                java.util.Enumeration<String> paramNames = request.getParameterNames();
                while (paramNames.hasMoreElements()) {
                    String paramName = paramNames.nextElement();
                    if (paramName.startsWith("specValue_")) {
                        String specIdStr = paramName.substring("specValue_".length());
                        String specValue = request.getParameter(paramName);
                        if (specValue != null && !specValue.trim().isEmpty()) {
                            try {
                                int specId = Integer.parseInt(specIdStr);
                                vsUpdateDao.insertVariantSpec(newVariantId, specId, specValue.trim());
                            } catch (NumberFormatException ex) {
                                // skip invalid spec id
                            }
                        }
                    }
                }
            }

            session.setAttribute("msg", "Variant added successfully!");
            session.setAttribute("msgType", "success");

        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("variantId"));
            String sku = request.getParameter("sku").trim();
            int productId = Integer.parseInt(request.getParameter("productId"));
            long price = Long.parseLong(request.getParameter("sellingPrice"));
            boolean isActive = "1".equals(request.getParameter("isActive"));

            if (vdao.isSkuDuplicate(sku, id)) {
                session.setAttribute("msg", "Error: SKU is already used!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect("variantServlet?action=edit&id=" + id);
                return;
            }

            ProductVariant v = new ProductVariant(id, productId, sku, price, isActive);
            vdao.updateVariant(v);

            // Update variant_spec_values: xóa cũ, insert mới
            VariantSpecValueDAO vsUpdateDao = new VariantSpecValueDAO();
            vsUpdateDao.deleteByVariantId(id);

            // Lấy tất cả params có tên bắt đầu bằng "specValue_"
            java.util.Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                if (paramName.startsWith("specValue_")) {
                    String specIdStr = paramName.substring("specValue_".length());
                    String specValue = request.getParameter(paramName);
                    if (specValue != null && !specValue.trim().isEmpty()) {
                        try {
                            int specId = Integer.parseInt(specIdStr);
                            vsUpdateDao.insertVariantSpec(id, specId, specValue.trim());
                        } catch (NumberFormatException ex) {
                            // skip invalid spec id
                        }
                    }
                }
            }

            session.setAttribute("msg", "Variant updated successfully!");
            session.setAttribute("msgType", "success");

        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("variantId"));
            if (vdao.countInventoryByVariantId(id) > 0) {
                vdao.softDeleteVariant(id);
                session.setAttribute("msg", "Variant has stock. Set to INACTIVE.");
            } else {
                vdao.deleteVariant(id);
                session.setAttribute("msg", "Variant deleted successfully!");
            }
            session.setAttribute("msgType", "success");
        }

        response.sendRedirect("variantServlet?action=all");
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
