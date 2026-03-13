/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.InventoryItem;
import utils.DBContext;

/**
 *
 * @author LE HOANG NHAN
 */
public class InventoryItemDAO extends DBContext {

    // 1. GET ALL (kèm tên sản phẩm từ product_variants + products)
    public List<InventoryItem> getAllInventory() {
        List<InventoryItem> list = new ArrayList<>();
        String sql = """
            SELECT ii.*,
                   p.name       AS product_name,
                   c.full_name  AS buyer_name
            FROM inventory_items ii
            LEFT JOIN product_variants pv ON ii.variant_id = pv.variant_id
            LEFT JOIN products p         ON pv.product_id = p.product_id
            LEFT JOIN order_items oi     ON oi.inventory_id = ii.inventory_id
            LEFT JOIN orders o           ON o.order_id = oi.order_id
            LEFT JOIN customers c        ON c.customer_id = o.customer_id
            ORDER BY ii.inventory_id DESC
            """;
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 1.1 SEARCH (by IMEI / status / IDs)
    public List<InventoryItem> searchInventory(String keyword) {
        List<InventoryItem> list = new ArrayList<>();
        String k = (keyword == null) ? "" : keyword.trim();
        if (k.isEmpty()) {
            return getAllInventory();
        }

        String sql = """
            SELECT ii.*,
                   p.name      AS product_name,
                   c.full_name AS buyer_name
            FROM inventory_items ii
            LEFT JOIN product_variants pv ON ii.variant_id = pv.variant_id
            LEFT JOIN products p         ON pv.product_id = p.product_id
            LEFT JOIN order_items oi     ON oi.inventory_id = ii.inventory_id
            LEFT JOIN orders o           ON o.order_id = oi.order_id
            LEFT JOIN customers c        ON c.customer_id = o.customer_id
            WHERE CAST(ii.inventory_id AS NVARCHAR(50)) LIKE ?
               OR CAST(ii.variant_id AS NVARCHAR(50)) LIKE ?
               OR ii.imei LIKE ?
               OR UPPER(ISNULL(ii.status,'')) LIKE ?
               OR LOWER(ISNULL(p.name,'')) LIKE ?
               OR LOWER(ISNULL(c.full_name,'')) LIKE ?
               OR LOWER(ISNULL(pv.sku,'')) LIKE ?
            ORDER BY ii.inventory_id DESC
            """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String like = "%" + k + "%";
            String likeUpper = "%" + k.toUpperCase() + "%";
            // Product name: flexible pattern (e.g. "iPhone 15 Pro Max" -> "%iphone%15%pro%max%") to handle spacing/formatting
            String productNameLike = "%" + k.toLowerCase().trim().replaceAll("\\s+", "%") + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setString(4, likeUpper);
            ps.setString(5, productNameLike); // product name
            ps.setString(6, productNameLike); // buyer name
            ps.setString(7, productNameLike); // sku (cho phép gõ 1 phần)
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
                rs.getString("imei"),
                rs.getDouble("import_price"),
                rs.getString("status")
        );
        try {
            item.setProductName(rs.getString("product_name"));
        } catch (Exception ignored) {
            /* cột product_name có thể không tồn tại trong một số truy vấn */ }
        try {
            item.setBuyerName(rs.getString("buyer_name"));
        } catch (Exception ignored) {
            /* cột buyer_name có thể không tồn tại hoặc null nếu chưa bán */ }
        return item;
    }

    // 2. GET BY ID
    public InventoryItem getInventoryById(int id) {
        String sql = """
                     SELECT ii.*, p.name AS product_name
                     FROM inventory_items ii
                     LEFT JOIN product_variants pv ON ii.variant_id = pv.variant_id
                     LEFT JOIN products p ON pv.product_id = p.product_id
                     WHERE ii.inventory_id = ?
                     """;
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 3. INSERT (Thêm sản phẩm vào kho)
    // Lưu ý: IMEI không được trùng
    public boolean insertInventory(InventoryItem item) {
        String sql = "INSERT INTO inventory_items (variant_id, receipt_item_id, imei, import_price, status) VALUES (?, ?, ?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, item.getVariant_id());
            ps.setInt(2, item.getReceipt_item_id());
            ps.setString(3, item.getImei());
            ps.setDouble(4, item.getImport_price());
            // Nếu status null thì mặc định set là IN_STOCK
            ps.setString(5, (item.getStatus() == null || item.getStatus().isEmpty()) ? "IN_STOCK" : item.getStatus());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            // In ra lỗi nếu trùng IMEI hoặc sai khóa ngoại
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 4. UPDATE
    public boolean updateInventory(InventoryItem item) {
        String sql = "UPDATE inventory_items SET variant_id=?, receipt_item_id=?, imei=?, import_price=?, status=? WHERE inventory_id=?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, item.getVariant_id());
            ps.setInt(2, item.getReceipt_item_id());
            ps.setString(3, item.getImei());
            ps.setDouble(4, item.getImport_price());
            ps.setString(5, (item.getStatus() == null || item.getStatus().isEmpty()) ? "IN_STOCK" : item.getStatus());
            ps.setInt(6, item.getInventory_id());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 5. DELETE
    public boolean deleteInventory(int id) {
        String sql = "DELETE FROM inventory_items WHERE inventory_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Xóa toàn bộ inventory_items gắn với 1 receipt_item_id (dùng khi xóa dòng phiếu nhập).
     */
    public int deleteByReceiptItemId(int receiptItemId) {
        String sql = "DELETE FROM inventory_items WHERE receipt_item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiptItemId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Kiểm tra xem receipt_item_id có inventory nào KHÔNG còn IN_STOCK hay không.
     * Trả về true nếu có ít nhất 1 bản ghi khác IN_STOCK (đã bán / reserved...).
     */
    public boolean hasNonInStockByReceiptItemId(int receiptItemId) {
        String sql = "SELECT TOP 1 1 FROM inventory_items WHERE receipt_item_id = ? AND status <> 'IN_STOCK'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiptItemId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return true; // an toàn: nếu lỗi thì coi như có ràng buộc, không cho xóa
        } catch (Exception e) {
            e.printStackTrace();
            return true;
        }
    }

    /**
     * Lấy danh sách inventory_id còn tồn (IN_STOCK) theo variant_id, giới hạn số lượng. Dùng khi tạo đơn hàng để gán sản phẩm từ kho vào order_items.
     */
    public List<Integer> getAvailableInventoryIdsByVariantId(int variantId, int limit) {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT TOP (?) inventory_id FROM inventory_items WHERE variant_id = ? AND status = 'IN_STOCK' ORDER BY inventory_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, variantId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getInt("inventory_id"));
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

    /**
     * Cập nhật trạng thái tồn kho (vd: SOLD sau khi bán).
     */
    public boolean updateStatus(int inventoryId, String status) {
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

    // --- MAIN TEST ---
    public static void main(String[] args) {
        InventoryItemDAO dao = new InventoryItemDAO();

        // 1. List All
        System.out.println("--- LIST ALL ---");
        List<InventoryItem> list = dao.getAllInventory();
        for (InventoryItem i : list) {
            System.out.println(i);
        }

        // 2. Insert Test
        // LƯU Ý KHI CHẠY: 
        // - variant_id (số 1 đầu tiên) phải có trong bảng product_variants
        // - receipt_item_id (số 1 thứ hai) phải có trong bảng import_receipt_items
        // - IMEI "IMΕΙ-001" chưa từng tồn tại
        System.out.println("--- INSERT ---");
        InventoryItem newItem = new InventoryItem(0, 1, 1, "IMEI-TEST-001", 15000000, "IN_STOCK");
        dao.insertInventory(newItem);
        System.out.println("Da them san pham vao kho.");

        // 3. Update Test
        // Giả sử update item có ID = 1
        // InventoryItem upItem = new InventoryItem(1, 1, 1, "IMEI-TEST-001", 15000000, "SOLD");
        // dao.updateInventory(upItem);
        // System.out.println("Da update trang thai.");
        // 4. Delete Test
        // dao.deleteInventory(2);
        // System.out.println("Da xoa item ID 2.");
    }
}
