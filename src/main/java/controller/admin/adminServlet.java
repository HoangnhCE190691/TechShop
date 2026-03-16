/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.admin;

import dao.BrandDAO;
import dao.CategoryDAO;
import dao.CustomerDAO;
import dao.EmployeesDAO;
import dao.OrderStatusDAO;
import dao.PaymentMethodDAO;
import dao.ProductSpecificationValueDAO;
import dao.SpecificationDefinitionDAO;
import dao.VoucherDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.Employees;
import model.Voucher;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "adminServlet", urlPatterns = {"/adminservlet"})
public class adminServlet extends HttpServlet {

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
            out.println("<title>Servlet adminServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet adminServlet at " + request.getContextPath() + "</h1>");
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

        // 1. Thiết lập Tiếng Việt cho cả Request và Response
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 2. Lấy tham số 'action' từ URL (ví dụ: adminservlet?action=dashboard)
        String action = request.getParameter("action");
        String page = "/pages/DashboardPage/adminDashboard.jsp"; // Trang mặc định khi mới vào

        List<?> listData = null; // Dấu <?> cho phép gán bất kỳ List nào (Customer, Employee...)

        if (action == null) {
            action = "";
        }

        // 3. Logic điều hướng (Switch-case sẽ sạch sẽ hơn if-else)
        if (action != null) {
            switch (action) {
                case "dashboard":
                    page = "/pages/DashboardPage/adminDashboard.jsp";

                    request.setAttribute("listDataCustomer", new CustomerDAO().getCustomersByYear(2026));
                    request.setAttribute("listDataEmployee", new EmployeesDAO().getEmployeesByYear(2026));

                    List<Voucher> listV = new VoucherDAO().getVouchersByYear(2026);

                    long activeV = listV.stream().filter(v -> v.getStatus().equalsIgnoreCase("Active")).count();
                    long lockedV = listV.stream().filter(v -> v.getStatus().equalsIgnoreCase("Locked")).count();
                    long expiredV = listV.stream().filter(v -> v.getStatus().equalsIgnoreCase("Expired")).count();

                    request.setAttribute("activeV", activeV);
                    request.setAttribute("lockedV", lockedV);
                    request.setAttribute("expiredV", expiredV);

                    request.setAttribute("listDataVoucher", listV);

                    break;
                case "customerManagement":
                    page = "/pages/CustomerManagementPage/customerManagement.jsp";
                    listData = new CustomerDAO().getAllCustomer();
                    break;
                case "employeeManagement":
                    page = "/pages/EmployeeManagementPage/employeeManagement.jsp";
                    listData = new EmployeesDAO().getAllEmployeeses();
                    break;
                case "categoryManagement":
                    page = "/pages/CategoryManagementPage/categoryManagement.jsp";
                    CategoryDAO cdao = new CategoryDAO();
                    listData = cdao.getAllCategory();
                    break;
                case "brandManagement":
                    page = "/pages/BrandManagementPage/brandManagement.jsp";
                    BrandDAO bdao = new BrandDAO();
                    listData = bdao.getAllBrand();
                    break;

                case "specificationValueManagement":
                    ProductSpecificationValueDAO svdao = new ProductSpecificationValueDAO();
                    listData = svdao.getAllProductSpecs();
                    SpecificationDefinitionDAO specDefDao = new SpecificationDefinitionDAO();
                    request.setAttribute("specs", specDefDao.getAllSpecs());
                    page = "/pages/SpecificationValueManagementPage/specificationValueManagement.jsp";
                    break;
                case "specificationDefinitionManagement":
                    SpecificationDefinitionDAO sdao = new SpecificationDefinitionDAO();
                    CategoryDAO speccdao = new CategoryDAO();
                    request.setAttribute("categories", speccdao.getAllCategory());
                    listData = sdao.getAllSpecs();
                    page = "/pages/SpecificationDefinitionManagementPage/specificationDefinitionManagement.jsp";
                    break;

                case "voucherManagement":
                    page = "/pages/VoucherManagementPage/voucherManagement.jsp";
                    VoucherDAO vdao = new VoucherDAO();
                    listData = vdao.getAllVoucher();
                    break;
                case "paymentMethodManagement":
                    page = "/pages/PaymentMethodManagementPage/paymentMethodManagement.jsp";
                    PaymentMethodDAO pdao = new PaymentMethodDAO();
                    listData = pdao.getAllPaymentMethods();
                    break;
                case "orderStatusManagement":
                    page = "/pages/OrderStatusManagementPage/orderStatusManagement.jsp";
                    OrderStatusDAO osdao = new OrderStatusDAO();
                    listData = osdao.getAllOrderStatuses();
                    break;
                case "searchByMonth":
                    String month = request.getParameter("month");

                    if (Integer.parseInt(month) == -1) {
                        request.setAttribute("listDataCustomer", new CustomerDAO().getCustomersByYear(2026));
                        request.setAttribute("listDataEmployee", new EmployeesDAO().getEmployeesByYear(2026));

                        List<Voucher> listVD = new VoucherDAO().getVouchersByYear(2026);

                        long activeVD = listVD.stream().filter(v -> v.getStatus().equalsIgnoreCase("Active")).count();
                        long lockedVD = listVD.stream().filter(v -> v.getStatus().equalsIgnoreCase("Locked")).count();
                        long expiredVD = listVD.stream().filter(v -> v.getStatus().equalsIgnoreCase("Expired")).count();

                        request.setAttribute("activeV", activeVD);
                        request.setAttribute("lockedV", lockedVD);
                        request.setAttribute("expiredV", expiredVD);

                        request.setAttribute("listDataVoucher", listVD);
                    } else {
                        request.setAttribute("listDataCustomer", new CustomerDAO().getCustomersByMonth(Integer.parseInt(month)));
                        request.setAttribute("listDataEmployee", new EmployeesDAO().getEmployeesByMonth(Integer.parseInt(month)));

                        List<Voucher> listVM = new VoucherDAO().getVouchersByMonth(Integer.parseInt(month));

// Đếm trạng thái Voucher
                        long activeVM = listVM.stream().filter(v -> v.getStatus().equalsIgnoreCase("Active")).count();
                        long lockedVM = listVM.stream().filter(v -> v.getStatus().equalsIgnoreCase("Locked")).count();
                        long expiredVM = listVM.stream().filter(v -> v.getStatus().equalsIgnoreCase("Expired")).count();

// Đếm loại nhân viêns
                        request.setAttribute("activeV", activeVM);
                        request.setAttribute("lockedV", lockedVM);
                        request.setAttribute("expiredV", expiredVM);

// Đẩy dữ liệu sang JSP
                        request.setAttribute("listDataVoucher", listVM);
                    }

                    page = "/pages/DashboardPage/adminDashboard.jsp";

                    break;
                case "searchByYear":
                    page = "/pages/OrderStatusManagementPage/orderStatusManagement.jsp";

                    page = "/pages/DashboardPage/adminDashboard.jsp";
                    break;
                case "profile":
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

                    EmployeesDAO edao = new EmployeesDAO();
                    Employees e = edao.getEmployeeById(currentUserId);

                    page = "/pages/DashboardPage/profileEmployee.jsp";

                    // 4. Kiểm tra xem page có bị rỗng không trước khi forward
                    request.setAttribute("employee", e);
                    break;
                default:

                    request.setAttribute("listDataCustomer", new CustomerDAO().getCustomersByYear(2026));
                    request.setAttribute("listDataEmployee", new EmployeesDAO().getEmployeesByYear(2026));

                    List<Voucher> listVC = new VoucherDAO().getVouchersByYear(2026);

                    long activeVC = listVC.stream().filter(v -> v.getStatus().equalsIgnoreCase("Active")).count();
                    long lockedVC = listVC.stream().filter(v -> v.getStatus().equalsIgnoreCase("Locked")).count();
                    long expiredVC = listVC.stream().filter(v -> v.getStatus().equalsIgnoreCase("Expired")).count();

                    request.setAttribute("activeV", activeVC);
                    request.setAttribute("lockedV", lockedVC);
                    request.setAttribute("expiredV", expiredVC);

                    request.setAttribute("listDataVoucher", listVC);

                    page = "/pages/DashboardPage/adminDashboard.jsp";
            }
        }

        // 4. Đẩy đường dẫn trang con vào Attribute để Template include
        request.setAttribute("contentPage", page);
        request.setAttribute("listdata", listData);

        // 5. Forward đến Template duy nhất
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
