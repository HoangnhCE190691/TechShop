/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;

import dao.BrandDAO;
import dao.CategoryDAO;
import dao.InventoryItemDAO;
import dao.ProductDAO;
import dao.SupplierDAO;
import dao.EmployeesDAO;
import dao.OrderDAO;
import dao.ReviewDAO;
import dao.ImportReceiptsDAO;
import dao.ImportReceiptItemDAO;
import model.Order;
import model.ImportReceipts;
import model.ImportReceiptItem;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.InventoryItem;
import model.Supplier;
import java.util.Map;
import model.Employees;
import service.ImportService;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "staffServlet", urlPatterns = {"/staffservlet"})
public class staffServlet extends HttpServlet {

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
            out.println("<title>Servlet staffServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet staffServlet at " + request.getContextPath() + "</h1>");
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
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 2. Lấy tham số 'action' từ URL (ví dụ: adminservlet?action=dashboard)
        String action = request.getParameter("action");
        String page = "/pages/dashboardPage.jsp"; // Trang mặc định khi mới vào
        if (action == null || action.trim().isEmpty()) {
            action = "dashboard";
        }
        List<?> listData = null; // Dấu <?> cho phép gán bất kỳ List nào (Customer, Employee...)
        // 3. Logic điều hướng (Switch-case sẽ sạch sẽ hơn if-else)
        if (action != null) {
            switch (action) {
                case "dashboard":
                    page = "/pages/DashboardPage/dashboardPage.jsp";
                    break;
                // Trong switch (action) của Servlet:

                case "supplierManagement":
                    page = "/pages/SupplierManagementPage/supplierManagement.jsp";
                    try {
                        SupplierDAO sdao = new SupplierDAO();
                        String keyword = request.getParameter("keyword");
                        List<Supplier> listSuppliers = (keyword != null && !keyword.trim().isEmpty())
                                ? sdao.searchSuppliers(keyword) : sdao.getAllSuppliers();
                        request.setAttribute("listSuppliers", listSuppliers != null ? listSuppliers : new java.util.ArrayList<>());
                    } catch (Exception e) {
                        e.printStackTrace();
                        request.setAttribute("listSuppliers", new java.util.ArrayList<>());
                    }
                    break;
                case "inventoryManagement":
                    page = "/pages/InventoryManagementPage/inventoryManagement.jsp";
                    try {
                        InventoryItemDAO idao = new InventoryItemDAO();
                        String keyword = request.getParameter("keyword");
                        List<InventoryItem> listInventory = (keyword != null && !keyword.trim().isEmpty())
                                ? idao.searchInventory(keyword)
                                : idao.getAllInventory();
                        listData = listInventory != null ? listInventory : new java.util.ArrayList<>();
                        request.setAttribute("listInventory", listData);
                    } catch (Exception e) {
                        e.printStackTrace();
                        listData = new java.util.ArrayList<>();
                        request.setAttribute("listInventory", listData);
                    }
                    break;

                case "productManagement":
                    page = "/pages/ProductManagementPage/productManagement.jsp";
                    ProductDAO productdao = new ProductDAO();
                    CategoryDAO ccdao = new CategoryDAO();
                    BrandDAO bdao = new BrandDAO();
                    request.setAttribute("categories", ccdao.getAllCategory());
                    request.setAttribute("brands", bdao.getAllBrand());
                    listData = productdao.getAllProduct();
                    break;
                case "importReceiptItem":
                    page = "/pages/ImportReceiptItemPage/importReceiptItem.jsp";
                    dao.ProductVariantDAO importVariantDao = new dao.ProductVariantDAO();
                    listData = importVariantDao.getAllVariant();
                    break;

                case "inventoryReceiptManagement":
                    page = "/pages/InventoryReceiptManagementPage/inventoryReceiptManagement.jsp";
                    ImportReceiptsDAO rdao = new ImportReceiptsDAO();
                    listData = rdao.getAllReceipts();
                    request.setAttribute("listSuppliers", new SupplierDAO().getAllSuppliers());
                    request.setAttribute("listEmployees", new EmployeesDAO().getAllEmployeeses());
                    break;
                case "inventoryReceiptAdd":
                    page = "/pages/InventoryReceiptManagementPage/addInventoryReceipt.jsp";
                    request.setAttribute("listSuppliers", new SupplierDAO().getAllSuppliers());
                    request.setAttribute("listEmployees", new EmployeesDAO().getAllEmployeeses());
                    break;
                case "inventoryReceiptEdit":
                    int ridEdit = Integer.parseInt(request.getParameter("id"));
                    request.setAttribute("receipt", new ImportReceiptsDAO().getReceiptById(ridEdit));
                    request.setAttribute("listSuppliers", new SupplierDAO().getAllSuppliers());
                    request.setAttribute("listEmployees", new EmployeesDAO().getAllEmployeeses());
                    page = "/pages/InventoryReceiptManagementPage/editInventoryReceipt.jsp";
                    break;
                case "inventoryReceiptDetail":
                    int ridDetail = Integer.parseInt(request.getParameter("id"));
                    ImportReceipts receipt = new ImportReceiptsDAO().getReceiptById(ridDetail);
                    request.setAttribute("receipt", receipt);
                    request.setAttribute("receiptItems", new ImportReceiptItemDAO().getItemsByReceiptId(ridDetail));
                    request.setAttribute("listVariants", new dao.ProductVariantDAO().getAllVariant());
                    request.setAttribute("listSuppliers", new SupplierDAO().getAllSuppliers());
                    request.setAttribute("listEmployees", new EmployeesDAO().getAllEmployeeses());
                    page = "/pages/InventoryReceiptManagementPage/detailInventoryReceipt.jsp";
                    break;
                case "inventoryReceiptDelete":
                    int ridDel = Integer.parseInt(request.getParameter("id"));
                    ImportReceiptItemDAO itemDao = new ImportReceiptItemDAO();
                    InventoryItemDAO invDaoForReceipt = new InventoryItemDAO();
                    int totalInvDeleted = 0;
                    for (ImportReceiptItem it : itemDao.getItemsByReceiptId(ridDel)) {
                        // delete all inventory rows for each receipt item
                        totalInvDeleted += invDaoForReceipt.deleteByReceiptItemId(it.getReceipt_item_id());
                        // nếu xóa item fail (dính khóa ngoại) thì dừng
                        if (!itemDao.deleteItem(it.getReceipt_item_id())) {
                            request.getSession().setAttribute("msg", "Cannot delete this receipt because one of its items is still referenced by other data.");
                            request.getSession().setAttribute("msgType", "danger");
                            response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptManagement");
                            return;
                        }
                    }
                    boolean deleted = new ImportReceiptsDAO().deleteReceipt(ridDel);
                    if (deleted) {
                        String receiptMsg = totalInvDeleted > 0
                                ? "Receipt deleted together with " + totalInvDeleted + " related inventory record(s)."
                                : "Receipt deleted successfully.";
                        request.getSession().setAttribute("msg", receiptMsg);
                        request.getSession().setAttribute("msgType", "success");
                    } else {
                        request.getSession().setAttribute("msg", "Cannot delete this receipt because it is referenced by other data.");
                        request.getSession().setAttribute("msgType", "danger");
                    }
                    response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptManagement");
                    return;

                case "productVariantManagement":
                    page = "/pages/ProductVariantManagementPage/productVariantManagement.jsp";
                    dao.ProductVariantDAO vdao = new dao.ProductVariantDAO();
                    dao.ProductDAO pdao = new dao.ProductDAO();
                    listData = vdao.getAllVariant();
                    request.setAttribute("products", pdao.getAllProduct());
                    break;

                case "reviewManagement":
                    page = "/pages/ReviewManagementPage/reviewManagement.jsp";
                    ReviewDAO reviewDao = new ReviewDAO();
                    listData = reviewDao.getAllReviews();
                    List<String> reviewedProducts = reviewDao.getReviewedProductNames();
                    request.setAttribute("reviewedProducts", reviewedProducts);
                    break;

                case "processOrderManagement":
                    page = "/pages/OrderManagementPage/processOrderManagement.jsp";
                    OrderDAO orderDao = new OrderDAO();
                    List<Order> orderList = orderDao.getAllOrdersWithFullInfo();
                    request.setAttribute("orderList", orderList);
                    List<Map<String, String>> statusList = orderDao.getAllOrderStatuses();
                    request.setAttribute("statusList", statusList);
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
                    page = "/pages/DashboardPage/dashboardPage.jsp";
            }
        }

        // 4. Đẩy đường dẫn trang con vào Attribute để Template include
        request.setAttribute("contentPage", page);
        request.setAttribute("listdata", listData);

        // 5. Forward đến Template duy nhất
        request.getRequestDispatcher("/template/staffTemplate.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    private int getStaffEmployeeId(HttpServletRequest request) {
        jakarta.servlet.http.Cookie[] cookies = request.getCookies();
        if (cookies == null) return 0;
        for (jakarta.servlet.http.Cookie c : cookies) {
            if ("cookieID".equals(c.getName())) {
                try { return Integer.parseInt(c.getValue()); } catch (NumberFormatException e) { return 0; }
            }
        }
        return 0;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if ("inventoryReceiptConfirm".equals(action)) {
            String rp = request.getParameter("receipt_id");
            int receiptId = (rp != null && !rp.isEmpty()) ? Integer.parseInt(rp) : 0;
            int created = new ImportService().generateInventoryFromReceipt(receiptId);
            request.getSession().setAttribute("msg", "Receipt confirmed. " + created + " inventory record(s) created.");
            request.getSession().setAttribute("msgType", "success");
            response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptDetail&id=" + receiptId);
            return;
        }
        if ("inventoryReceiptAdd".equals(action)) {
            String sp = request.getParameter("supplier_id");
            int supplierId = (sp != null && !sp.isEmpty()) ? Integer.parseInt(sp) : 0;
            int empId = getStaffEmployeeId(request);
            if (empId <= 0) {
                // Fallback: use first employee in system to avoid FK error
                try {
                    EmployeesDAO ed = new EmployeesDAO();
                    java.util.List<Employees> emps = ed.getAllEmployeeses();
                    if (emps != null && !emps.isEmpty()) {
                        empId = emps.get(0).getEmployeeId();
                    } else {
                        empId = 1;
                    }
                } catch (Exception e) {
                    empId = 1;
                }
            }
            double totalCost = 0;
            try { String tc = request.getParameter("total_cost"); if (tc != null && !tc.isEmpty()) totalCost = Double.parseDouble(tc); } catch (NumberFormatException e) { }
            ImportReceipts r = new ImportReceipts(0, supplierId, empId, totalCost, null);
            int newId = new ImportReceiptsDAO().insertReceiptReturnId(r);
            if (newId > 0) {
                request.getSession().setAttribute("msg", "Inventory receipt created successfully.");
                request.getSession().setAttribute("msgType", "success");
                response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptDetail&id=" + newId);
            } else {
                request.getSession().setAttribute("msg", "Failed to create inventory receipt. Please check the supplier and employee.");
                request.getSession().setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptManagement");
            }
            return;
        }
        if ("inventoryReceiptEdit".equals(action)) {
            String rp = request.getParameter("receipt_id");
            int receiptId = (rp != null && !rp.isEmpty()) ? Integer.parseInt(rp) : 0;
            String sp = request.getParameter("supplier_id");
            int supplierId = (sp != null && !sp.isEmpty()) ? Integer.parseInt(sp) : 0;
            String ep = request.getParameter("employee_id");
            int empId = (ep != null && !ep.isEmpty()) ? Integer.parseInt(ep) : 0;
            double totalCost = 0;
            try { String tc = request.getParameter("total_cost"); if (tc != null && !tc.isEmpty()) totalCost = Double.parseDouble(tc); } catch (NumberFormatException e) { }
            new ImportReceiptsDAO().updateReceipt(new ImportReceipts(receiptId, supplierId, empId, totalCost, null));
            request.getSession().setAttribute("msg", "Inventory receipt updated successfully.");
            request.getSession().setAttribute("msgType", "success");
            response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptDetail&id=" + receiptId);
            return;
        }
        if ("receiptItemAdd".equals(action)) {
            String rp = request.getParameter("receipt_id");
            int receiptId = (rp != null && !rp.isEmpty()) ? Integer.parseInt(rp) : 0;
            String vp = request.getParameter("variant_id");
            int variantId = (vp != null && !vp.isEmpty()) ? Integer.parseInt(vp) : 0;
            double importPrice = 0;
            try { String ip = request.getParameter("import_price"); if (ip != null && !ip.isEmpty()) importPrice = Double.parseDouble(ip); } catch (NumberFormatException e) { }
            String qp = request.getParameter("quantity");
            int qty = (qp != null && !qp.isEmpty()) ? Integer.parseInt(qp) : 0;
            if (variantId <= 0) {
                request.getSession().setAttribute("msg", "Please select a product and variant before adding an item.");
                request.getSession().setAttribute("msgType", "danger");
            } else if (qty <= 0) {
                request.getSession().setAttribute("msg", "Quantity must be greater than 0.");
                request.getSession().setAttribute("msgType", "danger");
            } else if (importPrice < 0) {
                request.getSession().setAttribute("msg", "Import price cannot be less than 0.");
                request.getSession().setAttribute("msgType", "danger");
            } else {
                new ImportReceiptItemDAO().insertItem(new ImportReceiptItem(0, receiptId, variantId, importPrice, qty));
                request.getSession().setAttribute("msg", "Item added to the receipt.");
                request.getSession().setAttribute("msgType", "success");
            }
            response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptDetail&id=" + receiptId);
            return;
        }
        if ("receiptItemEdit".equals(action)) {
            String ip = request.getParameter("receipt_item_id");
            int itemId = (ip != null && !ip.isEmpty()) ? Integer.parseInt(ip) : 0;
            String rp = request.getParameter("receipt_id");
            int receiptId = (rp != null && !rp.isEmpty()) ? Integer.parseInt(rp) : 0;
            String vp = request.getParameter("variant_id");
            int variantId = (vp != null && !vp.isEmpty()) ? Integer.parseInt(vp) : 0;
            double importPrice = 0;
            try { String px = request.getParameter("import_price"); if (px != null && !px.isEmpty()) importPrice = Double.parseDouble(px); } catch (NumberFormatException e) { }
            String qp = request.getParameter("quantity");
            int qty = (qp != null && !qp.isEmpty()) ? Integer.parseInt(qp) : 0;
            if (variantId <= 0) {
                request.getSession().setAttribute("msg", "Please select a product and variant before updating the item.");
                request.getSession().setAttribute("msgType", "danger");
            } else if (qty <= 0) {
                request.getSession().setAttribute("msg", "Quantity must be greater than 0.");
                request.getSession().setAttribute("msgType", "danger");
            } else if (importPrice < 0) {
                request.getSession().setAttribute("msg", "Import price cannot be less than 0.");
                request.getSession().setAttribute("msgType", "danger");
            } else {
                new ImportReceiptItemDAO().updateItem(new ImportReceiptItem(itemId, receiptId, variantId, importPrice, qty));
                request.getSession().setAttribute("msg", "Receipt item updated successfully.");
                request.getSession().setAttribute("msgType", "success");
            }
            response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptDetail&id=" + receiptId);
            return;
        }
        if ("receiptItemDelete".equals(action)) {
            String ip = request.getParameter("receipt_item_id");
            int itemId = (ip != null && !ip.isEmpty()) ? Integer.parseInt(ip) : 0;
            String rp = request.getParameter("receipt_id");
            int receiptId = (rp != null && !rp.isEmpty()) ? Integer.parseInt(rp) : 0;
            InventoryItemDAO invDao = new InventoryItemDAO();
            // Luôn xóa toàn bộ inventory_items liên quan rồi xóa dòng phiếu
            int deletedInv = invDao.deleteByReceiptItemId(itemId);
            boolean deleted = new ImportReceiptItemDAO().deleteItem(itemId);
            if (deleted) {
                String msg = deletedInv > 0 ? "Receipt item deleted together with " + deletedInv + " related inventory record(s)." : "Receipt item deleted successfully.";
                request.getSession().setAttribute("msg", msg);
                request.getSession().setAttribute("msgType", "success");
            } else {
                request.getSession().setAttribute("msg", "Cannot delete this item because it is referenced by other data.");
                request.getSession().setAttribute("msgType", "danger");
            }
            response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptDetail&id=" + receiptId);
            return;
        }
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
