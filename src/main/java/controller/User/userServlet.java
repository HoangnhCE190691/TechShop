/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.User;

import dao.CustomerAddressDAO;
import dao.CustomerDAO;
import dao.ProductDAO;
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
@WebServlet(name = "userServlet", urlPatterns = {"/userservlet"})
public class userServlet extends HttpServlet {

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
            out.println("<title>Servlet userServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet userServlet at " + request.getContextPath() + "</h1>");
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
        String page = "/pages/MainPage/homePage.jsp"; // Trang mặc định khi mới vào
        String action = request.getParameter("action");

        if (action != null) {
            switch (action) {
                case "homePage":
                    page = "/pages/MainPage/homePage.jsp";
                    ProductDAO productDAO = new ProductDAO();
                    request.setAttribute("phoneList", productDAO.getProductsByCategoryId(1, 10));
                    request.setAttribute("computerList", productDAO.getProductsByCategoryId(2, 10));
                    request.setAttribute("accessoryList", productDAO.getProductsByCategoryId(3, 10));
                    request.setAttribute("laptopList", productDAO.getProductsByCategoryId(4, 10));
                    request.setAttribute("appleList", productDAO.getProductsByBrandId(1, 10));
                    request.setAttribute("samsungList", productDAO.getProductsByBrandId(2, 10));

                    break;
                case "loginPage":
                    page = "/pages/MainPage/loginPage.jsp"; // Bạn cần tạo file này
                    break;
                case "registerPage":
                    page = "/pages/MainPage/registerPage.jsp"; // Bạn cần tạo file này
                    break;
                case "userDashboard":
                    page = "/pages/DashboardPage/userDashboard.jsp";
                    int customerID = Integer.parseInt(request.getParameter("id"));
                    CustomerDAO cdao = new CustomerDAO();
                    CustomerAddressDAO cadd = new CustomerAddressDAO();
                    List<CustomerAddress> listdata = cadd.getAddressesByCustomerId(customerID);
                    Customer customer = cdao.getCustomerById(customerID);
                    request.setAttribute("customer", customer);
                    request.setAttribute("listAddress", listdata);
                    break;
                default:
                    page = "/pages/dashboardPage.jsp";
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
