/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;

import dao.BrandDAO;
import dao.CategoryDAO;
import dao.ProductDAO;
import dao.SupplierDAO;
import dao.CustomerDAO;
import dao.EmployeesDAO;
import dao.OrderDAO;
import dao.ReviewDAO;
import dao.ImportReceiptsDAO;
import dao.ImportReceiptItemDAO;
import dao.VoucherDAO;
import model.Order;
import model.ImportReceipts;
import model.ImportReceiptItem;
import model.Voucher;
import model.InventorySummary;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import model.InventoryItem;
import model.Supplier;
import java.util.Map;
import model.Employees;
import dao.InventoryItemDAO;

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
        String page = "/pages/staffDashboard.jsp"; // Trang mặc định khi mới vào
        if (action == null || action.trim().isEmpty()) {
            action = "dashboard";
        }
        List<?> listData = null; // Dấu <?> cho phép gán bất kỳ List nào (Customer, Employee...)
        // 3. Logic điều hướng (Switch-case sẽ sạch sẽ hơn if-else)
        if (action != null) {
            switch (action) {
                case "dashboard":
                    page = "/pages/DashboardPage/staffDashboard.jsp";
                    int year = 2026;
                    request.setAttribute("listDataCustomer", new CustomerDAO().getCustomersByYear(year));
                    request.setAttribute("listDataEmployee", new EmployeesDAO().getEmployeesByYear(year));

                    List<Voucher> listV = new VoucherDAO().getVouchersByYear(year);
                    List<Order> listOrders = new OrderDAO().getOrdersByYear(year);

                    long activeV = listV.stream()
                            .filter(v -> v.getStatus().equalsIgnoreCase("Active"))
                            .count();
                    long lockedV = listV.stream()
                            .filter(v -> v.getStatus().equalsIgnoreCase("Locked"))
                            .count();
                    long expiredV = listV.stream()
                            .filter(v -> v.getStatus().equalsIgnoreCase("Expired"))
                            .count();

                    long pendingCount = listOrders.stream()
                            .filter(o -> o.getStatus().equalsIgnoreCase("PENDING"))
                            .count();
                    long approvedCount = listOrders.stream()
                            .filter(o -> o.getStatus().equalsIgnoreCase("APPROVED"))
                            .count();
                    long shippingCount = listOrders.stream()
                            .filter(o -> o.getStatus().equalsIgnoreCase("SHIPPING"))
                            .count();
                    long shippedCount = listOrders.stream()
                            .filter(o -> o.getStatus().equalsIgnoreCase("SHIPPED"))
                            .count();
                    long cancelledCount = listOrders.stream()
                            .filter(o -> o.getStatus().equalsIgnoreCase("CANCELLED"))
                            .count();

                    request.setAttribute("activeV", activeV);
                    request.setAttribute("lockedV", lockedV);
                    request.setAttribute("expiredV", expiredV);

                    request.setAttribute("pendingCount", pendingCount);
                    request.setAttribute("approvedCount", approvedCount);
                    request.setAttribute("shippingCount", shippingCount);
                    request.setAttribute("shippedCount", shippedCount);
                    request.setAttribute("cancelledCount", cancelledCount);

                    request.setAttribute("listDataVoucher", listV);

                    ReviewDAO reviewDAO = new ReviewDAO();
                    Map<Integer, Integer> reviewStats = reviewDAO.getReviewStats();
                    for (int i = 1; i <= 5; i++) {
                        request.setAttribute("star" + i, reviewStats.get(i));
                    }

                    // Supplier + Inventory receipts cards
                    request.setAttribute("listSuppliers", new SupplierDAO().getAllSuppliers());
                    List<ImportReceipts> allReceiptsDashboard = new ImportReceiptsDAO().getAllReceipts();
                    List<ImportReceipts> filteredReceiptsDashboard = new ArrayList<>();
                    for (ImportReceipts r : allReceiptsDashboard) {
                        if (r == null || r.getImport_date() == null) continue;
                        Calendar cal = Calendar.getInstance();
                        cal.setTime(r.getImport_date());
                        int rYear = cal.get(Calendar.YEAR);
                        if (rYear == year) {
                            filteredReceiptsDashboard.add(r);
                        }
                    }
                    filteredReceiptsDashboard.sort((a, b) -> {
                        if (a.getImport_date() == null && b.getImport_date() == null) return 0;
                        if (a.getImport_date() == null) return 1;
                        if (b.getImport_date() == null) return -1;
                        return b.getImport_date().compareTo(a.getImport_date());
                    });
                    int limitDashboard = 5; // end="4" in JSP
                    if (filteredReceiptsDashboard.size() > limitDashboard) {
                        filteredReceiptsDashboard = filteredReceiptsDashboard.subList(0, limitDashboard);
                    }
                    request.setAttribute("listImportReceipts", filteredReceiptsDashboard);

                    // Inventory summary for dashboard card
                    List<InventorySummary> dashboardInventorySummary = new InventoryItemDAO().getInventorySummary();
                    int dashboardInventoryImportedTotal = 0;
                    int dashboardInventorySoldTotal = 0;
                    int dashboardInventoryInStockTotal = 0;
                    for (InventorySummary s : dashboardInventorySummary) {
                        if (s == null) continue;
                        dashboardInventoryImportedTotal += s.getImported();
                        dashboardInventorySoldTotal += s.getSold();
                        dashboardInventoryInStockTotal += s.getInStock();
                    }
                    request.setAttribute("inventoryImportedTotal", dashboardInventoryImportedTotal);
                    request.setAttribute("inventorySoldTotal", dashboardInventorySoldTotal);
                    request.setAttribute("inventoryInStockTotal", dashboardInventoryInStockTotal);
                    break;

                case "searchByMonth":
                    page = "/pages/DashboardPage/staffDashboard.jsp";
                    int yearForMonth = 2026;

                    String monthStr = request.getParameter("month");
                    int month = -1;
                    try {
                        month = monthStr != null ? Integer.parseInt(monthStr) : -1;
                    } catch (NumberFormatException e) {
                        month = -1;
                    }
                    // value "Select" (0) -> coi như "All"
                    if (month <= 0) {
                        month = -1;
                    }

                    if (month == -1) {
                        request.setAttribute("listDataCustomer", new CustomerDAO().getCustomersByYear(yearForMonth));
                        request.setAttribute("listDataEmployee", new EmployeesDAO().getEmployeesByYear(yearForMonth));

                        List<Voucher> listVM = new VoucherDAO().getVouchersByYear(yearForMonth);
                        List<Order> listOrdersYear = new OrderDAO().getOrdersByYear(yearForMonth);

                        long activeVM = listVM.stream()
                                .filter(v -> v.getStatus().equalsIgnoreCase("Active"))
                                .count();
                        long lockedVM = listVM.stream()
                                .filter(v -> v.getStatus().equalsIgnoreCase("Locked"))
                                .count();
                        long expiredVM = listVM.stream()
                                .filter(v -> v.getStatus().equalsIgnoreCase("Expired"))
                                .count();

                        long pendingCountM = listOrdersYear.stream()
                                .filter(o -> o.getStatus().equalsIgnoreCase("PENDING"))
                                .count();
                        long approvedCountM = listOrdersYear.stream()
                                .filter(o -> o.getStatus().equalsIgnoreCase("APPROVED"))
                                .count();
                        long shippingCountM = listOrdersYear.stream()
                                .filter(o -> o.getStatus().equalsIgnoreCase("SHIPPING"))
                                .count();
                        long shippedCountM = listOrdersYear.stream()
                                .filter(o -> o.getStatus().equalsIgnoreCase("SHIPPED"))
                                .count();
                        long cancelledCountM = listOrdersYear.stream()
                                .filter(o -> o.getStatus().equalsIgnoreCase("CANCELLED"))
                                .count();

                        request.setAttribute("activeV", activeVM);
                        request.setAttribute("lockedV", lockedVM);
                        request.setAttribute("expiredV", expiredVM);

                        request.setAttribute("pendingCount", pendingCountM);
                        request.setAttribute("approvedCount", approvedCountM);
                        request.setAttribute("shippingCount", shippingCountM);
                        request.setAttribute("shippedCount", shippedCountM);
                        request.setAttribute("cancelledCount", cancelledCountM);

                        request.setAttribute("listDataVoucher", listVM);

                        request.setAttribute("listSuppliers", new SupplierDAO().getAllSuppliers());
                        List<ImportReceipts> allReceiptsYear = new ImportReceiptsDAO().getAllReceipts();
                        List<ImportReceipts> filteredReceiptsYear = new ArrayList<>();
                        for (ImportReceipts r : allReceiptsYear) {
                            if (r == null || r.getImport_date() == null) continue;
                            Calendar cal = Calendar.getInstance();
                            cal.setTime(r.getImport_date());
                            int rYear = cal.get(Calendar.YEAR);
                            if (rYear == yearForMonth) {
                                filteredReceiptsYear.add(r);
                            }
                        }
                        filteredReceiptsYear.sort((a, b) -> {
                            if (a.getImport_date() == null && b.getImport_date() == null) return 0;
                            if (a.getImport_date() == null) return 1;
                            if (b.getImport_date() == null) return -1;
                            return b.getImport_date().compareTo(a.getImport_date());
                        });
                        int limitYear = 5;
                        if (filteredReceiptsYear.size() > limitYear) {
                            filteredReceiptsYear = filteredReceiptsYear.subList(0, limitYear);
                        }
                        request.setAttribute("listImportReceipts", filteredReceiptsYear);
                    } else {
                        request.setAttribute("listDataCustomer", new CustomerDAO().getCustomersByMonth(month));
                        request.setAttribute("listDataEmployee", new EmployeesDAO().getEmployeesByMonth(month));

                        List<Voucher> listVM = new VoucherDAO().getVouchersByMonth(month);
                        List<Order> listOrdersMonth = new OrderDAO().getOrdersByMonth(month);

                        long activeVM = listVM.stream()
                                .filter(v -> v.getStatus().equalsIgnoreCase("Active"))
                                .count();
                        long lockedVM = listVM.stream()
                                .filter(v -> v.getStatus().equalsIgnoreCase("Locked"))
                                .count();
                        long expiredVM = listVM.stream()
                                .filter(v -> v.getStatus().equalsIgnoreCase("Expired"))
                                .count();

                        long pendingCountM = listOrdersMonth.stream()
                                .filter(o -> o.getStatus().equalsIgnoreCase("PENDING"))
                                .count();
                        long approvedCountM = listOrdersMonth.stream()
                                .filter(o -> o.getStatus().equalsIgnoreCase("APPROVED"))
                                .count();
                        long shippingCountM = listOrdersMonth.stream()
                                .filter(o -> o.getStatus().equalsIgnoreCase("SHIPPING"))
                                .count();
                        long shippedCountM = listOrdersMonth.stream()
                                .filter(o -> o.getStatus().equalsIgnoreCase("SHIPPED"))
                                .count();
                        long cancelledCountM = listOrdersMonth.stream()
                                .filter(o -> o.getStatus().equalsIgnoreCase("CANCELLED"))
                                .count();

                        request.setAttribute("activeV", activeVM);
                        request.setAttribute("lockedV", lockedVM);
                        request.setAttribute("expiredV", expiredVM);

                        request.setAttribute("pendingCount", pendingCountM);
                        request.setAttribute("approvedCount", approvedCountM);
                        request.setAttribute("shippingCount", shippingCountM);
                        request.setAttribute("shippedCount", shippedCountM);
                        request.setAttribute("cancelledCount", cancelledCountM);

                        request.setAttribute("listDataVoucher", listVM);

                        request.setAttribute("listSuppliers", new SupplierDAO().getAllSuppliers());
                        List<ImportReceipts> allReceiptsMonth = new ImportReceiptsDAO().getAllReceipts();
                        List<ImportReceipts> filteredReceiptsMonth = new ArrayList<>();
                        for (ImportReceipts r : allReceiptsMonth) {
                            if (r == null || r.getImport_date() == null) continue;
                            Calendar cal = Calendar.getInstance();
                            cal.setTime(r.getImport_date());
                            int rYear = cal.get(Calendar.YEAR);
                            int rMonth = cal.get(Calendar.MONTH) + 1;
                            if (rYear == yearForMonth && rMonth == month) {
                                filteredReceiptsMonth.add(r);
                            }
                        }
                        filteredReceiptsMonth.sort((a, b) -> {
                            if (a.getImport_date() == null && b.getImport_date() == null) return 0;
                            if (a.getImport_date() == null) return 1;
                            if (b.getImport_date() == null) return -1;
                            return b.getImport_date().compareTo(a.getImport_date());
                        });
                        int limitMonth = 5;
                        if (filteredReceiptsMonth.size() > limitMonth) {
                            filteredReceiptsMonth = filteredReceiptsMonth.subList(0, limitMonth);
                        }
                        request.setAttribute("listImportReceipts", filteredReceiptsMonth);
                    }

                    ReviewDAO rdStats = new ReviewDAO();
                    Map<Integer, Integer> rsStats = rdStats.getReviewStats();
                    for (int i = 1; i <= 5; i++) {
                        request.setAttribute("star" + i, rsStats.get(i));
                    }

                    // Inventory summary card (not filtered by month because DAO aggregates by variant)
                    List<InventorySummary> monthInventorySummary = new InventoryItemDAO().getInventorySummary();
                    int monthInventoryImportedTotal = 0;
                    int monthInventorySoldTotal = 0;
                    int monthInventoryInStockTotal = 0;
                    for (InventorySummary s : monthInventorySummary) {
                        if (s == null) continue;
                        monthInventoryImportedTotal += s.getImported();
                        monthInventorySoldTotal += s.getSold();
                        monthInventoryInStockTotal += s.getInStock();
                    }
                    request.setAttribute("inventoryImportedTotal", monthInventoryImportedTotal);
                    request.setAttribute("inventorySoldTotal", monthInventorySoldTotal);
                    request.setAttribute("inventoryInStockTotal", monthInventoryInStockTotal);
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

                        // Danh sách chi tiết từng sản phẩm trong kho (IMEI-level)
                        List<InventoryItem> listInventory = (keyword != null && !keyword.trim().isEmpty())
                                ? idao.searchInventory(keyword)
                                : idao.getAllInventory();
                        listData = listInventory != null ? listInventory : new java.util.ArrayList<>();
                        request.setAttribute("listInventory", listData);

                        // Chỉ load phần tổng hợp khi không search (đúng với điều kiện ở JSP)
                        if (keyword == null || keyword.trim().isEmpty()) {
                            List<model.InventorySummary> inventorySummary = idao.getInventorySummary();
                            request.setAttribute("inventorySummary", inventorySummary != null ? inventorySummary : new java.util.ArrayList<>());

                            int totalImported = 0;
                            int totalSold = 0;
                            int totalInStock = 0;
                            if (inventorySummary != null) {
                                for (model.InventorySummary s : inventorySummary) {
                                    if (s != null) {
                                        totalImported += s.getImported();
                                        totalSold += s.getSold();
                                        totalInStock += s.getInStock();
                                    }
                                }
                            }
                            request.setAttribute("totalImported", totalImported);
                            request.setAttribute("totalSold", totalSold);
                            request.setAttribute("totalInStock", totalInStock);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        listData = new java.util.ArrayList<>();
                        request.setAttribute("listInventory", listData);
                        request.setAttribute("inventorySummary", new java.util.ArrayList<>());
                        request.setAttribute("totalImported", 0);
                        request.setAttribute("totalSold", 0);
                        request.setAttribute("totalInStock", 0);
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
                    ImportReceiptsDAO editReceiptDao = new ImportReceiptsDAO();
                    editReceiptDao.recalculateTotalCost(ridEdit);
                    request.setAttribute("receipt", editReceiptDao.getReceiptById(ridEdit));
                    request.setAttribute("listSuppliers", new SupplierDAO().getAllSuppliers());
                    request.setAttribute("listEmployees", new EmployeesDAO().getAllEmployeeses());
                    page = "/pages/InventoryReceiptManagementPage/editInventoryReceipt.jsp";
                    break;
                case "inventoryReceiptDetail":
                    int ridDetail = Integer.parseInt(request.getParameter("id"));
                    ImportReceiptsDAO detailReceiptDao = new ImportReceiptsDAO();
                    detailReceiptDao.recalculateTotalCost(ridDetail);
                    ImportReceipts receipt = detailReceiptDao.getReceiptById(ridDetail);
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
                    page = "/pages/DashboardPage/staffDashboard.jsp";
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
            int created = new dao.InventoryItemDAO().generateInventoryFromReceipt(receiptId);
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
            ImportReceipts r = new ImportReceipts(0, supplierId, empId, 0, null);
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
            ImportReceiptsDAO receiptDao = new ImportReceiptsDAO();
            ImportReceipts existingReceipt = receiptDao.getReceiptById(receiptId);
            double totalCost = existingReceipt != null ? existingReceipt.getTotal_cost() : 0;
            receiptDao.updateReceipt(new ImportReceipts(receiptId, supplierId, empId, totalCost, null));
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
                new ImportReceiptsDAO().recalculateTotalCost(receiptId);
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
                new ImportReceiptsDAO().recalculateTotalCost(receiptId);
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
                new ImportReceiptsDAO().recalculateTotalCost(receiptId);
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
