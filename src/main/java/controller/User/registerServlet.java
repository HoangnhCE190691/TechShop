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
import model.Customer;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "registerServlet", urlPatterns = {"/registerservlet"})
public class registerServlet extends HttpServlet {

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
            out.println("<title>Servlet registerServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet registerServlet at " + request.getContextPath() + "</h1>");
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
        processRequest(request, response);
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
        // 1. Set Encoding để nhận tiếng Việt không bị lỗi font
        CustomerDAO cdao = new CustomerDAO();
        request.setCharacterEncoding("UTF-8");
     
        
        
        try {
            // 2. Lấy dữ liệu từ Form (dựa theo thuộc tính name="")
            String username = request.getParameter("username");
            String fullName = request.getParameter("full_name");
            String phone = request.getParameter("phone_number");
            String email = request.getParameter("email");
            String password = request.getParameter("password");

            String errorUsername = utils.IO.CheckDuplicationUsername(username) ? "" : "Username already exists!";
            String errorNumber = utils.IO.CheckNumber(phone) ? "" : "Invalid phone (10 digits required)";
            String errorEmail = utils.IO.checkDuplicationGmail(email) ? "" : "Gmail already exists";

            // 5. Tạo đối tượng User mới
            Customer u = new Customer();
            u.setUserName(username);
            u.setFullname(fullName);
            u.setPhoneNumber(phone);
            u.setEmail(email);
            u.setPassword(password); // Thực tế nên mã hóa MD5/BCrypt trước khi set

            // --- CÁC GIÁ TRỊ HỆ THỐNG TỰ GÁN CHO KHÁCH HÀNG ---
            u.setStatus("ACTIVE"); // Mặc định tài khoản kích hoạt luôn

            // 6. Lưu vào Database
            boolean isSuccess = cdao.addCustomer(u);

            if (errorUsername.isEmpty() && errorNumber.isEmpty() && errorEmail.isEmpty() && isSuccess) {
                
                
                
                response.sendRedirect("userservlet?action=loginPage");
            } else {
                request.setAttribute("errorUsername", errorUsername);
                request.setAttribute("errorPhone", errorNumber);
                request.setAttribute("errorEmail", errorEmail);

                request.setAttribute("oldUsername", username);
                request.setAttribute("oldFullName", fullName);
                request.setAttribute("oldEmail", email);
                request.setAttribute("oldPhone", phone);
                request.setAttribute("oldPassword", password);

                String headerComponent = "/components/navbar.jsp"; // Trang mặc định khi mới vào
                String footerComponent = "/components/footer.jsp"; // Trang mặc định khi mới vào

                request.setAttribute("HeaderComponent", headerComponent);
                request.setAttribute("FooterComponent", footerComponent);
                request.setAttribute("ContentPage", "/pages/MainPage/registerPage.jsp");

                // 5. Forward đến Template duy nhất
                request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);

            }

        } catch (Exception e) {
            e.printStackTrace();
            // Điều hướng trang lỗi
            response.sendRedirect("error.jsp");
        }
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
