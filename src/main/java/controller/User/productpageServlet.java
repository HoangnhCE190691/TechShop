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
        String headerComponent = "/components/navbar.jsp"; // Trang mặc định khi mới vào
        String footerComponent = "/components/footer.jsp"; // Trang mặc định khi mới vào
        String page = "/pages/MainPage/productPage.jsp"; // Trang mặc định khi mới vào

        String keyword = request.getParameter("keyword");
        String categoryIdParam = request.getParameter("categoryId");
        String brandIdParam = request.getParameter("brandId");
        String priceRange = request.getParameter("priceRange");

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
        List<Product> productList = pdao.getFilteredProducts(keyword, categoryId, brandId, minPrice, maxPrice);

        dao.CategoryDAO cdao = new dao.CategoryDAO();
        dao.BrandDAO bdao = new dao.BrandDAO();
        request.setAttribute("categoryList", cdao.getAllCategory());
        request.setAttribute("brandList", bdao.getAllBrand());

        request.setAttribute("productList", productList);
        request.setAttribute("keyword", keyword);
        request.setAttribute("categoryId", categoryId); // Để giữ lại state trên UI
        request.setAttribute("brandId", brandId);
        request.setAttribute("priceRange", priceRange);

        request.setAttribute("HeaderComponent", headerComponent);
        request.setAttribute("FooterComponent", footerComponent);
        request.setAttribute("ContentPage", page);

        // 5. Forward đến Template duy nhất
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
