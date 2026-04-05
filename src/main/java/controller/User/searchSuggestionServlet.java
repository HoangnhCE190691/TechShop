package controller.User;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import dao.ProductDAO;
import model.Product;

@WebServlet(name = "SearchSuggestionServlet", urlPatterns = {"/searchSuggestionServlet"})
public class searchSuggestionServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String keyword = request.getParameter("keyword");

        if (keyword != null && !keyword.trim().isEmpty()) {
            ProductDAO pdao = new ProductDAO();

            List<Product> list = pdao.getFilteredProductsWithPaging(keyword, null, null, null, null, null, 1, 10);

            if (list.size() > 5) {
                list = list.subList(0, 5);
            }

            request.setAttribute("suggestList", list);
            request.setAttribute("searchKeyword", keyword);

            request.getRequestDispatcher("/pages/MainPage/searchSuggestion.jsp").forward(request, response);
        } else {
            response.getWriter().write("");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}
