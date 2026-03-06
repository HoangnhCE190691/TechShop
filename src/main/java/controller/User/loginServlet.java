/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.User;

import dao.CustomerDAO;
import dao.EmployeesDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;
import model.Employees;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "loginServlet", urlPatterns = {"/loginservlet"})
public class loginServlet extends HttpServlet {

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
            out.println("<title>Servlet loginServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet loginServlet at " + request.getContextPath() + "</h1>");
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
        String headerComponent = "/components/navbar.jsp"; // Trang mặc định khi mới vào
        String footerComponent = "/components/footer.jsp"; // Trang mặc định khi mới vào
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        request.setAttribute("HeaderComponent", headerComponent);
        request.setAttribute("FooterComponent", footerComponent);

        // 1. Băm mật khẩu ra MD5 trước khi kiểm tra trong DB
        CustomerDAO Cdao = new CustomerDAO();
        EmployeesDAO Edao = new EmployeesDAO();

        Customer customer = Cdao.login(username, password);
        Employees employee = Edao.login(username, password);

        // 2. SỬA LỖI LOGIC QUAN TRỌNG:
        // Phải dùng && (VÀ). Chỉ khi CẢ 2 đều không tìm thấy thì mới là lỗi.
        if (customer.getCustomerID() == -1 && employee.getEmployeeId() == -1) {

            request.setAttribute("error", "Invalid username or password!");
            // Đăng nhập thất bại
            request.setAttribute("ContentPage", "/pages/MainPage/loginPage.jsp");
            request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);
        } // 3. Trường hợp là Nhân viên (Employee)
        else if (employee.getEmployeeId() != -1) {

            if (!employee.getStatus().equalsIgnoreCase("ACTIVE")) {
                request.setAttribute("error", "Your account has been banned!");
                // Đăng nhập thất bại
                request.setAttribute("ContentPage", "/pages/MainPage/loginPage.jsp");
                request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);
                return;
            }

            // Tạo Cookie cho Employee
            Cookie cookieId = new Cookie("cookieID", String.valueOf(employee.getEmployeeId()));
            Cookie cookieUser = new Cookie("cookieUser", employee.getUsername());
            Cookie cookieRole = new Cookie("cookieRole", employee.getRole().getRole_name()); // Lưu thêm role để dễ phân biệt

            // Set thời gian sống (ví dụ 1 tiếng)
            cookieId.setMaxAge(60 * 60);
            cookieUser.setMaxAge(60 * 60);
            cookieRole.setMaxAge(60 * 60);

            // Đẩy Cookie về trình duyệt
            response.addCookie(cookieId);
            response.addCookie(cookieUser);
            response.addCookie(cookieRole);

            // Điều hướng dựa trên ID (Logic cũ của bạn)
            switch (employee.getRole().getRole_id()) {
                case 1:
                    response.sendRedirect("adminservlet");
                    break;
                case 2:
                    response.sendRedirect("staffservlet");
                    break;
                default:
                    response.sendRedirect("homeservlet"); // Trang mặc định cho nhân viên khác
                    break;
            }
        } // 4. Trường hợp là Khách hàng (Customer)
        else {
            // Tạo Cookie cho Customer
            
            if (!customer.getStatus().equalsIgnoreCase("ACTIVE")) {
                request.setAttribute("error", "Your account has been banned!");
                // Đăng nhập thất bại
                request.setAttribute("ContentPage", "/pages/MainPage/loginPage.jsp");
                request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);
                return;
            }

            
            
            Cookie cookieId = new Cookie("cookieID", String.valueOf(customer.getCustomerID()));
            Cookie cookieUser = new Cookie("cookieUser", customer.getUserName()); // Lưu ý: userName không được có dấu cách hoặc ký tự lạ
            Cookie cookieRole = new Cookie("cookieRole", "customer");

            cookieId.setMaxAge(60 * 60);
            cookieUser.setMaxAge(60 * 60);
            cookieRole.setMaxAge(60 * 60);

            response.addCookie(cookieId);
            response.addCookie(cookieUser);
            response.addCookie(cookieRole);

            response.sendRedirect("userservlet?action=homePage");

        }

//        if (Customer.getCustomerID() == -1 && Employee.getEmployeeId() == -1) {
//            response.sendRedirect("login");
//        } else {
//            Cookie cookieId = new Cookie("id", Customer.getCustomerID() + "");
//            cookieId.setMaxAge(60 * 60);
//            response.addCookie(cookieId);
//
//            Cookie cookieUsername = new Cookie("username", Customer.getUserName() + "");
//            cookieUsername.setMaxAge(60 * 60);
//            response.addCookie(cookieUsername);
//
//            response.sendRedirect("userservlet");
//        }
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
