/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import model.InventoryItem;
import model.InventorySummary;
import utils.DBContext;

/**
 *
 * @author LE HOANG NHAN
 */
public class InventoryItemDAO extends DBContext {

    /**
     * Lấy danh sách inventory (IMEI-level) kèm tên sản phẩm + người mua (nếu đã
     * bán).
     */
    public List<InventoryItem> getAllInventory() {
        List<InventoryItem> list = new ArrayList<>();
        if (conn == null) {
            return list;
        }
        String sql = "SELECT ii.*, "
                + "p.name AS product_name, "
                + "c.full_name AS buyer_name, "
                + "pv.sku AS sku, "
                + "ir.receipt_code AS receipt_code "
                + "FROM inventory_items ii "
                + "LEFT JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "LEFT JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN import_receipt_items iri ON ii.receipt_item_id = iri.receipt_item_id "
                + "LEFT JOIN import_receipts ir ON iri.receipt_id = ir.receipt_id "
                + "LEFT JOIN order_items oi ON oi.inventory_id = ii.inventory_id "
                + "LEFT JOIN orders o ON o.order_id = oi.order_id "
                + "LEFT JOIN customers c ON c.customer_id = o.customer_id "
                + "ORDER BY ii.inventory_id DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tìm inventory theo keyword đơn giản (id/variant/imei/status/tên sp/tên
     * khách/sku). Mục tiêu: dễ hiểu, đủ dùng cho trang quản lý.
     */
    public List<InventoryItem> searchInventory(String keyword) {
        List<InventoryItem> list = new ArrayList<>();
        String k = (keyword == null) ? "" : keyword.trim();
        if (k.isEmpty()) {
            return getAllInventory();
        }
        if (conn == null) {
            return list;
        }

        String sql = "SELECT ii.*, "
                + "p.name AS product_name, "
                + "c.full_name AS buyer_name, "
                + "pv.sku AS sku, "
                + "ir.receipt_code AS receipt_code "
                + "FROM inventory_items ii "
                + "LEFT JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "LEFT JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN import_receipt_items iri ON ii.receipt_item_id = iri.receipt_item_id "
                + "LEFT JOIN import_receipts ir ON iri.receipt_id = ir.receipt_id "
                + "LEFT JOIN order_items oi ON oi.inventory_id = ii.inventory_id "
                + "LEFT JOIN orders o ON o.order_id = oi.order_id "
                + "LEFT JOIN customers c ON c.customer_id = o.customer_id "
                + "WHERE CAST(ii.inventory_id AS NVARCHAR(50)) LIKE ? "
                + "OR CAST(ii.variant_id AS NVARCHAR(50)) LIKE ? "
                + "OR ii.serial_id LIKE ? "
                + "OR UPPER(ISNULL(ii.status,'')) LIKE ? "
                + "OR LOWER(ISNULL(p.name,'')) LIKE ? "
                + "OR LOWER(ISNULL(c.full_name,'')) LIKE ? "
                + "OR LOWER(ISNULL(pv.sku,'')) LIKE ? "
                + "ORDER BY ii.inventory_id DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String like = "%" + k + "%";
            String likeUpper = "%" + k.toUpperCase() + "%";
            String likeLower = "%" + k.toLowerCase() + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setString(4, likeUpper);
            ps.setString(5, likeLower);
            ps.setString(6, likeLower);
            ps.setString(7, likeLower);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private InventoryItem mapRow(ResultSet rs) throws SQLException {
        InventoryItem item = new InventoryItem(
                rs.getInt("inventory_id"),
                rs.getInt("variant_id"),
                rs.getInt("receipt_item_id"),
                rs.getString("serial_id"),
                rs.getDouble("import_price"),
                rs.getString("status")
        );
        // Một số query không join đủ cột -> đọc "best-effort"
        try {
            item.setProductName(rs.getString("product_name"));
        } catch (Exception ignored) {
        }
        try {
            item.setBuyerName(rs.getString("buyer_name"));
        } catch (Exception ignored) {
        }
        try {
            item.setSku(rs.getString("sku"));
        } catch (Exception ignored) {
        }
        try {
            item.setReceiptCode(rs.getString("receipt_code"));
        } catch (Exception ignored) {
        }
        return item;
    }

    /**
     * Lấy inventory theo id.
     */
    public InventoryItem getInventoryById(int id) {
        if (conn == null) {
            return null;
        }
        String sql = "SELECT ii.*, p.name AS product_name, pv.sku AS sku, ir.receipt_code AS receipt_code "
                + "FROM inventory_items ii "
                + "LEFT JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "LEFT JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN import_receipt_items iri ON ii.receipt_item_id = iri.receipt_item_id "
                + "LEFT JOIN import_receipts ir ON iri.receipt_id = ir.receipt_id "
                + "WHERE ii.inventory_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tất cả dòng tồn kho thuộc một phiếu nhập (theo receipt_id), dùng cho
     * trang chi tiết: serial + status theo từng receipt_item.
     */
    public List<InventoryItem> getInventoryByReceiptId(int receiptId) {
        List<InventoryItem> list = new ArrayList<>();
        if (conn == null) {
            return list;
        }
        String sql = "SELECT ii.*, p.name AS product_name, pv.sku AS sku, ir.receipt_code AS receipt_code "
                + "FROM inventory_items ii "
                + "INNER JOIN import_receipt_items iri ON ii.receipt_item_id = iri.receipt_item_id "
                + "LEFT JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "LEFT JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN import_receipts ir ON iri.receipt_id = ir.receipt_id "
                + "WHERE iri.receipt_id = ? "
                + "ORDER BY iri.receipt_item_id ASC, ii.inventory_id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Map receipt_item_id → các bản ghi inventory (serial/status) cho một phiếu
     * nhập.
     */
    public Map<Integer, List<InventoryItem>> getInventoryGroupedByReceiptItemId(int receiptId) {
        Map<Integer, List<InventoryItem>> map = new HashMap<>();
        for (InventoryItem inv : getInventoryByReceiptId(receiptId)) {
            int rid = inv.getReceiptItemId();
            map.computeIfAbsent(rid, k -> new ArrayList<>()).add(inv);
        }
        return map;
    }

    /**
     * Thêm 1 dòng inventory. Serial ID không được trùng.
     */
    public boolean insertInventory(InventoryItem item) {
        if (conn == null || item == null) {
            return false;
        }
        String sql = "INSERT INTO inventory_items (variant_id, receipt_item_id, serial_id, import_price, status) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getVariant_id());
            ps.setInt(2, item.getReceipt_item_id());
            ps.setString(3, item.getSerialId());
            ps.setDouble(4, item.getImport_price());
            ps.setString(5, (item.getStatus() == null || item.getStatus().isEmpty()) ? "IN_STOCK" : item.getStatus());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cập nhật inventory theo inventory_id.
     */
    public boolean updateInventory(InventoryItem item) {
        if (conn == null || item == null) {
            return false;
        }
        String sql = "UPDATE inventory_items SET variant_id=?, receipt_item_id=?, serial_id=?, import_price=?, status=? WHERE inventory_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getVariant_id());
            ps.setInt(2, item.getReceipt_item_id());
            ps.setString(3, item.getSerialId());
            ps.setDouble(4, item.getImport_price());
            ps.setString(5, (item.getStatus() == null || item.getStatus().isEmpty()) ? "IN_STOCK" : item.getStatus());
            ps.setInt(6, item.getInventory_id());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Xóa inventory theo id (hard delete). Lưu ý: có thể fail nếu đang bị FK
     * reference.
     */
    public boolean deleteInventory(int id) {
        if (conn == null) {
            return false;
        }
        String sql = "DELETE FROM inventory_items WHERE inventory_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Xóa toàn bộ inventory_items gắn với 1 receipt_item_id (dùng khi xóa dòng
     * phiếu nhập).
     */
    public int deleteByReceiptItemId(int receiptItemId) {
        if (conn == null) {
            return 0;
        }
        String sql = "DELETE FROM inventory_items WHERE receipt_item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiptItemId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Kiểm tra xem receipt_item_id có inventory nào KHÔNG còn IN_STOCK hay
     * không. Trả về true nếu có ít nhất 1 bản ghi khác IN_STOCK (đã bán /
     * reserved...).
     */
    public boolean hasNonInStockByReceiptItemId(int receiptItemId) {
        if (conn == null) {
            return true;
        }
        String sql = "SELECT TOP 1 1 FROM inventory_items WHERE receipt_item_id = ? AND status <> 'IN_STOCK'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiptItemId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return true; // an toàn: nếu lỗi thì coi như có ràng buộc, không cho xóa
        }
    }

    /**
     * Lấy danh sách inventory_id còn tồn (IN_STOCK) theo variant_id, giới hạn
     * số lượng. Dùng khi tạo đơn hàng để gán sản phẩm từ kho vào order_items.
     */
    public List<Integer> getAvailableInventoryIdsByVariantId(int variantId, int limit) {
        List<Integer> list = new ArrayList<>();
        if (conn == null) {
            return list;
        }
        String sql = "SELECT TOP (?) ii.inventory_id "
                + "FROM inventory_items ii "
                + "WHERE ii.variant_id = ? "
                + "AND ii.status = 'IN_STOCK' "
                + "AND ii.inventory_id NOT IN ( "
                + "  SELECT oi.inventory_id FROM order_items oi "
                + "  JOIN orders o ON oi.order_id = o.order_id "
                + "  WHERE UPPER(o.status) != 'CANCELLED' "
                + ") "
                + "ORDER BY ii.inventory_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("inventory_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm số lượng tồn kho hiện tại (IN_STOCK) theo variant_id.
     */
    public int countAvailableByVariantId(int variantId) {
        if (conn == null) {
            return 0;
        }
        String sql = "SELECT COUNT(*) FROM inventory_items WHERE variant_id = ? AND status = 'IN_STOCK'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countByReceiptItemId(int receiptItemId) {
        if (conn == null) {
            return 0;
        }
        String sql = "SELECT COUNT(*) FROM inventory_items WHERE receipt_item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiptItemId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean existsByImei(String imei) {
        if (conn == null) {
            return true;
        }
        String sql = "SELECT TOP 1 1 FROM inventory_items WHERE serial_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, imei);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return true;
        }
    }

    /**
     * Cập nhật trạng thái tồn kho (vd: SOLD sau khi bán).
     */
    public boolean updateStatus(int inventoryId, String status) {
        if (conn == null) {
            return false;
        }
        String sql = "UPDATE inventory_items SET status = ? WHERE inventory_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status == null ? "IN_STOCK" : status);
            ps.setInt(2, inventoryId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private boolean isValidStandardSerial(String serial) {
        return serial != null && serial.matches("^SN-\\d{9}$");
    }

    private String generateStandardSerial(Set<String> usedInBatch) {
        while (true) {
            int number = (int) (Math.random() * 1_000_000_000);
            String serial = String.format("SN-%09d", number);
            if (usedInBatch.contains(serial)) {
                continue;
            }
            if (!existsByImei(serial)) {
                usedInBatch.add(serial);
                return serial;
            }
        }
    }

    /**
     * Tạo inventory_items từ receipt items khi confirm phiếu nhập. Hỗ trợ
     * truyền serial thủ công theo từng receipt_item_id, phần còn lại sẽ tự sinh
     * theo chuẩn SN-123456789.
     */
    public int generateInventoryFromReceiptWithManualSerials(int receiptId, Map<Integer, List<String>> manualSerialsByReceiptItem) {
        if (conn == null || receiptId <= 0) {
            return 0;
        }
        int inserted = 0;
        Set<String> usedInBatch = new HashSet<>();
        String sql = "SELECT receipt_item_id, variant_id, import_price, quantity "
                + "FROM import_receipt_items WHERE receipt_id = ? ORDER BY receipt_item_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int receiptItemId = rs.getInt("receipt_item_id");
                    int variantId = rs.getInt("variant_id");
                    double importPrice = rs.getDouble("import_price");
                    int qty = rs.getInt("quantity");

                    List<String> manualList = manualSerialsByReceiptItem == null
                            ? null
                            : manualSerialsByReceiptItem.get(receiptItemId);
                    int manualCount = (manualList == null) ? 0 : manualList.size();

                    for (int i = 0; i < qty; i++) {
                        String serial;
                        if (i < manualCount) {
                            serial = manualList.get(i);
                            if (!isValidStandardSerial(serial) || usedInBatch.contains(serial) || existsByImei(serial)) {
                                continue;
                            }
                            usedInBatch.add(serial);
                        } else {
                            serial = generateStandardSerial(usedInBatch);
                        }
                        InventoryItem item = new InventoryItem(0, variantId, receiptItemId, serial, importPrice, "IN_STOCK");
                        if (insertInventory(item)) {
                            inserted++;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return inserted;
    }

    /**
     * Tạo inventory_items từ receipt items khi confirm phiếu nhập.
     */
    public int generateInventoryFromReceipt(int receiptId) {
        return generateInventoryFromReceiptWithManualSerials(receiptId, null);
    }

    /**
     * Thống kê số lượng tồn kho theo trạng thái để hiển thị donut chart trên
     * dashboard staff. Kết quả: [inStock, sold, other].
     */
    public int[] getInventoryStatusCounts() {
        if (conn == null) {
            return new int[]{0, 0, 0};
        }
        String sql = "SELECT "
                + "SUM(CASE WHEN status = 'IN_STOCK' THEN 1 ELSE 0 END) AS in_stock, "
                + "SUM(CASE WHEN status = 'SOLD' THEN 1 ELSE 0 END) AS sold, "
                + "SUM(CASE WHEN status NOT IN ('IN_STOCK', 'SOLD') THEN 1 ELSE 0 END) AS other "
                + "FROM inventory_items";
        int inStock = 0;
        int sold = 0;
        int other = 0;
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                inStock = rs.getInt("in_stock");
                sold = rs.getInt("sold");
                other = rs.getInt("other");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new int[]{inStock, sold, other};
    }

    /**
     * Summary nhập / bán / tồn theo variant (1 dòng / variant).
     */
    public List<InventorySummary> getInventorySummary() {
        List<InventorySummary> list = new ArrayList<>();
        if (conn == null) {
            return list;
        }
        String sql = "SELECT "
                + "pv.variant_id, "
                + "p.name AS product_name, "
                + "pv.sku, "
                + "COUNT(*) AS imported, "
                + "SUM(CASE WHEN ii.status = 'SOLD' THEN 1 ELSE 0 END) AS sold, "
                + "SUM(CASE WHEN ii.status = 'REVERSED' THEN 1 ELSE 0 END) AS reversed, "
                + "SUM(CASE WHEN ii.status = 'IN_STOCK' THEN 1 ELSE 0 END) AS in_stock "
                + "FROM inventory_items ii "
                + "JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "GROUP BY pv.variant_id, p.name, pv.sku "
                + "ORDER BY p.name, pv.sku";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new InventorySummary(
                        rs.getInt("variant_id"),
                        rs.getString("product_name"),
                        rs.getString("sku"),
                        rs.getInt("imported"),
                        rs.getInt("sold"),
                        rs.getInt("reversed"),
                        rs.getInt("in_stock")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<InventorySummary> getInventorySummaryByKeyword(String keyword) {
        List<InventorySummary> list = new ArrayList<>();
        if (conn == null) {
            return list;
        }
        String k = keyword == null ? "" : keyword.trim();
        if (k.isEmpty()) {
            return getInventorySummary();
        }
        String sql = "SELECT "
                + "pv.variant_id, "
                + "p.name AS product_name, "
                + "pv.sku, "
                + "COUNT(*) AS imported, "
                + "SUM(CASE WHEN ii.status = 'SOLD' THEN 1 ELSE 0 END) AS sold, "
                + "SUM(CASE WHEN ii.status = 'REVERSED' THEN 1 ELSE 0 END) AS reversed, "
                + "SUM(CASE WHEN ii.status = 'IN_STOCK' THEN 1 ELSE 0 END) AS in_stock "
                + "FROM inventory_items ii "
                + "JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE LOWER(ISNULL(p.name,'')) LIKE ? "
                + "   OR LOWER(ISNULL(pv.sku,'')) LIKE ? "
                + "   OR CAST(pv.variant_id AS NVARCHAR(50)) LIKE ? "
                + "GROUP BY pv.variant_id, p.name, pv.sku "
                + "ORDER BY p.name, pv.sku";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String likeLower = "%" + k.toLowerCase() + "%";
            String like = "%" + k + "%";
            ps.setString(1, likeLower);
            ps.setString(2, likeLower);
            ps.setString(3, like);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new InventorySummary(
                            rs.getInt("variant_id"),
                            rs.getString("product_name"),
                            rs.getString("sku"),
                            rs.getInt("imported"),
                            rs.getInt("sold"),
                            rs.getInt("reversed"),
                            rs.getInt("in_stock")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
