/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;

import dao.ImportReceiptItemDAO;
import dao.InventoryItemDAO;
import dao.ProductVariantDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.InventoryItem;

@WebServlet(name = "InventoryServlet", urlPatterns = {"/inventory"})
// Nhân viên thêm, xem, sửa, xóa từng bản ghi tồn kho (thường kèm chọn biến thể và dòng phiếu nhập).
public class InventoryServlet extends HttpServlet {

    private InventoryItemDAO dao;

    @Override
    public void init() {
        dao = new InventoryItemDAO();
    }

    private void redirectToInventoryManagement(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryManagement");
    }

    /** Đọc số nguyên an toàn từ tham số. */
    private int parseIntSafe(String s, int defaultValue) {
        if (s == null) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /** Tạo mã nội bộ tạm khi thêm tay một chiếc vào kho (khác luồng xác nhận phiếu tự sinh seri). */
    private String generateInternalCode(int variantId, int receiptItemId) {
        return "INV-" + variantId + "-" + receiptItemId + "-" + System.currentTimeMillis();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            redirectToInventoryManagement(request, response);
            return;
        }

        String page = "/pages/InventoryManagementPage/inventoryManagement.jsp";
        switch (action) {
            case "add": {
                int receiptItemId = parseIntSafe(request.getParameter("receipt_item_id"), 0);
                if (receiptItemId > 0) {
                    request.setAttribute("receiptItem", new ImportReceiptItemDAO().getItemById(receiptItemId));
                }
                request.setAttribute("listVariants", new ProductVariantDAO().getAllVariant());
                page = "/pages/InventoryManagementPage/addInventory.jsp";
                break;
            }
            case "view": {
                InventoryItem item = getByIdSafe(request);
                request.setAttribute("inventoryItem", item);
                page = "/pages/InventoryManagementPage/detailInventory.jsp";
                break;
            }
            case "edit": {
                InventoryItem item = getByIdSafe(request);
                request.setAttribute("inventoryItem", item);
                request.setAttribute("listVariants", new ProductVariantDAO().getAllVariant());
                page = "/pages/InventoryManagementPage/editInventory.jsp";
                break;
            }
            case "delete": {
                // Xóa hẳn một dòng tồn kho; nếu đang được đơn hàng dùng thì có thể thất bại.
                boolean ok = false;
                int id = parseIntSafe(request.getParameter("id"), 0);
                if (id > 0) {
                    ok = dao.deleteInventory(id);
                }
                if (ok) {
                    setMsg(request.getSession(), "Đã xóa sản phẩm trong kho.", "success");
                } else {
                    setMsg(request.getSession(), "Xóa chưa được, có thể do ID không đúng hoặc sản phẩm đang được dùng.", "danger");
                }
                redirectToInventoryManagement(request, response);
                return;
            }
            default: {
                redirectToInventoryManagement(request, response);
                return;
            }
        }

        request.setAttribute("contentPage", page);
        request.getRequestDispatcher("/template/staffTemplate.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            redirectToInventoryManagement(request, response);
            return;
        }

        switch (action) {
            case "add": {
                String receiptItemIdStr = request.getParameter("receipt_item_id");
                String importPriceStr = request.getParameter("import_price");
                String status = request.getParameter("status");

                try {
                    int variantId = parseIntSafe(request.getParameter("variant_id"), 0);
                    int receiptItemId;
                    if (receiptItemIdStr != null && !receiptItemIdStr.isBlank()) {
                        receiptItemId = Integer.parseInt(receiptItemIdStr);
                    } else {
                        receiptItemId = new ImportReceiptItemDAO().getFirstReceiptItemId();
                        if (receiptItemId == 0) {
                            setMsg(request.getSession(), "Chưa có phiếu nhập phù hợp. Bạn tạo phiếu nhập trước nhé.", "danger");
                            redirectToInventoryManagement(request, response);
                            return;
                        }
                    }
                    double importPrice = Double.parseDouble(importPriceStr != null ? importPriceStr : "0");
                    String normalizedStatus = (status == null || status.trim().isEmpty()) ? "IN_STOCK" : status.trim();
                    String internalCode = generateInternalCode(variantId, receiptItemId);
                    InventoryItem item = new InventoryItem(0, variantId, receiptItemId, internalCode, importPrice, normalizedStatus);
                    boolean ok = dao.insertInventory(item);
                    if (ok) {
                        setMsg(request.getSession(), "Đã thêm sản phẩm vào kho.", "success");
                    } else {
                        setMsg(request.getSession(), "Thêm chưa được — có thể mã đã tồn tại hoặc dữ liệu sai.", "danger");
                    }
                } catch (NumberFormatException e) {
                    setMsg(request.getSession(), "Dữ liệu chưa hợp lệ (biến thể hoặc giá nhập).", "danger");
                }

                redirectToInventoryManagement(request, response);
                break;
            }
            case "update": {
                String importPriceStr = request.getParameter("import_price");
                String status = request.getParameter("status");

                try {
                    int inventoryId = parseIntSafe(request.getParameter("inventory_id"), 0);
                    InventoryItem existing = dao.getInventoryById(inventoryId);
                    if (existing == null) {
                        setMsg(request.getSession(), "Không tìm thấy sản phẩm cần cập nhật.", "danger");
                        redirectToInventoryManagement(request, response);
                        return;
                    }
                    int variantId = parseIntSafe(request.getParameter("variant_id"), 0);
                    double importPrice = Double.parseDouble(importPriceStr != null ? importPriceStr : "0");
                    String normalizedStatus = (status == null || status.trim().isEmpty()) ? "IN_STOCK" : status.trim();
                    InventoryItem item = new InventoryItem(inventoryId, variantId, existing.getReceipt_item_id(),
                            existing.getSerialId(), importPrice, normalizedStatus);
                    boolean ok = dao.updateInventory(item);
                    if (ok) {
                        setMsg(request.getSession(), "Cập nhật sản phẩm trong kho thành công.", "success");
                    } else {
                        setMsg(request.getSession(), "Cập nhật chưa thành công, bạn thử lại giúp mình nhé.", "danger");
                    }
                } catch (NumberFormatException e) {
                    setMsg(request.getSession(), "Dữ liệu chưa hợp lệ, bạn kiểm tra lại nhé.", "danger");
                }

                redirectToInventoryManagement(request, response);
                break;
            }
            default:
                redirectToInventoryManagement(request, response);
                break;
        }
    }

    /** Lấy một bản ghi tồn kho theo tham số id trên địa chỉ. */
    private InventoryItem getByIdSafe(HttpServletRequest request) {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isBlank()) {
            return null;
        }
        try {
            int id = Integer.parseInt(idStr);
            return dao.getInventoryById(id);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** Thông báo tạm cho màn quản lý kho sau chuyển hướng. */
    private void setMsg(HttpSession session, String msg, String type) {
        session.setAttribute("msg", msg);
        session.setAttribute("msgType", type);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
