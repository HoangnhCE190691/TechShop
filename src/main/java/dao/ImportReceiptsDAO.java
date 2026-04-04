/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import model.ImportReceipts;
import utils.DBContext;

/**
 * @author LE HOANG NHAN
 */
public class ImportReceiptsDAO extends DBContext {

    private String totalCostColumn;
    private String receiptsTable;
    private String receiptItemsTable;
    private Boolean createdAtIsIntType;

    // Xác định tên bảng lưu đầu phiếu nhập trong cơ sở dữ liệu.
    private String resolveReceiptsTable() {
        if (receiptsTable != null) {
            return receiptsTable;
        }
        receiptsTable = "import_receipts";
        try {
            DatabaseMetaData meta = conn.getMetaData();
            String[] candidates = {"import_receipts", "import_receipt"};
            for (String candidate : candidates) {
                try (ResultSet rs = meta.getTables(null, null, candidate, new String[]{"TABLE"})) {
                    if (rs.next()) {
                        receiptsTable = rs.getString("TABLE_NAME");
                        return receiptsTable;
                    }
                }
                try (ResultSet rs = meta.getTables(null, null, candidate.toUpperCase(), new String[]{"TABLE"})) {
                    if (rs.next()) {
                        receiptsTable = rs.getString("TABLE_NAME");
                        return receiptsTable;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return receiptsTable;
    }

    // Xác định tên bảng các dòng hàng trên phiếu (dùng khi cần cộng tiền từ các dòng).
    private String resolveReceiptItemsTable() {
        if (receiptItemsTable != null) {
            return receiptItemsTable;
        }
        receiptItemsTable = "import_receipt_items";
        try {
            DatabaseMetaData meta = conn.getMetaData();
            String[] candidates = {"import_receipt_items", "import_receipt_item"};
            for (String candidate : candidates) {
                try (ResultSet rs = meta.getTables(null, null, candidate, new String[]{"TABLE"})) {
                    if (rs.next()) {
                        receiptItemsTable = rs.getString("TABLE_NAME");
                        return receiptItemsTable;
                    }
                }
                try (ResultSet rs = meta.getTables(null, null, candidate.toUpperCase(), new String[]{"TABLE"})) {
                    if (rs.next()) {
                        receiptItemsTable = rs.getString("TABLE_NAME");
                        return receiptItemsTable;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return receiptItemsTable;
    }

    // Thử từng tên cột có thể có, trả về tên cột thật sự tồn tại trong bảng.
    private String resolveColumn(String... candidates) {
        String table = resolveReceiptsTable();
        try {
            DatabaseMetaData meta = conn.getMetaData();
            for (String candidate : candidates) {
                try (ResultSet rs = meta.getColumns(null, null, table, candidate)) {
                    if (rs.next()) {
                        return rs.getString("COLUMN_NAME");
                    }
                }
                try (ResultSet rs = meta.getColumns(null, null, table.toUpperCase(), candidate.toUpperCase())) {
                    if (rs.next()) {
                        return rs.getString("COLUMN_NAME");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return candidates[0];
    }

    // Các hàm sau chỉ trả về tên cột đúng trong bảng (mã phiếu, nhà cung cấp, nhân viên, ngày, ghi chú).
    private String receiptIdCol() {
        return resolveColumn("receipt_id", "receiptId", "id");
    }

    private String supplierIdCol() {
        return resolveColumn("supplier_id", "supplierId");
    }

    private String employeeIdCol() {
        return resolveColumn("employee_id", "employeeId", "staff_id", "staffId");
    }

    private String importDateCol() {
        return resolveColumn("import_date", "importDate", "created_at", "createdAt");
    }

    private String receiptCodeCol() {
        return resolveColumn("receipt_code", "receiptCode");
    }

    private String statusCol() {
        return resolveColumn("status");
    }

    private String noteCol() {
        return resolveColumn("note");
    }

    private String createdByCol() {
        return resolveColumn("created_by", "createdBy");
    }

    private String createdAtCol() {
        return resolveColumn("created_at", "createdAt");
    }

    // Kiểm tra cột thời điểm tạo có phải kiểu số nguyên không (một số bản thiết kế lưu dạng năm tháng ngày gộp).
    private boolean isCreatedAtIntType() {
        if (createdAtIsIntType != null) {
            return createdAtIsIntType;
        }
        createdAtIsIntType = false;
        String table = resolveReceiptsTable();
        String col = createdAtCol();
        try {
            DatabaseMetaData meta = conn.getMetaData();
            try (ResultSet rs = meta.getColumns(null, null, table, col)) {
                if (rs.next()) {
                    String type = rs.getString("TYPE_NAME");
                    createdAtIsIntType = type != null && type.toUpperCase().contains("INT");
                    return createdAtIsIntType;
                }
            }
            try (ResultSet rs = meta.getColumns(null, null, table.toUpperCase(), col.toUpperCase())) {
                if (rs.next()) {
                    String type = rs.getString("TYPE_NAME");
                    createdAtIsIntType = type != null && type.toUpperCase().contains("INT");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return createdAtIsIntType;
    }

    // Đọc thời điểm tạo: nếu trong bảng là số nguyên tám chữ số năm-tháng-ngày thì đổi sang dạng thời gian đầy đủ.
    private Timestamp readCreatedAt(ResultSet rs) throws Exception {
        if (!isCreatedAtIntType()) {
            return rs.getTimestamp("created_at");
        }
        int raw = rs.getInt("created_at");
        if (raw <= 0) {
            return null;
        }
        String s = String.valueOf(raw);
        if (s.length() == 8) {
            int y = Integer.parseInt(s.substring(0, 4));
            int m = Integer.parseInt(s.substring(4, 6));
            int d = Integer.parseInt(s.substring(6, 8));
            return Timestamp.valueOf(String.format("%04d-%02d-%02d 00:00:00", y, m, d));
        }
        return null;
    }

    // Xác định tên cột lưu tổng tiền trên bảng đầu phiếu (nếu có).
    private String resolveTotalCostColumn() {
        if (totalCostColumn != null) {
            return totalCostColumn;
        }
        totalCostColumn = resolveColumn("total_cost", "totalCost");
        return totalCostColumn;
    }

    // Có cột tổng tiền thật trên bảng đầu phiếu hay không; nếu không thì chỉ tính khi truy vấn.
    private boolean hasRealTotalCostColumn() {
        String col = resolveTotalCostColumn();
        return !"total_cost".equals(col) && !"totalCost".equals(col) ? true : hasColumn("total_cost", "totalCost");
    }

    // Kiểm tra trong bảng đầu phiếu có tồn tại một trong các tên cột cho trước hay không.
    private boolean hasColumn(String... candidates) {
        String table = resolveReceiptsTable();
        try {
            DatabaseMetaData meta = conn.getMetaData();
            for (String candidate : candidates) {
                try (ResultSet rs = meta.getColumns(null, null, table, candidate)) {
                    if (rs.next()) {
                        return true;
                    }
                }
                try (ResultSet rs = meta.getColumns(null, null, table.toUpperCase(), candidate.toUpperCase())) {
                    if (rs.next()) {
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Ghép câu truy vấn lấy phiếu, luôn đặt tên cột kết quả thống nhất để hàm đọc kết quả dễ xử lý.
    private String buildSelectBase() {
        String totalExpr = hasRealTotalCostColumn()
                ? resolveTotalCostColumn()
                : "(SELECT COALESCE(SUM(i.import_price * i.quantity), 0) FROM " + resolveReceiptItemsTable()
                + " i WHERE i.receipt_id = " + resolveReceiptsTable() + "." + receiptIdCol() + ")";
        return "SELECT "
                + receiptIdCol() + " AS receipt_id, "
                + receiptCodeCol() + " AS receipt_code, "
                + supplierIdCol() + " AS supplier_id, "
                + employeeIdCol() + " AS employee_id, "
                + totalExpr + " AS total_cost, "
                + importDateCol() + " AS import_date, "
                + statusCol() + " AS status, "
                + noteCol() + " AS note, "
                + createdByCol() + " AS created_by, "
                + createdAtCol() + " AS created_at "
                + "FROM " + resolveReceiptsTable();
    }

    // Chuyển một dòng kết quả truy vấn thành đối tượng phiếu nhập trong chương trình.
    private ImportReceipts mapReceipt(ResultSet rs) throws Exception {
        ResultSetMetaData md = rs.getMetaData();
        if (md.getColumnCount() >= 5) {
            return new ImportReceipts(
                    rs.getInt("receipt_id"),
                    rs.getInt("supplier_id"),
                    rs.getInt("employee_id"),
                    rs.getDouble("total_cost"),
                    rs.getTimestamp("import_date"),
                    rs.getString("receipt_code"),
                    rs.getString("status"),
                    rs.getString("note"),
                    rs.getInt("created_by"),
                    readCreatedAt(rs)
            );
        }
        throw new IllegalArgumentException("ResultSet is missing expected columns for import receipt.");
    }

    // Lấy danh sách tất cả phiếu nhập (bảng điều khiển hoặc màn hình quản lý).
    public List<ImportReceipts> getAllReceipts() {
        List<ImportReceipts> list = new ArrayList<>();
        String sql = buildSelectBase();
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapReceipt(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy một phiếu theo mã số (xem chi tiết, xác nhận, sửa phần đầu phiếu...).
    public ImportReceipts getReceiptById(int id) {
        String sql = buildSelectBase() + " WHERE " + receiptIdCol() + " = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapReceipt(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Thêm phiếu mới (thường ở trạng thái nháp), trả về mã phiếu vừa tạo để chuyển sang trang chi tiết.
    public int insertReceiptReturnId(ImportReceipts p) {
        String sql = "INSERT INTO " + resolveReceiptsTable()
                + " (" + supplierIdCol() + ", " + employeeIdCol()
                + (hasRealTotalCostColumn() ? ", " + resolveTotalCostColumn() : "")
                + ", " + importDateCol()
                + ", " + receiptCodeCol()
                + ", " + statusCol()
                + ", " + createdByCol()
                + ", " + createdAtCol()
                + ") VALUES (?, ?"
                + (hasRealTotalCostColumn() ? ", ?" : "")
                + ", ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, p.getSupplier_id());
            ps.setInt(2, p.getEmployee_id());
            int idx = 3;
            if (hasRealTotalCostColumn()) {
                ps.setDouble(idx++, p.getTotal_cost());
            }
            java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
            ps.setTimestamp(idx++, p.getImport_date() != null ? p.getImport_date() : now);
            String rc = generateNextReceiptCode();
            ps.setString(idx++, rc);
            ps.setString(idx++, (p.getStatus() == null || p.getStatus().isBlank()) ? "DRAFT" : p.getStatus());
            ps.setInt(idx++, p.getCreated_by() > 0 ? p.getCreated_by() : p.getEmployee_id());
            if (isCreatedAtIntType()) {
                Timestamp v = p.getCreated_at() != null ? p.getCreated_at() : now;
                int ymd = Integer.parseInt(new java.text.SimpleDateFormat("yyyyMMdd").format(v));
                ps.setInt(idx, ymd);
            } else {
                ps.setTimestamp(idx, p.getCreated_at() != null ? p.getCreated_at() : now);
            }
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Tạo mã phiếu theo tháng hiện tại, bốn số thứ tự tăng dần; bỏ qua mã cũ không đọc được số.
    private String generateNextReceiptCode() {
        LocalDate now = LocalDate.now();
        String ym = now.format(DateTimeFormatter.ofPattern("yyyyMM"));
        String prefix = "PN-" + ym + "-";
        String sql = "SELECT COALESCE(MAX(TRY_CAST(RIGHT(" + receiptCodeCol() + ", 4) AS INT)), 0) AS max_no "
                + "FROM " + resolveReceiptsTable() + " WHERE " + receiptCodeCol() + " LIKE ?";
        int next = 1;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, prefix + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    next = rs.getInt("max_no") + 1;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return prefix + String.format("%04d", next);
    }

    // Cập nhật phần đầu phiếu (sau khi đã xác nhận thường ít chỉnh).
    public void updateReceipt(ImportReceipts p) {
        String sql = "UPDATE " + resolveReceiptsTable()
                + " SET " + supplierIdCol() + "=?, " + employeeIdCol() + "=?"
                + (hasRealTotalCostColumn() ? ", " + resolveTotalCostColumn() + "=?" : "")
                + ", " + receiptCodeCol() + "=?"
                + ", " + statusCol() + "=?"
                + ", " + noteCol() + "=?"
                + " WHERE " + receiptIdCol() + "=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getSupplier_id());
            ps.setInt(2, p.getEmployee_id());
            int idx = 3;
            if (hasRealTotalCostColumn()) {
                ps.setDouble(idx++, p.getTotal_cost());
            }
            ps.setString(idx++, p.getReceipt_code());
            ps.setString(idx++, p.getStatus());
            ps.setString(idx++, p.getNote());
            ps.setInt(idx, p.getReceipt_id());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Nếu bảng có cột tổng tiền thì ghi lại bằng tổng tiền các dòng hàng; gọi sau khi thêm, sửa hoặc xóa dòng.
    public void recalculateTotalCost(int receiptId) {
        if (!hasRealTotalCostColumn()) {
            return;
        }
        String sql = """
                UPDATE %s
                SET %s = (
                    SELECT COALESCE(SUM(import_price * quantity), 0)
                    FROM %s
                    WHERE receipt_id = ?
                )
                WHERE %s = ?
                """.formatted(resolveReceiptsTable(), resolveTotalCostColumn(), resolveReceiptItemsTable(), receiptIdCol());
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiptId);
            ps.setInt(2, receiptId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Xóa bản ghi đầu phiếu. Nên xóa hết dòng hàng và tồn kho liên quan trước nếu không muốn bị chặn bởi ràng buộc dữ liệu.
    public boolean deleteReceipt(int id) {
        String sql = "DELETE FROM " + resolveReceiptsTable() + " WHERE " + receiptIdCol() + " = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
