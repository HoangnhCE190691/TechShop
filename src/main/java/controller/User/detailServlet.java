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
import jakarta.servlet.http.HttpServlet;
import model.Product;
import model.ProductImage;
import model.ProductVariant;
import model.ProductSpecificationValues;
import java.util.List;

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

                request.setAttribute("product", p);
                request.setAttribute("images", images);
                request.setAttribute("variants", variants);
                request.setAttribute("specs", specs);

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
