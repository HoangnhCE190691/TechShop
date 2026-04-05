package controller.User;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.ProductDAO;
import dao.CategoryDAO;
import dao.BrandDAO;
import model.Product;
import model.Category;
import model.Brand;
import java.util.List;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "productpageServlet", urlPatterns = {"/productpageservlet"})
public class productpageServlet extends HttpServlet {

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
            out.println("<title>Servlet productpageServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet productpageServlet at " + request.getContextPath() + "</h1>");
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
        // 1. Khởi tạo các thành phần giao diện mặc định 
        String headerComponent = "/components/navbar.jsp";
        String footerComponent = "/components/footer.jsp";
        String page = "/pages/MainPage/productPage.jsp";

        // 2. Lấy các tham số lọc từ Request 
        String keyword = request.getParameter("keyword");
        String categoryIdParam = request.getParameter("categoryId");
        String brandIdParam = request.getParameter("brandId");
        String priceRange = request.getParameter("priceRange");
        String sortOrder = request.getParameter("sortOrder");

        // Lấy tham số phân trang 
        int pageSize = 9;
        String pageParam = request.getParameter("page");
        int pageIndex = (pageParam == null || pageParam.isEmpty()) ? 1 : Integer.parseInt(pageParam);

        Integer categoryId = null;
        Integer brandId = null;
        Double minPrice = null;
        Double maxPrice = null;

        try {
            if (categoryIdParam != null && !categoryIdParam.trim().isEmpty()) {
                categoryId = Integer.parseInt(categoryIdParam);
            }
            if (brandIdParam != null && !brandIdParam.trim().isEmpty()) {
                brandId = Integer.parseInt(brandIdParam);
            }

            if (priceRange != null) {
                switch (priceRange) {
                    case "under5":
                        maxPrice = 5000000.0;
                        break;
                    case "5to10":
                        minPrice = 5000000.0;
                        maxPrice = 10000000.0;
                        break;
                    case "15to25":
                        minPrice = 15000000.0;
                        maxPrice = 25000000.0;
                        break;
                    case "over25":
                        minPrice = 25000000.0;
                        break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        ProductDAO pdao = new ProductDAO();

        int totalProducts = pdao.getTotalFilteredProducts(keyword, categoryId, brandId, minPrice, maxPrice);
        int endPage = (int) Math.ceil((double) totalProducts / pageSize);

        List<Product> productList = pdao.getFilteredProductsWithPaging(
                keyword, categoryId, brandId, minPrice, maxPrice, sortOrder, pageIndex, pageSize);

        dao.CategoryDAO cdao = new dao.CategoryDAO();
        dao.BrandDAO bdao = new dao.BrandDAO();

        request.setAttribute("categoryList", cdao.getAllActiveCategories());
        request.setAttribute("brandList", bdao.getAllActiveBrands());
        request.setAttribute("productList", productList);

        request.setAttribute("endP", endPage);
        request.setAttribute("tag", pageIndex);

        request.setAttribute("keyword", keyword);
        request.setAttribute("categoryId", categoryId);
        request.setAttribute("brandId", brandId);
        request.setAttribute("priceRange", priceRange);
        request.setAttribute("sortOrder", sortOrder);

        request.setAttribute("HeaderComponent", headerComponent);
        request.setAttribute("FooterComponent", footerComponent);
        request.setAttribute("ContentPage", page);

        // 7. Forward đến Template người dùng 
        request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);
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

}
