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
import dao.ProductVariantDAO;
import model.ProductVariant;

/**
 * @author ASUS
 */
@WebServlet(name = "staffServlet", urlPatterns = {"/staffservlet"})
// Trung tâm điều hướng nhân viên: bảng điều khiển, phiếu nhập kho, tồn kho, nhà cung cấp (qua servlet riêng), đơn hàng, sản phẩm...
// Tham số action trên địa chỉ quyết định màn hình hoặc thao tác (get hiển thị, post lưu hoặc xác nhận phiếu).
public class staffServlet extends HttpServlet {

    /** Bản nháp seri nhập tay theo từng phiếu, lưu trong phiên làm việc để không mất khi tải lại trang. */
    @SuppressWarnings("unchecked")
    private java.util.Map<Integer, java.util.Map<String, String>> getSerialDraftsByReceipt(jakarta.servlet.http.HttpSession session) {
        Object obj = session.getAttribute("serialDraftsByReceipt");
        if (obj instanceof java.util.Map) {
            return (java.util.Map<Integer, java.util.Map<String, String>>) obj;
        }
        java.util.Map<Integer, java.util.Map<String, String>> created = new java.util.HashMap<>();
        session.setAttribute("serialDraftsByReceipt", created);
        return created;
    }

    /** Đọc các ô seri từ form gửi lên và ghi vào bản nháp trong phiên. */
    private void saveSerialDraftsFromRequest(HttpServletRequest request, int receiptId) {
        if (receiptId <= 0) {
            return;
        }
        String[] drafts = request.getParameterValues("serialDraft");
        if (drafts == null || drafts.length == 0) {
            return;
        }
        java.util.Map<Integer, java.util.Map<String, String>> all = getSerialDraftsByReceipt(request.getSession());
        java.util.Map<String, String> map = all.computeIfAbsent(receiptId, k -> new java.util.HashMap<>());
        for (String entry : drafts) {
            if (entry == null || entry.isEmpty()) {
                continue;
            }
            String[] parts = entry.split("\\|", 3);
            if (parts.length < 3) {
                continue;
            }
            String key = parts[0] + "_" + parts[1];
            String val = parts[2] == null ? "" : parts[2].trim().toUpperCase();
            map.put(key, val);
        }
    }

    /** Xóa bản nháp seri thuộc một dòng hàng trên phiếu (khi xóa hoặc sửa dòng). */
    private void removeSerialDraftsForItem(HttpServletRequest request, int receiptId, int receiptItemId) {
        if (receiptId <= 0 || receiptItemId <= 0) {
            return;
        }
        java.util.Map<Integer, java.util.Map<String, String>> all = getSerialDraftsByReceipt(request.getSession());
        java.util.Map<String, String> map = all.get(receiptId);
        if (map == null || map.isEmpty()) {
            return;
        }
        String prefix = receiptItemId + "_";
        java.util.Iterator<java.util.Map.Entry<String, String>> it = map.entrySet().iterator();
        while (it.hasNext()) {
            java.util.Map.Entry<String, String> e = it.next();
            String k = e.getKey();
            if (k != null && k.startsWith(prefix)) {
                it.remove();
            }
        }
    }

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
        OrderDAO orderDAO = new OrderDAO();

        String action = request.getParameter("action");
        String page = "/pages/staffDashboard.jsp";
        if (action == null || action.trim().isEmpty()) {
            action = "dashboard";
        }
        if ("inventoryReceiptEdit".equals(action)) {
            String rid = request.getParameter("id");
            request.getSession().setAttribute("msg",
                    "Receipt edit page is disabled. Add lines using the \"Add Item\" form (same SKU + price merges on one receipt).");
            request.getSession().setAttribute("msgType", "danger");
            if (rid != null && !rid.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptDetail&id=" + rid);
            } else {
                response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptManagement");
            }
            return;
        }
        List<?> listData = null;
        if (action != null) {
            switch (action) {
                case "dashboard":
                    page = "/pages/DashboardPage/staffDashboard.jsp";
                    int year = 2026;
                    request.setAttribute("listDataCustomer", new CustomerDAO().getCustomersByYear(year));
                    request.setAttribute("listDataEmployee", new EmployeesDAO().getEmployeesByYear(year));

                    List<Voucher> listV = new VoucherDAO().getVouchersByYear(year);
                    List<Order> listOrders = new OrderDAO().getOrdersByYear(year);

                    List<Order> top5RecentOrders = orderDAO.getTop5RecentOrders();
                    request.setAttribute("top5RecentOrders", top5RecentOrders);

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

                    request.setAttribute("listSuppliers", new SupplierDAO().getAllSuppliers());
                    List<ImportReceipts> allReceiptsDashboard = new ImportReceiptsDAO().getAllReceipts();
                    List<ImportReceipts> filteredReceiptsDashboard = new ArrayList<>();
                    for (ImportReceipts r : allReceiptsDashboard) {
                        if (r == null || r.getImport_date() == null) {
                            continue;
                        }
                        Calendar cal = Calendar.getInstance();
                        cal.setTime(r.getImport_date());
                        int rYear = cal.get(Calendar.YEAR);
                        if (rYear == year) {
                            filteredReceiptsDashboard.add(r);
                        }
                    }
                    filteredReceiptsDashboard.sort((a, b) -> {
                        if (a.getImport_date() == null && b.getImport_date() == null) {
                            return 0;
                        }
                        if (a.getImport_date() == null) {
                            return 1;
                        }
                        if (b.getImport_date() == null) {
                            return -1;
                        }
                        return b.getImport_date().compareTo(a.getImport_date());
                    });
                    int limitDashboard = 5;
                    if (filteredReceiptsDashboard.size() > limitDashboard) {
                        filteredReceiptsDashboard = filteredReceiptsDashboard.subList(0, limitDashboard);
                    }
                    request.setAttribute("listImportReceipts", filteredReceiptsDashboard);

                    List<InventorySummary> dashboardInventorySummary = new InventoryItemDAO().getInventorySummary();
                    int dashboardInventoryImportedTotal = 0;
                    int dashboardInventorySoldTotal = 0;
                    int dashboardInventoryReversedTotal = 0;
                    int dashboardInventoryInStockTotal = 0;
                    for (InventorySummary s : dashboardInventorySummary) {
                        if (s == null) {
                            continue;
                        }
                        dashboardInventoryImportedTotal += s.getImported();
                        dashboardInventorySoldTotal += s.getSold();
                        dashboardInventoryReversedTotal += s.getReversed();
                        dashboardInventoryInStockTotal += s.getInStock();
                    }
                    request.setAttribute("inventoryImportedTotal", dashboardInventoryImportedTotal);
                    request.setAttribute("inventorySoldTotal", dashboardInventorySoldTotal);
                    request.setAttribute("inventoryReversedTotal", dashboardInventoryReversedTotal);
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
                    if (month <= 0) {
                        month = -1;
                    }

                    if (month == -1) {
                        request.setAttribute("listDataCustomer", new CustomerDAO().getCustomersByYear(yearForMonth));
                        request.setAttribute("listDataEmployee", new EmployeesDAO().getEmployeesByYear(yearForMonth));
                        request.setAttribute("top5RecentOrders", orderDAO.getTop5RecentOrders());

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
                            if (r == null || r.getImport_date() == null) {
                                continue;
                            }
                            Calendar cal = Calendar.getInstance();
                            cal.setTime(r.getImport_date());
                            int rYear = cal.get(Calendar.YEAR);
                            if (rYear == yearForMonth) {
                                filteredReceiptsYear.add(r);
                            }
                        }
                        filteredReceiptsYear.sort((a, b) -> {
                            if (a.getImport_date() == null && b.getImport_date() == null) {
                                return 0;
                            }
                            if (a.getImport_date() == null) {
                                return 1;
                            }
                            if (b.getImport_date() == null) {
                                return -1;
                            }
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
                        List<Order> listOrdersMonth = new OrderDAO().getTop5OrdersByMonthStaff(month);

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

                        List<Order> top5Month = new ArrayList<>();
                        if (listOrdersMonth != null && !listOrdersMonth.isEmpty()) {
                            top5Month = listOrdersMonth.stream().limit(5).collect(java.util.stream.Collectors.toList());
                        }

                        request.setAttribute("top5RecentOrders", top5Month);

                        request.setAttribute("listSuppliers", new SupplierDAO().getAllSuppliers());
                        List<ImportReceipts> allReceiptsMonth = new ImportReceiptsDAO().getAllReceipts();
                        List<ImportReceipts> filteredReceiptsMonth = new ArrayList<>();
                        for (ImportReceipts r : allReceiptsMonth) {
                            if (r == null || r.getImport_date() == null) {
                                continue;
                            }
                            Calendar cal = Calendar.getInstance();
                            cal.setTime(r.getImport_date());
                            int rYear = cal.get(Calendar.YEAR);
                            int rMonth = cal.get(Calendar.MONTH) + 1;
                            if (rYear == yearForMonth && rMonth == month) {
                                filteredReceiptsMonth.add(r);
                            }
                        }
                        filteredReceiptsMonth.sort((a, b) -> {
                            if (a.getImport_date() == null && b.getImport_date() == null) {
                                return 0;
                            }
                            if (a.getImport_date() == null) {
                                return 1;
                            }
                            if (b.getImport_date() == null) {
                                return -1;
                            }
                            return b.getImport_date().compareTo(a.getImport_date());
                        });
                        int limitMonth = 5;
                        if (filteredReceiptsMonth.size() > limitMonth) {
                            filteredReceiptsMonth = filteredReceiptsMonth.subList(0, limitMonth);
                        }
                        request.setAttribute("listImportReceipts", filteredReceiptsMonth);
                    }

                    ReviewDAO rdStats = new ReviewDAO();
                    Map<Integer, Integer> rsStats = (month == -1)
                            ? rdStats.getReviewStats()
                            : rdStats.getReviewStatsByMonth(yearForMonth, month);
                    for (int i = 1; i <= 5; i++) {
                        request.setAttribute("star" + i, rsStats.get(i));
                    }

                    // Inventory summary card (not filtered by month because DAO aggregates by variant)
                    List<InventorySummary> monthInventorySummary = new InventoryItemDAO().getInventorySummary();
                    int monthInventoryImportedTotal = 0;
                    int monthInventorySoldTotal = 0;
                    int monthInventoryReversedTotal = 0;
                    int monthInventoryInStockTotal = 0;
                    for (InventorySummary s : monthInventorySummary) {
                        if (s == null) {
                            continue;
                        }
                        monthInventoryImportedTotal += s.getImported();
                        monthInventorySoldTotal += s.getSold();
                        monthInventoryReversedTotal += s.getReversed();
                        monthInventoryInStockTotal += s.getInStock();
                    }
                    request.setAttribute("inventoryImportedTotal", monthInventoryImportedTotal);
                    request.setAttribute("inventorySoldTotal", monthInventorySoldTotal);
                    request.setAttribute("inventoryReversedTotal", monthInventoryReversedTotal);
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

                        // IMEI-level inventory list
                        List<InventoryItem> listInventory = (keyword != null && !keyword.trim().isEmpty())
                                ? idao.searchInventory(keyword)
                                : idao.getAllInventory();
                        listData = listInventory != null ? listInventory : new java.util.ArrayList<>();
                        request.setAttribute("listInventory", listData);

                        List<model.InventorySummary> inventorySummary = (keyword != null && !keyword.trim().isEmpty())
                                ? idao.getInventorySummaryByKeyword(keyword)
                                : idao.getInventorySummary();
                        request.setAttribute("inventorySummary", inventorySummary != null ? inventorySummary : new java.util.ArrayList<>());

                        int totalImported = 0;
                        int totalSold = 0;
                        int totalReversed = 0;
                        int totalInStock = 0;
                        if (inventorySummary != null) {
                            for (model.InventorySummary s : inventorySummary) {
                                if (s != null) {
                                    totalImported += s.getImported();
                                    totalSold += s.getSold();
                                    totalReversed += s.getReversed();
                                    totalInStock += s.getInStock();
                                }
                            }
                        }
                        request.setAttribute("totalImported", totalImported);
                        request.setAttribute("totalSold", totalSold);
                        request.setAttribute("totalReversed", totalReversed);
                        request.setAttribute("totalInStock", totalInStock);
                    } catch (Exception e) {
                        e.printStackTrace();
                        listData = new java.util.ArrayList<>();
                        request.setAttribute("listInventory", listData);
                        request.setAttribute("inventorySummary", new java.util.ArrayList<>());
                        request.setAttribute("totalImported", 0);
                        request.setAttribute("totalSold", 0);
                        request.setAttribute("totalReversed", 0);
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

                // --- Phiếu nhập kho: danh sách theo nhà cung cấp, tạo phiếu, mở phiếu nháp, chi tiết, lịch sử, xóa ---
                case "inventoryReceiptManagement":
                    page = "/pages/InventoryReceiptManagementPage/inventoryReceiptManagement.jsp";
                    ImportReceiptsDAO rdao = new ImportReceiptsDAO();
                    List<ImportReceipts> allReceipts = rdao.getAllReceipts();

                    java.util.Map<Integer, ImportReceipts> latestBySupplier = new java.util.HashMap<>();
                    java.util.Map<Integer, ImportReceipts> latestDraftBySupplier = new java.util.HashMap<>();
                    java.util.Map<Integer, ImportReceipts> latestConfirmedBySupplier = new java.util.HashMap<>();
                    for (ImportReceipts r : allReceipts) {
                        if (r == null) {
                            continue;
                        }
                        int supplierId = r.getSupplier_id();
                        String st = r.getStatus() == null ? "" : r.getStatus().trim();
                        if ("DRAFT".equalsIgnoreCase(st)) {
                            ImportReceipts oldDraft = latestDraftBySupplier.get(supplierId);
                            if (oldDraft == null || r.getReceipt_id() > oldDraft.getReceipt_id()) {
                                latestDraftBySupplier.put(supplierId, r);
                            }
                        }
                        if ("CONFIRMED".equalsIgnoreCase(st)) {
                            ImportReceipts oldConfirmed = latestConfirmedBySupplier.get(supplierId);
                            if (oldConfirmed == null || r.getReceipt_id() > oldConfirmed.getReceipt_id()) {
                                latestConfirmedBySupplier.put(supplierId, r);
                            }
                        }

                        ImportReceipts oldAny = latestBySupplier.get(supplierId);
                        if (oldAny == null || r.getReceipt_id() > oldAny.getReceipt_id()) {
                            latestBySupplier.put(supplierId, r);
                        }
                    }

                    List<ImportReceipts> dedupedReceipts = new ArrayList<>();
                    for (java.util.Map.Entry<Integer, ImportReceipts> entry : latestBySupplier.entrySet()) {
                        int supplierId = entry.getKey();
                        ImportReceipts display = latestDraftBySupplier.get(supplierId);
                        if (display == null) {
                            display = latestConfirmedBySupplier.get(supplierId);
                        }
                        if (display == null) {
                            display = entry.getValue();
                        }
                        dedupedReceipts.add(display);
                    }
                    dedupedReceipts.sort((a, b) -> Integer.compare(b.getReceipt_id(), a.getReceipt_id()));
                    listData = dedupedReceipts;
                    request.setAttribute("listSuppliers", new SupplierDAO().getAllSuppliers());
                    request.setAttribute("listEmployees", new EmployeesDAO().getAllEmployeeses());
                    break;
                case "inventoryReceiptAdd":
                    page = "/pages/InventoryReceiptManagementPage/addInventoryReceipt.jsp";
                    request.setAttribute("listSuppliers", new SupplierDAO().getActiveSuppliers());
                    request.setAttribute("listEmployees", new EmployeesDAO().getAllEmployeeses());
                    break;
                case "inventoryReceiptStartBySupplier":
                    int supplierIdStart = 0;
                    try {
                        supplierIdStart = Integer.parseInt(request.getParameter("supplier_id"));
                    } catch (Exception e) {
                        supplierIdStart = 0;
                    }
                    if (supplierIdStart <= 0) {
                        response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptAdd");
                        return;
                    }
                    SupplierDAO supplierDaoStart = new SupplierDAO();
                    if (!supplierDaoStart.isSupplierActive(supplierIdStart)) {
                        request.getSession().setAttribute("msg",
                                "This supplier is inactive. Only active suppliers can be used for new receipts.");
                        request.getSession().setAttribute("msgType", "danger");
                        response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptAdd");
                        return;
                    }

                    ImportReceiptsDAO startDao = new ImportReceiptsDAO();
                    List<ImportReceipts> allStartReceipts = startDao.getAllReceipts();
                    ImportReceipts latestDraft = null;
                    for (ImportReceipts r : allStartReceipts) {
                        if (r == null || r.getSupplier_id() != supplierIdStart) {
                            continue;
                        }
                        String st = r.getStatus() == null ? "" : r.getStatus().trim();
                        if (!"DRAFT".equalsIgnoreCase(st)) {
                            continue;
                        }
                        if (latestDraft == null || r.getReceipt_id() > latestDraft.getReceipt_id()) {
                            latestDraft = r;
                        }
                    }

                    if (latestDraft != null) {
                        response.sendRedirect(request.getContextPath()
                                + "/staffservlet?action=inventoryReceiptDetail&id=" + latestDraft.getReceipt_id() + "&mode=add#add-item-form");
                        return;
                    }

                    int empIdStart = getStaffEmployeeId(request);
                    if (empIdStart <= 0) {
                        empIdStart = 1;
                    }
                    ImportReceipts newDraftBySupplier = new ImportReceipts(0, supplierIdStart, empIdStart, 0, null);
                    newDraftBySupplier.setStatus("DRAFT");
                    newDraftBySupplier.setNote("");
                    newDraftBySupplier.setCreated_by(empIdStart);
                    newDraftBySupplier.setCreated_at(new java.sql.Timestamp(System.currentTimeMillis()));
                    int newDraftBySupplierId = startDao.insertReceiptReturnId(newDraftBySupplier);
                    if (newDraftBySupplierId > 0) {
                        response.sendRedirect(request.getContextPath()
                                + "/staffservlet?action=inventoryReceiptDetail&id=" + newDraftBySupplierId + "&mode=add#add-item-form");
                    } else {
                        request.getSession().setAttribute("msg", "Could not create a new receipt for this supplier.");
                        request.getSession().setAttribute("msgType", "danger");
                        response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptManagement");
                    }
                    return;
                case "inventoryReceiptDetail":
                    int ridDetail = Integer.parseInt(request.getParameter("id"));
                    String modeDetail = request.getParameter("mode");
                    if (modeDetail == null || modeDetail.trim().isEmpty()) {
                        response.sendRedirect(request.getContextPath()
                                + "/staffservlet?action=inventoryReceiptDetail&id=" + ridDetail + "&mode=view");
                        return;
                    }
                    ImportReceiptsDAO detailReceiptDao = new ImportReceiptsDAO();
                    detailReceiptDao.recalculateTotalCost(ridDetail);
                    ImportReceipts receipt = detailReceiptDao.getReceiptById(ridDetail);
                    if (receipt == null) {
                        request.getSession().setAttribute("msg", "Receipt not found.");
                        request.getSession().setAttribute("msgType", "danger");
                        response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptManagement");
                        return;
                    }
                    if ("add".equals(modeDetail) && receipt.getStatus() != null
                            && "CONFIRMED".equalsIgnoreCase(receipt.getStatus().trim())) {
                        response.sendRedirect(request.getContextPath()
                                + "/staffservlet?action=inventoryReceiptSupplierHistory&supplier_id=" + receipt.getSupplier_id());
                        return;
                    }
                    request.setAttribute("receipt", receipt);
                    request.setAttribute("receiptItems", new ImportReceiptItemDAO().getItemsByReceiptId(ridDetail));
                    request.setAttribute("inventoryByReceiptItemId",
                            new InventoryItemDAO().getInventoryGroupedByReceiptItemId(ridDetail));
                    java.util.Map<Integer, java.util.Map<String, String>> serialDraftsAll
                            = getSerialDraftsByReceipt(request.getSession());
                    request.setAttribute("serialDraftMap", serialDraftsAll.get(ridDetail));
                    request.setAttribute("listVariants", new dao.ProductVariantDAO().getAllVariant());
                    SupplierDAO supplierDaoDetail = new SupplierDAO();
                    request.setAttribute("listSuppliers", supplierDaoDetail.getAllSuppliers());
                    java.util.List<Supplier> suppliersForHeaderSelect = new java.util.ArrayList<>(supplierDaoDetail.getActiveSuppliers());
                    Supplier currentReceiptSupplier = supplierDaoDetail.getSupplierById(receipt.getSupplier_id());
                    if (currentReceiptSupplier != null && !currentReceiptSupplier.getIs_active()) {
                        boolean alreadyIn = false;
                        for (Supplier sx : suppliersForHeaderSelect) {
                            if (sx.getSupplier_id() == currentReceiptSupplier.getSupplier_id()) {
                                alreadyIn = true;
                                break;
                            }
                        }
                        if (!alreadyIn) {
                            suppliersForHeaderSelect.add(0, currentReceiptSupplier);
                        }
                    }
                    request.setAttribute("listSuppliersForReceiptSelect", suppliersForHeaderSelect);
                    request.setAttribute("listEmployees", new EmployeesDAO().getAllEmployeeses());
                    page = "/pages/InventoryReceiptManagementPage/detailInventoryReceipt.jsp";
                    break;
                case "inventoryReceiptSupplierHistory":
                    page = "/pages/InventoryReceiptManagementPage/receiptSupplierHistory.jsp";
                    int supplierIdHistory = 0;
                    try {
                        supplierIdHistory = Integer.parseInt(request.getParameter("supplier_id"));
                    } catch (Exception e) {
                        supplierIdHistory = 0;
                    }
                    ImportReceiptsDAO historyDao = new ImportReceiptsDAO();
                    List<ImportReceipts> allHistoryReceipts = historyDao.getAllReceipts();
                    List<ImportReceipts> supplierHistoryReceipts = new ArrayList<>();
                    for (ImportReceipts r : allHistoryReceipts) {
                        if (r == null || r.getSupplier_id() != supplierIdHistory) {
                            continue;
                        }
                        supplierHistoryReceipts.add(r);
                    }
                    supplierHistoryReceipts.sort((a, b) -> {
                        if (a.getCreated_at() == null && b.getCreated_at() == null) {
                            return Integer.compare(b.getReceipt_id(), a.getReceipt_id());
                        }
                        if (a.getCreated_at() == null) {
                            return 1;
                        }
                        if (b.getCreated_at() == null) {
                            return -1;
                        }
                        return b.getCreated_at().compareTo(a.getCreated_at());
                    });
                    request.setAttribute("supplierHistoryReceipts", supplierHistoryReceipts);
                    request.setAttribute("listSuppliers", new SupplierDAO().getAllSuppliers());
                    request.setAttribute("listEmployees", new EmployeesDAO().getAllEmployeeses());
                    request.setAttribute("supplierIdHistory", supplierIdHistory);
                    break;
                case "inventoryReceiptDelete":
                    int ridDel = Integer.parseInt(request.getParameter("id"));
                    ImportReceiptItemDAO itemDao = new ImportReceiptItemDAO();
                    InventoryItemDAO invDaoForReceipt = new InventoryItemDAO();
                    int totalInvDeleted = 0;
                    for (ImportReceiptItem it : itemDao.getItemsByReceiptId(ridDel)) {
                        totalInvDeleted += invDaoForReceipt.deleteByReceiptItemId(it.getReceipt_item_id());
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
        if (cookies == null) {
            return 0;
        }
        for (jakarta.servlet.http.Cookie c : cookies) {
            if ("cookieID".equals(c.getName())) {
                try {
                    return Integer.parseInt(c.getValue());
                } catch (NumberFormatException e) {
                    return 0;
                }
            }
        }
        return 0;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        // Xác nhận phiếu: kiểm tra đủ seri, không trùng, tạo tồn kho, chuyển trạng thái phiếu sang đã xác nhận.
        if ("inventoryReceiptConfirm".equals(action)) {
            String rp = request.getParameter("receipt_id");
            int receiptId = (rp != null && !rp.isEmpty()) ? Integer.parseInt(rp) : 0;
            InventoryItemDAO invDao = new InventoryItemDAO();
            ImportReceiptItemDAO receiptItemDao = new ImportReceiptItemDAO();
            List<ImportReceiptItem> receiptItems = receiptItemDao.getItemsByReceiptId(receiptId);
            if (receiptItems == null || receiptItems.isEmpty()) {
                request.getSession().setAttribute("msg",
                        "This receipt has no items. Add at least one line before confirming.");
                request.getSession().setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath()
                        + "/staffservlet?action=inventoryReceiptDetail&id=" + receiptId + "&mode=add#add-item-form");
                return;
            }
            java.util.Map<Integer, java.util.List<String>> manualSerialsByItem = new java.util.HashMap<>();
            java.util.Set<String> allManualSerials = new java.util.HashSet<>();

            for (ImportReceiptItem it : receiptItems) {
                java.util.List<String> cleaned = new java.util.ArrayList<>();
                for (int idx = 1; idx <= it.getQuantity(); idx++) {
                    String s = request.getParameter("serials_" + it.getReceipt_item_id() + "_" + idx);
                    s = s == null ? "" : s.trim().toUpperCase();
                    if (s.isEmpty()) {
                        request.getSession().setAttribute("msg",
                                "Please enter all serials for this SKU (quantity " + it.getQuantity() + ").");
                        request.getSession().setAttribute("msgType", "danger");
                        response.sendRedirect(request.getContextPath()
                                + "/staffservlet?action=inventoryReceiptDetail&id=" + receiptId + "&mode=add&serialItem=" + it.getReceipt_item_id() + "#manual-serial-panel");
                        return;
                    }
                    if (!s.matches("^SN-\\d{9}$")) {
                        request.getSession().setAttribute("msg", "Serial must match SN-123456789: " + s);
                        request.getSession().setAttribute("msgType", "danger");
                        response.sendRedirect(request.getContextPath()
                                + "/staffservlet?action=inventoryReceiptDetail&id=" + receiptId + "&mode=add#manual-serial-panel");
                        return;
                    }
                    if (allManualSerials.contains(s) || invDao.existsByImei(s)) {
                        request.getSession().setAttribute("msg", "Duplicate serial: " + s);
                        request.getSession().setAttribute("msgType", "danger");
                        response.sendRedirect(request.getContextPath()
                                + "/staffservlet?action=inventoryReceiptDetail&id=" + receiptId + "&mode=add#manual-serial-panel");
                        return;
                    }
                    cleaned.add(s);
                    allManualSerials.add(s);
                }
                manualSerialsByItem.put(it.getReceipt_item_id(), cleaned);
            }

            int generated = invDao.generateInventoryFromReceiptWithManualSerials(receiptId, manualSerialsByItem);
            ImportReceipts currentReceipt = new ImportReceiptsDAO().getReceiptById(receiptId);
            int supplierId = 0;
            int empId = getStaffEmployeeId(request);
            if (currentReceipt != null) {
                supplierId = currentReceipt.getSupplier_id();
                currentReceipt.setStatus("CONFIRMED");
                currentReceipt.setNote("Confirmed and moved to inventory.");
                new ImportReceiptsDAO().updateReceipt(currentReceipt);
                if (empId <= 0) {
                    empId = currentReceipt.getEmployee_id();
                }
            }
            if (empId <= 0) {
                empId = 1;
            }
            new ImportReceiptsDAO().recalculateTotalCost(receiptId);
            request.getSession().setAttribute("msg",
                    "Receipt confirmed: " + generated + " item(s) moved to inventory.");
            request.getSession().setAttribute("msgType", "success");
            response.sendRedirect(request.getContextPath()
                    + "/staffservlet?action=inventoryReceiptManagement");
            return;
        }
        if ("inventoryReceiptAdd".equals(action)) {
            String sp = request.getParameter("supplier_id");
            int supplierId = 0;
            try {
                supplierId = (sp != null && !sp.isEmpty()) ? Integer.parseInt(sp) : 0;
            } catch (NumberFormatException e) {
                supplierId = 0;
            }
            SupplierDAO supplierDaoPostAdd = new SupplierDAO();
            if (supplierId <= 0 || !supplierDaoPostAdd.isSupplierActive(supplierId)) {
                request.getSession().setAttribute("msg",
                        supplierId <= 0
                                ? "Please select an active supplier."
                                : "This supplier is inactive. Only active suppliers can be used for new receipts.");
                request.getSession().setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptAdd");
                return;
            }
            String receiptCode = request.getParameter("receipt_code");
            String status = request.getParameter("status");
            String note = request.getParameter("note");
            int empId = getStaffEmployeeId(request);
            if (empId <= 0) {
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
            r.setReceipt_code(receiptCode);
            r.setStatus(status);
            r.setNote(note);
            r.setCreated_by(empId);
            r.setCreated_at(new java.sql.Timestamp(System.currentTimeMillis()));
            int newId = new ImportReceiptsDAO().insertReceiptReturnId(r);
            if (newId > 0) {
                request.getSession().setAttribute("msg", "Inventory receipt created successfully.");
                request.getSession().setAttribute("msgType", "success");
                response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptDetail&id=" + newId + "&mode=add#add-item-form");
            } else {
                request.getSession().setAttribute("msg", "Failed to create inventory receipt. Please check the supplier and employee.");
                request.getSession().setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptManagement");
            }
            return;
        }
        // Cập nhật thông tin header phiếu (NCC, trạng thái, ghi chú) khi còn sửa được.
        if ("inventoryReceiptEdit".equals(action)) {
            String rp = request.getParameter("receipt_id");
            int receiptId = (rp != null && !rp.isEmpty()) ? Integer.parseInt(rp) : 0;
            String mode = request.getParameter("mode");
            String sp = request.getParameter("supplier_id");
            int supplierId = (sp != null && !sp.isEmpty()) ? Integer.parseInt(sp) : 0;
            String status = request.getParameter("status");
            String note = request.getParameter("note");

            ImportReceiptsDAO dao = new ImportReceiptsDAO();
            ImportReceipts old = dao.getReceiptById(receiptId);
            if (old == null) {
                request.getSession().setAttribute("msg", "Receipt not found.");
                request.getSession().setAttribute("msgType", "danger");
            } else {
                int newSupplierId = supplierId > 0 ? supplierId : old.getSupplier_id();
                SupplierDAO supplierDaoEdit = new SupplierDAO();
                if (newSupplierId != old.getSupplier_id() && !supplierDaoEdit.isSupplierActive(newSupplierId)) {
                    request.getSession().setAttribute("msg",
                            "Cannot switch to an inactive supplier. Choose an active supplier.");
                    request.getSession().setAttribute("msgType", "danger");
                } else {
                    old.setSupplier_id(newSupplierId);
                    old.setStatus(status);
                    old.setNote(note);
                    dao.updateReceipt(old);
                    request.getSession().setAttribute("msg", "Receipt information updated successfully.");
                    request.getSession().setAttribute("msgType", "success");
                }
            }

            String redirectMode = (mode != null && !mode.isEmpty()) ? "&mode=" + mode : "";
            response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptDetail&id=" + receiptId + redirectMode);
            return;
        }
        // Thêm dòng SKU: một SKU một giá trên phiếu — trùng SKU thì merge quantity (DAO).
        if ("receiptItemAdd".equals(action)) {
            String rp = request.getParameter("receipt_id");
            int receiptId = (rp != null && !rp.isEmpty()) ? Integer.parseInt(rp) : 0;
            ImportReceipts receiptCheck = new ImportReceiptsDAO().getReceiptById(receiptId);
            if (receiptCheck != null && receiptCheck.getStatus() != null
                    && "CONFIRMED".equalsIgnoreCase(receiptCheck.getStatus().trim())) {
                request.getSession().setAttribute("msg", "This receipt is CONFIRMED; you cannot add items.");
                request.getSession().setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath()
                        + "/staffservlet?action=inventoryReceiptSupplierHistory&supplier_id=" + receiptCheck.getSupplier_id());
                return;
            }
            String vp = request.getParameter("variant_id");
            int variantId = (vp != null && !vp.isEmpty()) ? Integer.parseInt(vp) : 0;
            double importPrice = 0;
            try {
                String ip = request.getParameter("import_price");
                if (ip != null && !ip.isEmpty()) {
                    importPrice = Double.parseDouble(ip);
                }
            } catch (NumberFormatException e) {
            }
            String qp = request.getParameter("quantity");
            int qty = (qp != null && !qp.isEmpty()) ? Integer.parseInt(qp) : 0;
            if (variantId <= 0) {
                request.getSession().setAttribute("msg", "Please select a product and variant before adding an item.");
                request.getSession().setAttribute("msgType", "danger");
            } else if (qty <= 0) {
                request.getSession().setAttribute("msg", "Quantity must be greater than 0.");
                request.getSession().setAttribute("msgType", "danger");
            } else if (importPrice <= 0) {
                request.getSession().setAttribute("msg", "Import price must be greater than 0.");
                request.getSession().setAttribute("msgType", "danger");
            } else {
                ProductVariant pvAdd = new ProductVariantDAO().getVariantById(variantId);
                if (pvAdd == null) {
                    request.getSession().setAttribute("msg", "Selected variant was not found.");
                    request.getSession().setAttribute("msgType", "danger");
                } else {
                    ImportReceiptItemDAO itemDao = new ImportReceiptItemDAO();
                    ImportReceiptItem existingLine = itemDao.getFirstItemByReceiptAndVariant(receiptId, variantId);
                    if (existingLine != null && Double.compare(existingLine.getImport_price(), importPrice) != 0) {
                        request.getSession().setAttribute("msg",
                                "On one receipt, one product has one import price. Use the existing price or edit the existing line.");
                        request.getSession().setAttribute("msgType", "danger");
                    } else {
                        itemDao.mergeOrInsertLine(receiptId, variantId, importPrice, qty);
                        new ImportReceiptsDAO().recalculateTotalCost(receiptId);
                        request.getSession().setAttribute("msg",
                                "Line added successfully.");
                        request.getSession().setAttribute("msgType", "success");
                    }
                }
            }
            response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptDetail&id=" + receiptId + "&mode=add#add-item-form");
            return;
        }
        // Sửa dòng: có thể gộp hai dòng cùng SKU thành một; lưu draft serial trong session trước redirect.
        if ("receiptItemEdit".equals(action)) {
            String rp = request.getParameter("receipt_id");
            int receiptId = (rp != null && !rp.isEmpty()) ? Integer.parseInt(rp) : 0;
            saveSerialDraftsFromRequest(request, receiptId);
            ImportReceipts receiptCheck = new ImportReceiptsDAO().getReceiptById(receiptId);
            if (receiptCheck != null && receiptCheck.getStatus() != null
                    && "CONFIRMED".equalsIgnoreCase(receiptCheck.getStatus().trim())) {
                request.getSession().setAttribute("msg", "This receipt is CONFIRMED; you cannot edit items.");
                request.getSession().setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath()
                        + "/staffservlet?action=inventoryReceiptSupplierHistory&supplier_id=" + receiptCheck.getSupplier_id());
                return;
            }
            String ip = request.getParameter("receipt_item_id");
            int itemId = (ip != null && !ip.isEmpty()) ? Integer.parseInt(ip) : 0;
            String vp = request.getParameter("variant_id");
            int variantId = (vp != null && !vp.isEmpty()) ? Integer.parseInt(vp) : 0;
            double importPrice = 0;
            try {
                String p = request.getParameter("import_price");
                if (p != null && !p.isEmpty()) {
                    importPrice = Double.parseDouble(p);
                }
            } catch (NumberFormatException e) {
            }
            int qty = 0;
            try {
                String q = request.getParameter("quantity");
                if (q != null && !q.isEmpty()) {
                    qty = Integer.parseInt(q);
                }
            } catch (NumberFormatException e) {
            }
            ImportReceiptItem oldItem = new ImportReceiptItemDAO().getItemById(itemId);
            if (oldItem == null) {
                request.getSession().setAttribute("msg", "Receipt line not found.");
                request.getSession().setAttribute("msgType", "danger");
            } else if (qty <= 0 || importPrice <= 0) {
                request.getSession().setAttribute("msg", "Import price must be greater than 0 and quantity must be valid.");
                request.getSession().setAttribute("msgType", "danger");
            } else {
                if (variantId <= 0) {
                    variantId = oldItem.getVariant_id();
                }
                ProductVariant pv = new ProductVariantDAO().getVariantById(variantId);
                if (pv == null) {
                    request.getSession().setAttribute("msg", "Selected variant was not found.");
                    request.getSession().setAttribute("msgType", "danger");
                } else {
                    ImportReceiptItemDAO itemDao = new ImportReceiptItemDAO();
                    boolean skuChanged = (variantId != oldItem.getVariant_id());
                    ImportReceiptItem sameVariantLine = itemDao.getFirstItemByReceiptAndVariant(oldItem.getReceipt_id(), variantId);

                    // Duplicate variant on same receipt: combine into the existing line.
                    if (sameVariantLine != null && sameVariantLine.getReceipt_item_id() != itemId) {
                        sameVariantLine.setQuantity(sameVariantLine.getQuantity() + qty);
                        sameVariantLine.setImport_price(importPrice);
                        itemDao.updateItem(sameVariantLine);
                        itemDao.deleteItem(itemId);
                        removeSerialDraftsForItem(request, receiptId, itemId);
                        request.getSession().setAttribute("msg", "Receipt line updated.");
                    } else {
                        ImportReceiptItem updated = new ImportReceiptItem(itemId, oldItem.getReceipt_id(), variantId, importPrice, qty);
                        itemDao.updateItem(updated);
                        if (skuChanged) {
                            removeSerialDraftsForItem(request, receiptId, itemId);
                        }
                        request.getSession().setAttribute("msg", "Receipt line updated.");
                    }
                    new ImportReceiptsDAO().recalculateTotalCost(receiptId);
                    request.getSession().setAttribute("msgType", "success");
                }
            }
            response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryReceiptDetail&id=" + receiptId + "&mode=add#add-item-form");
            return;
        }
        // Xóa dòng: xóa inventory gắn receipt_item (nếu có) trước khi DELETE dòng phiếu.
        if ("receiptItemDelete".equals(action)) {
            String ip = request.getParameter("receipt_item_id");
            int itemId = (ip != null && !ip.isEmpty()) ? Integer.parseInt(ip) : 0;
            String rp = request.getParameter("receipt_id");
            int receiptId = (rp != null && !rp.isEmpty()) ? Integer.parseInt(rp) : 0;
            ImportReceipts receiptCheck = new ImportReceiptsDAO().getReceiptById(receiptId);
            if (receiptCheck != null && receiptCheck.getStatus() != null
                    && "CONFIRMED".equalsIgnoreCase(receiptCheck.getStatus().trim())) {
                request.getSession().setAttribute("msg", "This receipt is CONFIRMED; you cannot delete items.");
                request.getSession().setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath()
                        + "/staffservlet?action=inventoryReceiptSupplierHistory&supplier_id=" + receiptCheck.getSupplier_id());
                return;
            }
            InventoryItemDAO invDao = new InventoryItemDAO();
            // Delete related inventory_items first, then receipt line
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
