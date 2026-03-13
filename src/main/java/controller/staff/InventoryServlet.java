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
public class InventoryServlet extends HttpServlet {

    private InventoryItemDAO dao;

    @Override
    public void init() {
        dao = new InventoryItemDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryManagement");
            return;
        }

        switch (action) {
            case "add" -> {
                String receiptItemIdStr = request.getParameter("receipt_item_id");
                if (receiptItemIdStr != null && !receiptItemIdStr.isBlank()) {
                    try {
                        int receiptItemId = Integer.parseInt(receiptItemIdStr);
                        request.setAttribute("receiptItem", new ImportReceiptItemDAO().getItemById(receiptItemId));
                    } catch (NumberFormatException ignored) {
                    }
                }
                request.setAttribute("listVariants", new ProductVariantDAO().getAllVariant());
                request.setAttribute("contentPage", "/pages/InventoryManagementPage/addInventory.jsp");
                request.getRequestDispatcher("/template/staffTemplate.jsp").forward(request, response);
            }
            case "view" -> {
                InventoryItem item = getByIdSafe(request);
                request.setAttribute("inventoryItem", item);
                request.setAttribute("contentPage", "/pages/InventoryManagementPage/detailInventory.jsp");
                request.getRequestDispatcher("/template/staffTemplate.jsp").forward(request, response);
            }
            case "edit" -> {
                InventoryItem item = getByIdSafe(request);
                request.setAttribute("inventoryItem", item);
                request.setAttribute("listVariants", new ProductVariantDAO().getAllVariant());
                request.setAttribute("contentPage", "/pages/InventoryManagementPage/editInventory.jsp");
                request.getRequestDispatcher("/template/staffTemplate.jsp").forward(request, response);
            }
            case "delete" -> {
                String idStr = request.getParameter("id");
                boolean ok = false;
                if (idStr != null && !idStr.isBlank()) {
                    try {
                        int id = Integer.parseInt(idStr);
                        ok = dao.deleteInventory(id);
                    } catch (NumberFormatException ignored) {
                    }
                }
                setMsg(request.getSession(), ok ? "Inventory item deleted." : "Delete failed (invalid ID or item in use).", ok ? "success" : "danger");
                response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryManagement");
            }
            default -> response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryManagement");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryManagement");
            return;
        }

        switch (action) {
            case "add" ->
                handleAdd(request, response);
            case "update" ->
                handleUpdate(request, response);
            default ->
                response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryManagement");
        }
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String variantIdStr = request.getParameter("variant_id");
        String receiptItemIdStr = request.getParameter("receipt_item_id");
        String imei = request.getParameter("imei");
        String importPriceStr = request.getParameter("import_price");
        String status = request.getParameter("status");

        try {
            int variantId = Integer.parseInt(variantIdStr != null ? variantIdStr : "0");
            int receiptItemId;
            if (receiptItemIdStr != null && !receiptItemIdStr.isBlank()) {
                receiptItemId = Integer.parseInt(receiptItemIdStr);
            } else {
                receiptItemId = new ImportReceiptItemDAO().getFirstReceiptItemId();
                if (receiptItemId == 0) {
                    setMsg(request.getSession(), "No receipt item available. Create an import receipt first.", "danger");
                    response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryManagement");
                    return;
                }
            }
            double importPrice = Double.parseDouble(importPriceStr != null ? importPriceStr : "0");
            if (imei == null || imei.trim().isEmpty()) {
                setMsg(request.getSession(), "Please enter IMEI.", "danger");
            } else {
                String normalizedStatus = (status == null || status.trim().isEmpty()) ? "IN_STOCK" : status.trim();
                InventoryItem item = new InventoryItem(0, variantId, receiptItemId, imei.trim(), importPrice, normalizedStatus);
                boolean ok = dao.insertInventory(item);
                setMsg(request.getSession(), ok ? "Item added." : "Add failed (duplicate IMEI or invalid data).", ok ? "success" : "danger");
            }
        } catch (NumberFormatException e) {
            setMsg(request.getSession(), "Invalid data (variant or import price).", "danger");
        }

        response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryManagement");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String inventoryIdStr = request.getParameter("inventory_id");
        String variantIdStr = request.getParameter("variant_id");
        String imei = request.getParameter("imei");
        String importPriceStr = request.getParameter("import_price");
        String status = request.getParameter("status");

        try {
            int inventoryId = Integer.parseInt(inventoryIdStr);
            InventoryItem existing = dao.getInventoryById(inventoryId);
            if (existing == null) {
                setMsg(request.getSession(), "Item not found.", "danger");
                response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryManagement");
                return;
            }
            int variantId = Integer.parseInt(variantIdStr != null ? variantIdStr : "0");
            double importPrice = Double.parseDouble(importPriceStr != null ? importPriceStr : "0");

            if (imei == null || imei.trim().isEmpty()) {
                setMsg(request.getSession(), "Please enter IMEI.", "danger");
            } else {
                String normalizedStatus = (status == null || status.trim().isEmpty()) ? "IN_STOCK" : status.trim();
                InventoryItem item = new InventoryItem(inventoryId, variantId, existing.getReceipt_item_id(), imei.trim(), importPrice, normalizedStatus);
                boolean ok = dao.updateInventory(item);
                setMsg(request.getSession(), ok ? "Item updated." : "Update failed.", ok ? "success" : "danger");
            }
        } catch (NumberFormatException e) {
            setMsg(request.getSession(), "Invalid data.", "danger");
        }

        response.sendRedirect(request.getContextPath() + "/staffservlet?action=inventoryManagement");
    }

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

    private void setMsg(HttpSession session, String msg, String type) {
        session.setAttribute("msg", msg);
        session.setAttribute("msgType", type);
    }
}
