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
 * @author LE HOANG NHAN
 */
public class InventoryItemDAO extends DBContext {

    // Danh sách toàn bộ tồn kho cho nhân viên; ghép lỏng để không mất dòng khi thiếu liên kết phụ.
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

    // Tìm theo tên sản phẩm gần đúng; không nhập gì thì trả về như lấy hết danh sách.
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
                + "WHERE LOWER(ISNULL(p.name,'')) LIKE ? "
                + "ORDER BY ii.inventory_id DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String likeLower = "%" + k.toLowerCase() + "%";
            ps.setString(1, likeLower);
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

    // Chuyển một dòng kết quả truy vấn thành đối tượng tồn kho; cột phụ có thể không có nên đọc từng cột an toàn.
    private InventoryItem mapRow(ResultSet rs) throws SQLException {
        InventoryItem item = new InventoryItem(
                rs.getInt("inventory_id"),
                rs.getInt("variant_id"),
                rs.getInt("receipt_item_id"),
                rs.getString("serial_id"),
                rs.getDouble("import_price"),
                rs.getString("status")
        );
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

    // Lấy một bản ghi tồn kho theo mã số nội bộ.
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

    // Mọi chiếc hàng đã nhập thuộc một phiếu nhập; dùng ở trang chi tiết phiếu, gom theo từng dòng hàng.
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

    // Gom danh sách trên theo từng dòng phiếu nhập để giao diện hiển thị từng dòng và các seri bên dưới.
    public Map<Integer, List<InventoryItem>> getInventoryGroupedByReceiptItemId(int receiptId) {
        Map<Integer, List<InventoryItem>> map = new HashMap<>();
        for (InventoryItem inv : getInventoryByReceiptId(receiptId)) {
            int rid = inv.getReceiptItemId();
            map.computeIfAbsent(rid, k -> new ArrayList<>()).add(inv);
        }
        return map;
    }

    // Thêm một chiếc vào tồn kho; số seri không được trùng trong cơ sở dữ liệu, trùng thì thêm thất bại.
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

    // Cập nhật thông tin một bản ghi tồn kho theo mã nội bộ của nó.
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

    // Xóa hẳn một bản ghi tồn kho; nếu đã gắn vào đơn hàng có thể không xóa được.
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

    // Xóa hết các chiếc tồn kho thuộc một dòng trên phiếu nhập; thường làm trước khi xóa dòng đó khỏi phiếu.
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

    // Trả về đúng nếu có ít nhất một chiếc không còn trạng thái đang nằm trong kho (ví dụ đã bán); khi đó không nên xóa dòng phiếu.
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
            return true; // Nếu truy vấn lỗi thì coi như có ràng buộc để tránh xóa nhầm.
        }
    }

    // Lấy tối đa một số mã tồn kho đang còn trong kho và chưa gắn đơn chưa hủy; dùng khi tạo đơn để gán chiếc cụ thể.
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

    // Đếm số chiếc còn trong kho theo biến thể; kiểm tra giỏ hàng hoặc đặt hàng không vượt quá.
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

    // Đếm đã tạo bao nhiêu bản ghi tồn kho cho một dòng phiếu; so với số lượng trên dòng để biết đã đủ seri chưa.
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

    // Kiểm tra số seri đã có trong tồn kho chưa. Tên hàm giữ từ phiên bản cũ; tham số thực chất là chuỗi seri. Lỗi kết nối thì coi như đã tồn tại để an toàn.
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

    // Đổi trạng thái một chiếc (ví dụ sang đã bán sau khi thanh toán xong).
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

    // Seri nhập tay hợp lệ theo đúng mẫu quy định trong biểu thức kiểm tra (tiền tố cố định và chín chữ số).
    private boolean isValidStandardSerial(String serial) {
        return serial != null && serial.matches("^SN-\\d{9}$");
    }

    // Tạo seri ngẫu nhiên theo mẫu chuẩn, không trùng trong đợt đang nhập và không trùng trong cơ sở dữ liệu.
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

    // Khi xác nhận phiếu nhập: với mỗi dòng hàng, mỗi đơn vị số lượng tạo một bản ghi tồn kho.
    // Seri nhập tay theo danh sách gửi vào; thiếu thì tự sinh theo mẫu chuẩn. Seri sai định dạng hoặc trùng thì bỏ qua ô đó.
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

    // Xác nhận phiếu và tạo tồn kho khi không có danh sách seri nhập tay.
    public int generateInventoryFromReceipt(int receiptId) {
        return generateInventoryFromReceiptWithManualSerials(receiptId, null);
    }

    // Thống kê ba con số cho biểu đồ: đang trong kho, đã bán, các trạng thái khác.
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

    // Tổng hợp theo từng biến thể: đã nhập, đã bán, đang giữ chỗ, còn trong kho.
    public List<InventorySummary> getInventorySummary() {
        List<InventorySummary> list = new ArrayList<>();
        if (conn == null) {
            return list;
        }
        // Cột giữ chỗ gom cả trạng thái giữ chỗ và tên cũ viết sai để không mất số liệu cũ.
        String sql = "SELECT "
                + "pv.variant_id, "
                + "p.name AS product_name, "
                + "pv.sku, "
                + "COUNT(*) AS imported, "
                + "SUM(CASE WHEN ii.status = 'SOLD' THEN 1 ELSE 0 END) AS sold, "
                + "SUM(CASE WHEN ii.status IN ('RESERVED', 'REVERSED') THEN 1 ELSE 0 END) AS reversed, "
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

    // Giống tổng hợp trên nhưng lọc theo tên sản phẩm, mã biến thể hoặc mã số biến thể.
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
                + "SUM(CASE WHEN ii.status IN ('RESERVED', 'REVERSED') THEN 1 ELSE 0 END) AS reversed, "
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
