package controller.admin;

import dao.BrandDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.util.List;
import model.Brand;

/**
 *
 * @author CaoTram
 */
@WebServlet(name = "brandServlet", urlPatterns = {"/brandServlet"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB (tối đa 1 file)
        maxRequestSize = 1024 * 1024 * 50 // 50MB (tối đa cả request)
)
public class brandServlet extends HttpServlet {

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
            out.println("<title>Servlet categoryServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet categoryServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }
    private static final String UPLOAD_DIR = "assets/img/brands";

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
        String page = "/pages/BrandManagementPage/brandManagement.jsp";
        List<?> listData = null;
        BrandDAO bdao = new BrandDAO();

        if (action != null) {
            switch (action) {
                case "add":
                    page = "/pages/BrandManagementPage/addBrand.jsp";
                    break;
                case "delete":
                    int idDel = Integer.parseInt(request.getParameter("id"));
                    Brand brand = bdao.getBrandById(idDel);
                    int pCount = bdao.countProductsByBrandId(idDel);
                    request.setAttribute("brand", brand);
                    request.setAttribute("productCount", pCount);
                    page = "/pages/BrandManagementPage/deleteBrand.jsp";
                    break;
                case "edit":
                    int idEdit = Integer.parseInt(request.getParameter("id"));
                    Brand b = bdao.getBrandById(idEdit);
                    request.setAttribute("brand", b);
                    page = "/pages/BrandManagementPage/editBrand.jsp";
                    break;
                case "detail":
                    int idDetail = Integer.parseInt(request.getParameter("id"));
                    Brand brandDetail = bdao.getBrandById(idDetail);
                    int productCount = bdao.countProductsByBrandId(idDetail);
                    request.setAttribute("brand", brandDetail);
                    request.setAttribute("productCount", productCount);
                    page = "/pages/BrandManagementPage/detailBrand.jsp";
                    break;
                case "all":
                    page = "/pages/BrandManagementPage/brandManagement.jsp";
                    listData = bdao.getAllBrand();
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
        BrandDAO bdao = new BrandDAO();
        HttpSession session = request.getSession();

        if ("add".equals(action) || "update".equals(action)) {
            String name = request.getParameter("brandName").trim();
            // Lấy trạng thái từ radio button (1 là true, 0 là false)
            boolean status = "1".equals(request.getParameter("isActive"));

            // 1. XỬ LÝ FILE UPLOAD
            Part filePart = request.getPart("brandLogo");
            String imagePath = null;

            // Chỉ xử lý nếu người dùng thực sự chọn file
            if (filePart != null && filePart.getSize() > 0) {
                // Lấy tên file gốc (Ví dụ: apple-logo.png)
                String originalFileName = java.nio.file.Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

                // Tạo tên file duy nhất: Timestamp + Tên file gốc để giữ chữ "-logo"
                String finalFileName = System.currentTimeMillis() + "_" + originalFileName;

                // Thiết lập đường dẫn lưu trữ trong server (thư mục assets/img/brands)
                String deployPath = request.getServletContext().getRealPath("") + java.io.File.separator + "assets/img/brands";
                java.io.File uploadDir = new java.io.File(deployPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                // Ghi file vật lý vào thư mục
                filePart.write(deployPath + java.io.File.separator + finalFileName);

                // Lưu đường dẫn tương đối vào database
                imagePath = "assets/img/brands/" + finalFileName;
            }

            // 2. XỬ LÝ LƯU VÀO DATABASE
            if ("add".equals(action)) {
                // Kiểm tra trùng tên trước khi thêm mới
                if (bdao.isBrandNameExists(name)) {
                    session.setAttribute("msg", "Error: Brand name '" + name + "' already exists!");
                    session.setAttribute("msgType", "danger");
                    response.sendRedirect("brandServlet?action=add");
                    return;
                }
                bdao.insertBrand(name, imagePath, status);
                session.setAttribute("msg", "Brand '" + name + "' added successfully!");

            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("brandId"));

                // Kiểm tra trùng tên (loại trừ ID của chính mình)
                if (bdao.isBrandNameExists(name, id)) {
                    session.setAttribute("msg", "Error: Name '" + name + "' is used by another brand!");
                    session.setAttribute("msgType", "danger");
                    response.sendRedirect("brandServlet?action=edit&id=" + id);
                    return;
                }

                // Nếu không upload ảnh mới, giữ lại đường dẫn ảnh cũ từ DB
                if (imagePath == null) {
                    model.Brand current = bdao.getBrandById(id);
                    imagePath = (current != null) ? current.getImageUrl() : null;
                }

                model.Brand b = new model.Brand(id, name, imagePath, status);
                bdao.updateBrand(b);
                session.setAttribute("msg", "Brand '" + name + "' updated successfully!");
            }
            session.setAttribute("msgType", "success");

        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("brandId"));
            // Nếu thương hiệu đã có sản phẩm, chỉ cho phép ẩn (Deactivate)
            if (bdao.countProductsByBrandId(id) > 0) {
                bdao.deactivateBrand(id);
                session.setAttribute("msg", "Brand contains products. Switched to INACTIVE.");
            } else {
                bdao.deleteBrand(id);
                session.setAttribute("msg", "Brand deleted successfully!");
            }
            session.setAttribute("msgType", "success");
        }

        // Sau khi xử lý xong, quay lại danh sách quản lý
        response.sendRedirect("brandServlet?action=all");
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
