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
                    page = "/pages/ProductManagementPage/detailProduct.jsp";
                    break;
                case "delete":
                    int idDel = Integer.parseInt(request.getParameter("id"));
                    request.setAttribute("product", pdao.getProductById(idDel));
                    request.setAttribute("orderCount", pdao.countProductInOrderDetails(idDel));
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
            p.setStatus(status);
            p.setCreatedBy((Integer) session.getAttribute("userId"));

            int productId = pdao.insertProduct(p);

            // Handle multiple image upload
            boolean isFirstImage = true;
            for (Part filePart : request.getParts()) {
                if ("productImage".equals(filePart.getName()) && filePart.getSize() > 0) {
                    String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "assest" + File.separator
                            + "img" + File.separator + "product";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdir();
                    }

                    long timestamp = System.currentTimeMillis();
                    fileName = timestamp + "_" + fileName; // Đề phòng trùng lặp tên file
                    String filePath = uploadPath + File.separator + fileName;
                    filePart.write(filePath);

                    ProductImageDAO imgDao = new ProductImageDAO();
                    ProductImage pi = new ProductImage();
                    Product prod = new Product();
                    prod.setProductId(productId);
                    pi.setProduct(prod);
                    pi.setImageUrl("assest/img/product/" + fileName);

                    if (isFirstImage) {
                        pi.setIs_thumbnail((byte) 1);
                        isFirstImage = false;
                    } else {
                        pi.setIs_thumbnail((byte) 0);
                    }
                    imgDao.addProductImage(pi);
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
                    && cur.getBrandId() == brandId && cur.getStatus().equals(status)
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

                String uploadPath = getServletContext().getRealPath("") + File.separator + "assest" + File.separator
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
                        pi.setImageUrl("assest/img/product/" + fileName);

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
            if (pdao.countProductInOrderDetails(id) > 0) {
                pdao.softDeleteProduct(id);
                session.setAttribute("msg", "Product has orders. Set to INACTIVE.");
            } else {
                pdao.deleteProduct(id);
                session.setAttribute("msg", "Product deleted successfully!");
            }
            session.setAttribute("msgType", "success");
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
