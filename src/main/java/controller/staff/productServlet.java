/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;

import dao.BrandDAO;
import dao.CategoryDAO;
import dao.ProductDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.Product;

import jakarta.servlet.http.Part;
import java.io.File;
import java.nio.file.Paths;
import java.util.Collection;
import dao.ProductImageDAO;
import model.ProductImage;

/**
 *
 * @author CaoTram
 */
@WebServlet(name = "productServlet", urlPatterns = {"/productServlet"})
@jakarta.servlet.annotation.MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2 MB
        maxFileSize = 1024 * 1024 * 10, // 10 MB
        maxRequestSize = 1024 * 1024 * 50 // 50 MB
)
public class productServlet extends HttpServlet {

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
            out.println("<title>Servlet productServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet productServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the
    // + sign on the left to edit the code.">
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
        String page = "/pages/ProductManagementPage/productManagement.jsp";
        List<Product> listData = null;

        ProductDAO pdao = new ProductDAO();
        CategoryDAO cdao = new CategoryDAO();
        BrandDAO bdao = new BrandDAO();

        if (action != null) {
            switch (action) {
                case "add":
                    request.setAttribute("categories", cdao.getAllCategory());
                    request.setAttribute("brands", bdao.getAllBrand());
                    page = "/pages/ProductManagementPage/addProduct.jsp";
                    break;
                case "edit":
                    int idEdit = Integer.parseInt(request.getParameter("id"));
                    request.setAttribute("product", pdao.getProductById(idEdit));
                    request.setAttribute("categories", cdao.getAllCategory());
                    request.setAttribute("brands", bdao.getAllBrand());

                    ProductImageDAO imgDaoEdit = new ProductImageDAO();
                    request.setAttribute("images", imgDaoEdit.getImagesByProductId(idEdit));

                    page = "/pages/ProductManagementPage/editProduct.jsp";
                    break;
                case "detail":
                    int idDetail = Integer.parseInt(request.getParameter("id"));
                    request.setAttribute("product", pdao.getProductById(idDetail));

                    ProductImageDAO imgDaoDetail = new ProductImageDAO();
                    request.setAttribute("images", imgDaoDetail.getImagesByProductId(idDetail));

                    page = "/pages/ProductManagementPage/detailProduct.jsp";
                    break;
                case "delete":
                    int idDel = Integer.parseInt(request.getParameter("id"));
                    request.setAttribute("product", pdao.getProductById(idDel));
                    request.setAttribute("orderCount", pdao.countProductInOrderDetails(idDel));
                    request.setAttribute("inventoryCount", pdao.countProductInInventory(idDel));
                    page = "/pages/ProductManagementPage/deleteProduct.jsp";
                    break;
                case "all":
                    request.setAttribute("categories", cdao.getAllCategory());
                    request.setAttribute("brands", bdao.getAllBrand());
                    listData = pdao.getAllProduct();
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
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        ProductDAO pdao = new ProductDAO();
        HttpSession session = request.getSession();

        if ("add".equals(action)) {
            String name = request.getParameter("name").trim();
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            int brandId = Integer.parseInt(request.getParameter("brandId"));
            String description = request.getParameter("description");
            String status = request.getParameter("status");

            if (pdao.isProductDuplicate(name, categoryId, brandId, 0)) {
                session.setAttribute("msg", "Error: This combination of Name, Category and Brand already exists!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect("productServlet?action=add");
                return;
            }

            Product p = new Product();
            p.setName(name);
            p.setCategoryId(categoryId);
            p.setBrandId(brandId);
            p.setDescription(description);
            p.setStatus("INACTIVE");
            p.setCreatedBy((Integer) session.getAttribute("userId"));

            //  Logic xử lý sau khi insert sản phẩm thành công
            int productId = pdao.insertProduct(p);

// Kiểm tra xem người dùng có thực sự upload ảnh nào không
            boolean hasAnyImage = false;
            for (Part part : request.getParts()) {
                if ("productImage".equals(part.getName()) && part.getSize() > 0) {
                    hasAnyImage = true;
                    break;
                }
            }

            ProductImageDAO imgDao = new ProductImageDAO();

            if (!hasAnyImage) {
                // TRƯỜNG HỢP 1: KHÔNG CÓ ẢNH -> Gán ảnh mặc định 
                ProductImage pi = new ProductImage();
                Product prod = new Product();
                prod.setProductId(productId);
                pi.setProduct(prod);
                // Đảm bảo bạn đã có file này trong thư mục assets/img/product/
                pi.setImageUrl("assets/img/product/default.png");
                pi.setIs_thumbnail((byte) 1);
                imgDao.addProductImage(pi);
            } else {
                // TRƯỜNG HỢP 2: CÓ ẢNH -> Xử lý upload như bình thường 
                boolean isFirstImage = true;
                String uploadPath = getServletContext().getRealPath("") + File.separator + "assets" + File.separator
                        + "img" + File.separator + "product";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs(); // Sửa thành mkdirs() để tạo đầy đủ cây thư mục
                }

                for (Part filePart : request.getParts()) {
                    if ("productImage".equals(filePart.getName()) && filePart.getSize() > 0) {
                        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                        long timestamp = System.currentTimeMillis();
                        fileName = timestamp + "_" + fileName;

                        filePart.write(uploadPath + File.separator + fileName);

                        ProductImage pi = new ProductImage();
                        Product prod = new Product();
                        prod.setProductId(productId);
                        pi.setProduct(prod);
                        pi.setImageUrl("assets/img/product/" + fileName);
                        pi.setIs_thumbnail(isFirstImage ? (byte) 1 : (byte) 0);
                        isFirstImage = false;

                        imgDao.addProductImage(pi);
                    }
                }
            }

            session.setAttribute("msg", "Product added successfully!");
            session.setAttribute("msgType", "success");

        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("productId"));
            String name = request.getParameter("name").trim();
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            int brandId = Integer.parseInt(request.getParameter("brandId"));
            String description = request.getParameter("description");
            String status = request.getParameter("status");

            if (pdao.isProductDuplicate(name, categoryId, brandId, id)) {
                session.setAttribute("msg", "Error: This combination is already used by another product!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect("productServlet?action=edit&id=" + id);
                return;
            }

            // KIỂM TRA THAY ĐỔI
            Product cur = pdao.getProductById(id);
            boolean isImageChanged = false;
            for (Part checkPart : request.getParts()) {
                if ("productImage".equals(checkPart.getName()) && checkPart.getSize() > 0) {
                    isImageChanged = true;
                    break;
                }
            }

            if (!isImageChanged && cur.getName().equals(name) && cur.getCategoryId() == categoryId
                    && cur.getBrandId() == brandId
                    && (cur.getStatus() != null && cur.getStatus().equals(status)) // Kiểm tra null trước
                    && (cur.getDescription() == null ? description == null
                    : cur.getDescription().equals(description))) {

                session.setAttribute("msg", "NO CHANGES DETECTED.");
                session.setAttribute("msgType", "danger");
                response.sendRedirect("productServlet?action=edit&id=" + id);
                return;
            }

            Product p = new Product();
            p.setProductId(id);
            p.setName(name);
            p.setCategoryId(categoryId);
            p.setBrandId(brandId);
            p.setDescription(description);
            p.setStatus(status);
            p.setUpdatedBy((Integer) session.getAttribute("userId"));

            // Handle multiple image upload if a new file is chosen
            boolean hasAnyImageUploaded = false;
            for (Part checkPart : request.getParts()) {
                if ("productImage".equals(checkPart.getName()) && checkPart.getSize() > 0) {
                    hasAnyImageUploaded = true;
                    break;
                }
            }

            pdao.updateProduct(p);

            if (hasAnyImageUploaded) {
                ProductImageDAO imgDao = new ProductImageDAO();

                // Delete all old images for this product inside DB
                List<ProductImage> oldImages = imgDao.getImagesByProductId(id);
                for (ProductImage oldImg : oldImages) {
                    imgDao.deleteProductImage(oldImg.getImageID());
                }

                String uploadPath = getServletContext().getRealPath("") + File.separator + "assets" + File.separator
                        + "img" + File.separator + "product";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdir();
                }

                boolean isFirstImage = true;
                for (Part filePart : request.getParts()) {
                    if ("productImage".equals(filePart.getName()) && filePart.getSize() > 0) {
                        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                        long timestamp = System.currentTimeMillis();
                        fileName = timestamp + "_" + fileName;

                        String filePath = uploadPath + File.separator + fileName;
                        filePart.write(filePath);

                        Product prod = new Product();
                        prod.setProductId(id);
                        ProductImage pi = new ProductImage();
                        pi.setProduct(prod);
                        pi.setImageUrl("assets/img/product/" + fileName);

                        if (isFirstImage) {
                            pi.setIs_thumbnail((byte) 1);
                            isFirstImage = false;
                        } else {
                            pi.setIs_thumbnail((byte) 0);
                        }

                        imgDao.addProductImage(pi);
                    }
                }
                session.setAttribute("msg", "Product and images updated successfully!");
                session.setAttribute("msgType", "success");
            } else {
                session.setAttribute("msg", "Product updated successfully!");
                session.setAttribute("msgType", "success");
            }

        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("productId"));

            // Kiểm tra cả đơn hàng và tồn kho
            int orderCount = pdao.countProductInOrderDetails(id);
            int inventoryCount = pdao.countProductInInventory(id);

            if (orderCount > 0 || inventoryCount > 0) {
                // Nếu đã từng nhập kho hoặc đã bán, chỉ được phép ẨN (Soft Delete)
                pdao.softDeleteProduct(id);

                String reason = (orderCount > 0) ? "sales history" : "inventory records";
                session.setAttribute("msg", "Product has " + reason + ". It has been DEACTIVATED to preserve data.");
                session.setAttribute("msgType", "warning");
            } else {
                // Chỉ xóa vĩnh viễn nếu sản phẩm "sạch" hoàn toàn (vừa tạo xong chưa làm gì)
                boolean isDeleted = pdao.deleteProduct(id);
                if (isDeleted) {
                    session.setAttribute("msg", "Product has been permanently deleted successfully!");
                    session.setAttribute("msgType", "success");
                } else {
                    session.setAttribute("msg", "Error: System constraints prevented deletion.");
                    session.setAttribute("msgType", "danger");
                }
            }
        }
        response.sendRedirect("productServlet?action=all");
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
