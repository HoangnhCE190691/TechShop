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
@WebServlet(name="verificationForgotPassword", urlPatterns={"/verificationforgotpassword"})
public class verificationForgotPassword extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
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
            out.println("<title>Servlet verificationForgotPassword</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet verificationForgotPassword at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
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
        String page = "/pages/MainPage/verificationForgotPassword.jsp"; // Trang mặc định khi mới vào
        request.setAttribute("HeaderComponent", headerComponent);
        request.setAttribute("FooterComponent", footerComponent);
        request.setAttribute("ContentPage", page);

        // 5. Forward đến Template duy nhất
        request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String otpInput = request.getParameter("otp_input");

        // 2. Lấy dữ liệu đã lưu trong Session
        HttpSession session = request.getSession(false);

        if (session != null) {
            String otpServer = (String) session.getAttribute("code");
//            int idC = (int) session.getAttribute("id");
            // Giả sử Object của bạn tên là Customer hoặc User
         
            // 3. Kiểm tra logic
            if (otpServer != null && otpServer.equals(otpInput)) {
                // THÀNH CÔNG: Mã khớp
                // Xóa dữ liệu tạm trong session sau khi đã dùng xong
                session.removeAttribute("code");
//                session.removeAttribute("id");

                
                // Chuyển hướng đến trang thành công hoặc đăng nhập
                response.sendRedirect("changepasswordforgot");
            } else {
                // THẤT BẠI: Mã sai
                request.setAttribute("mess", "Mã xác thực không chính xác. Vui lòng thử lại!");

                // Giữ lại các thành phần giao diện để forward ngược về trang OTP
                request.setAttribute("HeaderComponent", "/components/navbar.jsp");
                request.setAttribute("FooterComponent", "/components/footer.jsp");
                request.setAttribute("ContentPage", "/pages/MainPage/forgot-password.jsp");
                request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);
            }
        } else {
            // Session đã hết hạn (timeout)
            response.sendRedirect("register.jsp?mess=SessionExpired");
        }
    }

    /**
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
