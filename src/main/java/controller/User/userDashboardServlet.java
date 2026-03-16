/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.User;

import dao.CustomerAddressDAO;
import dao.CustomerDAO;
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

/**
 *
 * @author ASUS
 */
@WebServlet(name = "userDashboardServlet", urlPatterns = {"/userdashboardservlet"})
public class userDashboardServlet extends HttpServlet {

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
            out.println("<title>Servlet userDashboardServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet userDashboardServlet at " + request.getContextPath() + "</h1>");
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

        // 1. Lấy action và gán giá trị mặc định nếu null
        String action = request.getParameter("action");
        if (action == null) {
            action = "view"; // Nên đổi thành "view" cho rõ nghĩa
        }

        // 2. Lấy ID từ Cookie
        int currentUserId = -1;
        jakarta.servlet.http.Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (jakarta.servlet.http.Cookie cookie : cookies) {
                if (cookie.getName().equals("cookieID")) {
                    currentUserId = Integer.parseInt(cookie.getValue());
                    break;
                }
            }
        }

        // Nếu không thấy Cookie, đá về Login, đừng để chạy tiếp
        if (currentUserId == -1) {
            response.sendRedirect("userservlet?action=loginPage");
            return;
        }

        CustomerDAO cdao = new CustomerDAO();
        CustomerAddressDAO cadd = new CustomerAddressDAO();
        Customer customer = cdao.getCustomerById(currentUserId);
        String page = "";

        // 3. Xử lý điều hướng trang
        switch (action) {
            case "edit":
                page = "/pages/MainPage/UserManagement/editUser.jsp";
                request.setAttribute("customer", customer);
                break;
            case "changepassword":
                page = "/pages/MainPage/UserManagement/changePassword.jsp";
                break;
            default: // Trang dashboard chính
                List<CustomerAddress> listdata = cadd.getAddressesByCustomerId(currentUserId);
                request.setAttribute("customer", customer);
                request.setAttribute("listAddress", listdata);
                page = "/pages/DashboardPage/userDashboard.jsp";
                break;
        }

        // 4. Kiểm tra xem page có bị rỗng không trước khi forward
        request.setAttribute("HeaderComponent", "/components/navbar.jsp");
        request.setAttribute("FooterComponent", "/components/footer.jsp");
        request.setAttribute("ContentPage", page);

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
        String action = request.getParameter("action");
        CustomerDAO cdao = new CustomerDAO();

        // 1. Lấy UserId từ Cookie (Làm gọn phần này)
        int currentUserId = -1;
        jakarta.servlet.http.Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (jakarta.servlet.http.Cookie c : cookies) {
                if ("cookieID".equals(c.getName())) {
                    currentUserId = Integer.parseInt(c.getValue());
                    break;
                }
            }
        }

        // Kiểm tra bảo mật cơ bản
        if (currentUserId == -1) {
            response.sendRedirect("userservlet?action=loginPage");
            return;
        }

        // 2. Xử lý tập trung bằng Switch Case
        if (action == null) {
            action = ""; // Tránh NullPointerException cho switch
        }
        Customer currentCust = cdao.getCustomerById(currentUserId);
        switch (action) {
            case "edit":
                // 1. Lấy dữ liệu từ form ra các biến String (CHƯA set vào currentCust vội)
                String newFullname = request.getParameter("fullname");
                String newEmail = request.getParameter("email");
                String newPhone = request.getParameter("phoneNumber");

                // 2. Kiểm tra lỗi ngay lập tức
                // Lúc này currentCust.getEmail() VẪN ĐANG GIỮ EMAIL CŨ trong DB -> Check sẽ chuẩn xác 100%
                String errorGmail = utils.IO.checkDuplicationGmailInEdit(newEmail, currentCust.getEmail()) ? "" : "Gmail already exists";
                String errorPhone = utils.IO.CheckNumber(newPhone) ? "" : "Invalid phone (10 digits required)";

                // 3. Set dữ liệu mới vào Object để giữ trạng thái (Keep state) cho form
                currentCust.setFullname(newFullname);
                currentCust.setEmail(newEmail);
                currentCust.setPhoneNumber(newPhone);

                // 4. CHỈ LƯU DATABASE KHI KHÔNG CÓ LỖI NÀO
                if (errorGmail.isEmpty() && errorPhone.isEmpty()) {
                    boolean SuccessUpdate = cdao.updateCustomerNopassword(currentCust);

                    if (SuccessUpdate) {
                        response.sendRedirect("userdashboardservlet");
                        return; // Chuyển trang xong thì dừng luôn
                    }
                }

                // 5. Rớt xuống đây nghĩa là CÓ LỖI hoặc UPDATE DB THẤT BẠI
                request.setAttribute("errorGmail", errorGmail);
                request.setAttribute("errorPhone", errorPhone);

                request.setAttribute("customer", currentCust); // Đã chứa data mới, JSP sẽ lấy lại được
                request.setAttribute("HeaderComponent", "/components/navbar.jsp");
                request.setAttribute("FooterComponent", "/components/footer.jsp");
                request.setAttribute("ContentPage", "/pages/MainPage/UserManagement/editUser.jsp");

                request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);
                return;
            case "changePassword":
                String oldPass = request.getParameter("oldPassword");
                String newPass = request.getParameter("newPassword");
                String confirmPass = request.getParameter("confirmPassword");

                String errorNewPass = "";
                // Dùng .equals() để bắt buộc phân biệt chữ Hoa/Thường
                if (!newPass.equals(confirmPass)) {
                    errorNewPass = "New password and confirmation do not match!"; // Dịch ra tiếng Việt cho thân thiện với form
                }

                String hashedOldPass = cdao.hashMD5(oldPass);
                String errorOldPass = "";
                // Thêm dấu "!" để check: Nếu KHÔNG GIỐNG thì báo lỗi
                if (!hashedOldPass.equals(currentCust.getPassword())) {
                    errorOldPass = "Incorrect current password!";
                }

                // Nếu không có lỗi nào
                if (errorNewPass.isEmpty() && errorOldPass.isEmpty()) {
                    // LƯU Ý BẢO MẬT CỰC QUAN TRỌNG: 
                    // Nhớ đảm bảo trong hàm cdao.changePassword() bạn ĐÃ MÃ HÓA (MD5) cái newPass này rồi nhé!
                    // Nếu DAO chưa mã hóa, bạn phải tự hash ở đây: cdao.changePassword(currentUserId, cdao.hashMD5(newPass))
                    cdao.changePassword(currentUserId, newPass);
                    response.sendRedirect("userdashboardservlet");

                } else {
                    // Có lỗi -> Báo lỗi trên màn hình
                    request.setAttribute("errorNewPass", errorNewPass);
                    request.setAttribute("errorOldPass", errorOldPass);

                    request.setAttribute("HeaderComponent", "/components/navbar.jsp");
                    request.setAttribute("FooterComponent", "/components/footer.jsp");
                    request.setAttribute("ContentPage", "/pages/MainPage/UserManagement/changePassword.jsp");

                    // DÒNG NÀY RẤT QUAN TRỌNG - KHÔNG CÓ LÀ RA TRANG TRẮNG
                    request.getRequestDispatcher("/template/userTemplate.jsp").forward(request, response);
                }
                return;
            default:
                response.sendRedirect("userdashboardservlet");
                break;
        }
    }

    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response, CustomerDAO cdao, int userId) throws IOException {
        String oldPass = request.getParameter("oldPassword");
        String newPass = request.getParameter("newPassword");
        Customer currentCust = cdao.getCustomerById(userId);

        if (currentCust.getPassword().equals(cdao.hashMD5(oldPass))) {
            if (cdao.changePassword(userId, newPass)) {
                request.getSession().setAttribute("successMessage", "Đổi mật khẩu thành công!");
                response.sendRedirect("userdashboardservlet");
            } else {
                request.getSession().setAttribute("errorMessage", "Lỗi hệ thống!");
                response.sendRedirect("userdashboardservlet?action=changepassword");
            }
        } else {
            request.getSession().setAttribute("errorMessage", "Mật khẩu hiện tại không đúng!");
            response.sendRedirect("userdashboardservlet?action=changepassword");
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
