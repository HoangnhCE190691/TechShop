/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.admin;

import dao.CustomerDAO;
import dao.EmployeesDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.Customer;
import model.CustomerAddress;
import model.Employees;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "profileEmployee", urlPatterns = {"/profileemployee"})
public class profileEmployee extends HttpServlet {

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
            out.println("<title>Servlet profileEmployee</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet profileEmployee at " + request.getContextPath() + "</h1>");
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
        String action = request.getParameter("action");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
// 1. Tránh NullPointerException cho biến action
        if (action == null) {
            action = "";
        }

// 2. Lấy ID từ Cookie an toàn
        int currentUserId = -1;
        jakarta.servlet.http.Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (jakarta.servlet.http.Cookie cookie : cookies) {
                if ("cookieID".equals(cookie.getName())) {
                    try {
                        // Đề phòng user cố tình sửa cookie thành chữ
                        currentUserId = Integer.parseInt(cookie.getValue());
                    } catch (NumberFormatException ex) {
                        currentUserId = -1;
                    }
                    break;
                }
            }
        }

// 3. Nếu không thấy Cookie hợp lệ, đá về Login
        if (currentUserId == -1) {
            response.sendRedirect("userservlet?action=loginPage");
            return;
        }

// 4. Lấy thông tin Employee
        EmployeesDAO edao = new EmployeesDAO();
        Employees e = edao.getEmployeeById(currentUserId);

// Bổ sung: Nếu ID trong cookie không tồn tại trong DB (user đã bị xóa) -> Bắt đăng nhập lại
        if (e == null) {
            response.sendRedirect("userservlet?action=loginPage");
            return;
        }

// 5. Khởi tạo biến page mặc định
        String page = "/pages/DashboardPage/profileEmployee.jsp";

// 6. Điều hướng giao diện
        switch (action) {
            case "edit":
                page = "/pages/ProfileManagementPage/changeProfile.jsp";
                break;
            case "changepassword":
                page = "/pages/ProfileManagementPage/changePassword.jsp";
                break;
            default: // Trang dashboard chính
                break; // Không cần set lại page vì đã có mặc định ở trên
        }

// 7. Truyền data và forward (Chỉ cần set attribute 1 lần ở đây)
        request.setAttribute("employee", e);
        request.setAttribute("contentPage", page);
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
        EmployeesDAO edao = new EmployeesDAO();

// 1. Lấy UserId từ Cookie (Đã bọc try-catch an toàn)
        int currentUserId = -1;
        jakarta.servlet.http.Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (jakarta.servlet.http.Cookie c : cookies) {
                if ("cookieID".equals(c.getName())) {
                    try {
                        currentUserId = Integer.parseInt(c.getValue());
                    } catch (NumberFormatException e) {
                        currentUserId = -1;
                    }
                    break;
                }
            }
        }

// Kiểm tra bảo mật cơ bản
        if (currentUserId == -1) {
            response.sendRedirect("employeeservlet?action=loginPage");
            return;
        }

// 2. Xử lý tập trung bằng Switch Case
        if (action == null) {
            action = ""; // Tránh NullPointerException cho switch
        }

        Employees currentEmp = edao.getEmployeeById(currentUserId);
        if (currentEmp == null) {
            response.sendRedirect("employeeservlet?action=loginPage");
            return;
        }

        switch (action) {
            case "edit":
                // 1. Lấy dữ liệu từ form
                String newFullname = request.getParameter("fullName");
                String newEmail = request.getParameter("email");
                String newPhone = request.getParameter("phoneNumber");

                // 2. Kiểm tra lỗi ngay lập tức
                String errorGmail = utils.IO.checkDuplicationGmailInEdit(newEmail, currentEmp.getEmail()) ? "" : "Gmail already exists";
                String errorPhone = utils.IO.CheckNumber(newPhone) ? "" : "Invalid phone (10 digits required)";

                // 3. Set dữ liệu mới vào Object để giữ trạng thái cho form
                // Sửa thành setFullName() chữ N viết hoa cho khớp Model của bạn
                currentEmp.setFullName(newFullname);
                currentEmp.setEmail(newEmail);
                currentEmp.setPhoneNumber(newPhone);

                // 4. CHỈ LƯU DATABASE KHI KHÔNG CÓ LỖI NÀO
                if (errorGmail.isEmpty() && errorPhone.isEmpty()) {
                    // LƯU Ý: Bạn cần tạo hàm updateEmployeeNoPassword trong EmployeesDAO nhé!
                    boolean successUpdate = edao.updateEmployeeNoPassword(currentEmp);

                    if (successUpdate) {
                        response.sendRedirect("profileemployee");
                        return; // Chuyển trang xong thì dừng luôn
                    }
                }

                // 5. Rớt xuống đây nghĩa là CÓ LỖI hoặc UPDATE DB THẤT BẠI
                request.setAttribute("errorGmail", errorGmail);
                request.setAttribute("errorPhone", errorPhone);
                request.setAttribute("employee", currentEmp);
              
                // Nhớ check lại đường dẫn file JSP edit của Employee nhé
                request.setAttribute("contentPage", "/pages/ProfileManagementPage/changeProfile.jsp");

                request.getRequestDispatcher("/template/adminTemplate.jsp").forward(request, response);
                return;

            case "changePassword":
                String oldPass = request.getParameter("oldPassword");
                String newPass = request.getParameter("newPassword");
                String confirmPass = request.getParameter("confirmPassword");

                String errorNewPass = "";
                if (!newPass.equals(confirmPass)) {
                    errorNewPass = "New password and confirmation do not match!";
                }

                // Đảm bảo hàm hashMD5 tồn tại trong EmployeesDAO
                String hashedOldPass = edao.hashMD5(oldPass);
                String errorOldPass = "";

                // Sửa getPassword() thành getPasswordHash() cho khớp với Model Employees
                if (!hashedOldPass.equals(currentEmp.getPasswordHash())) {
                    errorOldPass = "Incorrect current password!";
                }

                // Nếu không có lỗi nào
                if (errorNewPass.isEmpty() && errorOldPass.isEmpty()) {
                    // LƯU Ý: Bạn cần tạo hàm changePassword trong EmployeesDAO
                    boolean success = edao.changePassword(currentUserId, newPass);

                    if (success) {
                        response.sendRedirect("profileemployee");
                    } else {
                        response.sendRedirect("profileemployee?action=changepassword");
                    }
                } else {
                    request.setAttribute("errorNewPass", errorNewPass);
                    request.setAttribute("errorOldPass", errorOldPass);

                    // Nhớ check lại đường dẫn file JSP đổi pass của Employee nhé
                    request.setAttribute("contentPage", "/pages/ProfileManagementPage/changePassword.jsp");

                    request.getRequestDispatcher("/template/adminTemplate.jsp").forward(request, response);
                }
                return;

            default:
                response.sendRedirect("employeedashboardservlet");
                break;
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
