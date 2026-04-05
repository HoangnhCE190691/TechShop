package controller.User;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.ReviewDAO;
import model.Review;

@WebServlet(name = "ReviewServlet", urlPatterns = { "/reviewservlet" })
public class reviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String action = request.getParameter("action");
        String productIdStr = request.getParameter("productId");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");

        int productId = 0;
        int rating = 5; // default
        try {
            if (productIdStr != null)
                productId = Integer.parseInt(productIdStr);
            if (ratingStr != null)
                rating = Integer.parseInt(ratingStr);
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        // 1. Kiểm tra đăng nhập
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

        // Nếu chưa đăng nhập, quay lại trang sp
        if (customerId == -1) {
            response.sendRedirect("detailservlet?productId=" + productId);
            return;
        }

        ReviewDAO reviewDAO = new ReviewDAO();

        if ("add".equals(action)) {
            // Kiểm tra lại có quyền review không
            int orderItemId = reviewDAO.getUnreviewedOrderItemId(customerId, productId);
            if (orderItemId != -1) {
                Review r = new Review();
                r.setCustomerId(customerId);
                r.setOrderItemId(orderItemId);
                r.setRating(rating);
                r.setComment(comment);
                reviewDAO.addReview(r);
            }
        } else if ("edit".equals(action)) {
            String reviewIdStr = request.getParameter("reviewId");
            if (reviewIdStr != null) {
                int reviewId = Integer.parseInt(reviewIdStr);
                Review existingReview = reviewDAO.getReviewByCustomerAndProduct(customerId, productId);

                // Đảm bảo review tồn tại và thuộc về user
                if (existingReview != null && existingReview.getReviewId() == reviewId) {
                    Review r = new Review();
                    r.setReviewId(reviewId);
                    r.setCustomerId(customerId);
                    r.setRating(rating);
                    r.setComment(comment);
                    reviewDAO.updateReview(r);
                }
            }
        }
        response.sendRedirect("detailservlet?productId=" + productId);
    }
}
