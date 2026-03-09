/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.User;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.ProductDAO;
import dao.ProductImageDAO;
import dao.ProductVariantDAO;
import dao.ProductSpecificationValueDAO;
import dao.VariantSpecValueDAO;
import jakarta.servlet.http.HttpServlet;
import model.Product;
import model.ProductImage;
import model.ProductVariant;
import model.ProductSpecificationValues;
import model.VariantSpecValue;
import model.Review;
import dao.ReviewDAO;
import java.util.List;
import jakarta.servlet.http.Cookie;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "detailServlet", urlPatterns = { "/detailservlet" })
public class detailServlet extends HttpServlet {

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
            out.println("<title>Servlet detailServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet detailServlet at " + request.getContextPath() + "</h1>");
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
        String headerComponent = "/components/navbar.jsp"; // Trang mặc định khi mới vào
        String footerComponent = "/components/footer.jsp"; // Trang mặc định khi mới vào
        String page = "/pages/MainPage/detailPage.jsp"; // Trang mặc định khi mới vào

        String idParam = request.getParameter("productId");
        if (idParam != null && !idParam.isEmpty()) {
            try {
                int productId = Integer.parseInt(idParam);

                ProductDAO pDao = new ProductDAO();
                Product p = pDao.getProductById(productId);

                ProductImageDAO imgDao = new ProductImageDAO();
                List<ProductImage> images = imgDao.getImagesByProductId(productId);

                ProductVariantDAO variantDao = new ProductVariantDAO();
                List<ProductVariant> variants = variantDao.getVariantsByProductId(productId);

                ProductSpecificationValueDAO specDao = new ProductSpecificationValueDAO();
                List<ProductSpecificationValues> specs = specDao.getSpecsByProductId(productId);

                VariantSpecValueDAO varSpecDao = new VariantSpecValueDAO();
                List<VariantSpecValue> variantSpecs = varSpecDao.getSpecsByProductId(productId);

                // Fetch reviews
                ReviewDAO reviewDao = new ReviewDAO();
                List<Review> productReviews = reviewDao.getReviewsByProductId(productId);

                // Calculate statistics
                int totalReviews = productReviews.size();
                double averageRating = 0;
                int[] starCounts = new int[6]; // index 1 to 5

                for (Review r : productReviews) {
                    averageRating += r.getRating();
                    if (r.getRating() >= 1 && r.getRating() <= 5) {
                        starCounts[r.getRating()]++;
                    }
                }

                if (totalReviews > 0) {
                    averageRating = averageRating / totalReviews;
                }

                int[] starPercentages = new int[6];
                for (int i = 1; i <= 5; i++) {
                    if (totalReviews > 0) {
                        starPercentages[i] = (int) Math.round(((double) starCounts[i] / totalReviews) * 100);
                    }
                }

                // Check user login and review eligibility
                int customerId = -1;
                Cookie[] cookies = request.getCookies();
                if (cookies != null) {
                    for (Cookie c : cookies) {
                        if (c.getName().equals("cookieID")) {
                            customerId = Integer.parseInt(c.getValue());
                            break;
                        }
                    }
                }

                Review userReview = null;
                boolean canReview = false;

                if (customerId != -1) {
                    // check if the user already reviewed
                    userReview = reviewDao.getReviewByCustomerAndProduct(customerId, productId);

                    if (userReview == null) {
                        // check if the user bought and hasn't reviewed
                        canReview = reviewDao.getUnreviewedOrderItemId(customerId, productId) != -1;
                    }
                }

                request.setAttribute("product", p);
                request.setAttribute("images", images);
                request.setAttribute("variants", variants);
                request.setAttribute("specs", specs);
                request.setAttribute("variantSpecs", variantSpecs);

                request.setAttribute("productReviews", productReviews);
                request.setAttribute("totalReviews", totalReviews);
                request.setAttribute("averageRating", averageRating);
                request.setAttribute("starCounts", starCounts);
                request.setAttribute("starPercentages", starPercentages);
                request.setAttribute("userReview", userReview);
                request.setAttribute("canReview", canReview);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.setAttribute("HeaderComponent", headerComponent);
        request.setAttribute("FooterComponent", footerComponent);
        request.setAttribute("ContentPage", page);

        // 5. Forward đến Template duy nhất
        request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);
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
