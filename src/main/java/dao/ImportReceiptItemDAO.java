/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.ImportReceiptItem;
import utils.DBContext;

/**
 * @author LE HOANG NHAN
 */

public class ImportReceiptItemDAO extends DBContext {

    private String itemsTable;

    // Hỏi cơ sở dữ liệu xem bảng dòng phiếu tên chính xác là gì, nhớ lại lần sau khỏi hỏi lại.
    private String resolveItemsTable() {
        if (itemsTable != null) {
            return itemsTable;
        }
        itemsTable = "import_receipt_items";
        try {
            DatabaseMetaData meta = conn.getMetaData();
            String[] candidates = {"import_receipt_items", "import_receipt_item"};
            for (String candidate : candidates) {
                try (ResultSet rs = meta.getTables(null, null, candidate, new String[]{"TABLE"})) {
                    if (rs.next()) {
                        itemsTable = rs.getString("TABLE_NAME");
                        return itemsTable;
                    }
                }
                try (ResultSet rs = meta.getTables(null, null, candidate.toUpperCase(), new String[]{"TABLE"})) {
                    if (rs.next()) {
                        itemsTable = rs.getString("TABLE_NAME");
                        return itemsTable;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return itemsTable;
    }

    // Lấy hết các dòng hàng thuộc một phiếu nhập (theo mã phiếu). Dùng ở trang chi tiết phiếu và lúc nhập số seri trước khi xác nhận.
    public List<ImportReceiptItem> getItemsByReceiptId(int receiptId) {
        List<ImportReceiptItem> list = new ArrayList<>();
        String sql = "SELECT * FROM " + resolveItemsTable() + " WHERE receipt_id = ? ORDER BY receipt_item_id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ImportReceiptItem(
                            rs.getInt("receipt_item_id"),
                            rs.getInt("receipt_id"),
                            rs.getInt("variant_id"),
                            rs.getDouble("import_price"),
                            rs.getInt("quantity")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Khi form không chọn dòng phiếu cụ thể thì lấy mã dòng đầu tiên trong hệ thống; không có thì trả về 0.
    public int getFirstReceiptItemId() {
        String sql = "SELECT TOP 1 receipt_item_id FROM " + resolveItemsTable() + " ORDER BY receipt_item_id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt("receipt_item_id");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Lấy đúng một dòng hàng theo mã số dòng (để sửa hoặc xóa dòng đó).
    public ImportReceiptItem getItemById(int id) {
        String sql = "SELECT * FROM " + resolveItemsTable() + " WHERE receipt_item_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new ImportReceiptItem(
                        rs.getInt("receipt_item_id"),
                        rs.getInt("receipt_id"),
                        rs.getInt("variant_id"),
                        rs.getDouble("import_price"),
                        rs.getInt("quantity")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Cùng một phiếu và cùng một biến thể sản phẩm thì lấy một dòng đại diện (dòng đầu tiên). Dùng để kiểm tra đã có dòng chưa hoặc so giá nhập.
    public ImportReceiptItem getFirstItemByReceiptAndVariant(int receiptId, int variantId) {
        String sql = "SELECT TOP 1 receipt_item_id, receipt_id, variant_id, import_price, quantity "
                + "FROM " + resolveItemsTable()
                + " WHERE receipt_id = ? AND variant_id = ? ORDER BY receipt_item_id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiptId);
            ps.setInt(2, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new ImportReceiptItem(
                            rs.getInt("receipt_item_id"),
                            rs.getInt("receipt_id"),
                            rs.getInt("variant_id"),
                            rs.getDouble("import_price"),
                            rs.getInt("quantity")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Khi nhân viên thêm hàng: trước hết thử cộng thêm số lượng vào dòng đã có; nếu chưa có dòng thì chèn dòng mới.
    // Gói trong một giao dịch để tránh lưu dở. Số lượng không dương thì không làm gì.
    public void mergeOrInsertLine(int receiptId, int variantId, double importPrice, int qty) {
        if (qty <= 0) {
            return;
        }
        boolean oldAutoCommit = true;
        try {
            oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);

            // Ưu tiên cộng số lượng vào dòng đã có cùng sản phẩm trên phiếu.
            String updateSql = "UPDATE " + resolveItemsTable()
                    + " SET quantity = quantity + ? WHERE receipt_id = ? AND variant_id = ?";
            int updatedRows;
            try (PreparedStatement u = conn.prepareStatement(updateSql)) {
                u.setInt(1, qty);
                u.setInt(2, receiptId);
                u.setInt(3, variantId);
                updatedRows = u.executeUpdate();
            }

            if (updatedRows == 0) {
                String insertSql = "INSERT INTO " + resolveItemsTable()
                        + " (receipt_id, variant_id, import_price, quantity) VALUES (?, ?, ?, ?)";
                try (PreparedStatement i = conn.prepareStatement(insertSql)) {
                    i.setInt(1, receiptId);
                    i.setInt(2, variantId);
                    i.setDouble(3, importPrice);
                    i.setInt(4, qty);
                    i.executeUpdate();
                }
            }

            conn.commit();
        } catch (Exception e) {
            try {
                conn.rollback();
            } catch (Exception ignored) {
            }
            e.printStackTrace();
        } finally {
            try {
                conn.setAutoCommit(oldAutoCommit);
            } catch (Exception ignored) {
            }
        }
    }

    // Cập nhật toàn bộ thông tin một dòng khi người dùng sửa trực tiếp trên giao diện (khác với cộng dồn số lượng).
    public void updateItem(ImportReceiptItem item) {
        String sql = "UPDATE " + resolveItemsTable() + " SET receipt_id=?, variant_id=?, import_price=?, quantity=? WHERE receipt_item_id=?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, item.getReceipt_id());
            ps.setInt(2, item.getVariant_id());
            ps.setDouble(3, item.getImport_price());
            ps.setInt(4, item.getQuantity());
            ps.setInt(5, item.getReceipt_item_id());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Xóa một dòng phiếu. Nếu đã có bản ghi tồn kho gắn với dòng này thì có thể xóa không được; lớp điều khiển cần xóa tồn kho trước.
    public boolean deleteItem(int id) {
        String sql = "DELETE FROM " + resolveItemsTable() + " WHERE receipt_item_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

}
