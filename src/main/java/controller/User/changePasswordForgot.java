/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.User;

import dao.CustomerDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "changePasswordForgot", urlPatterns = {"/changepasswordforgot"})
public class changePasswordForgot extends HttpServlet {

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
            out.println("<title>Servlet changePasswordForgot</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet changePasswordForgot at " + request.getContextPath() + "</h1>");
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
        String headerComponent = "/components/navbar.jsp"; // Trang mặc định khi mới vào
        String footerComponent = "/components/footer.jsp"; // Trang mặc định khi mới vào

        request.setAttribute("HeaderComponent", headerComponent);
        request.setAttribute("FooterComponent", footerComponent);
        request.setAttribute("ContentPage", "/pages/MainPage/changePasswordWhenForgotPassword.jsp");
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

        String password = request.getParameter("password");
        String passwordConfirm = request.getParameter("confirmPassword");
        CustomerDAO cdao = new CustomerDAO();

        // 1. Kiểm tra mật khẩu khớp nhau (Dùng equals thay vì equalsIgnoreCase để bảo mật case-sensitive)
        if (password != null && password.equals(passwordConfirm)) {
            HttpSession session = request.getSession(false);

            if (session != null && session.getAttribute("id") != null) {
                int idC = (int) session.getAttribute("id");
                Customer c = cdao.getCustomerById(idC);

                if (c != null) {
                    // 2. Hash mật khẩu và update
                   
                    boolean isUpdated = cdao.changePassword(idC,passwordConfirm);

                    if (isUpdated) {
                        // Cập nhật thành công mới xóa session và gửi mail
                        session.removeAttribute("id");

                        try {
                            utils.EmailUtils.sendEmail(c.getEmail(), "TechShop - Password Changed",
                                    "Chào " + c.getUserName() + ", mật khẩu của bạn đã được thay đổi thành công.");
                        } catch (Exception e) {
                            e.printStackTrace(); // Log lỗi gửi mail nhưng đừng chặn người dùng
                        }

                        response.sendRedirect("userservlet?action=loginPage");
                        return;
                    }
                }
            }
            // Nếu rơi xuống đây nghĩa là không tìm thấy Customer hoặc lỗi DB
            request.setAttribute("errorPassword", "Lỗi hệ thống: Không thể xác định người dùng.");
        } else {
            request.setAttribute("errorPassword", "Hai mật khẩu không khớp nhau!");
        }

        // 3. Xử lý khi có lỗi (Forward lại trang cũ)
        request.setAttribute("HeaderComponent", "/components/navbar.jsp");
        request.setAttribute("FooterComponent", "/components/footer.jsp");
        request.setAttribute("ContentPage", "/pages/MainPage/changePasswordWhenForgotPassword.jsp");
        request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);
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
