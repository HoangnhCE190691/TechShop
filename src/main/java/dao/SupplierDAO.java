package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Supplier;
import utils.DBContext;

public class SupplierDAO extends DBContext {

    // Khung SELECT dùng chung để đỡ lặp SQL ở nhiều hàm.
    private static final String SQL_SELECT_BASE = "SELECT supplier_id, supplier_name, phone, email, address, is_active";
    private static final String SQL_FROM = " FROM suppliers";

    // SupplierServlet dùng hàm này để báo lỗi sớm khi DB mất kết nối.
    public boolean hasConnection() {
        return conn != null;
    }

    // Lấy toàn bộ nhà cung cấp cho màn hình quản lý.
    // Luôn đọc thêm created_at để hiển thị ngày tạo trên UI.
    public List<Supplier> getAllSuppliers() {
        List<Supplier> list = new ArrayList<>();
        if (conn == null) {
            return list;
        }
        // Lấy thêm created_at để trang list/view hiển thị đúng cột "Date added".
        String sql = SQL_SELECT_BASE + ", created_at" + SQL_FROM;
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Chỉ NCC đang hoạt động — dùng cho chọn NCC khi tạo phiếu nhập (không hiện NCC đã ngưng).
    public List<Supplier> getActiveSuppliers() {
        List<Supplier> list = new ArrayList<>();
        if (conn == null) {
            return list;
        }
        String sql = SQL_SELECT_BASE + ", created_at" + SQL_FROM + " WHERE is_active = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Kiểm tra nhanh có đúng là NCC tồn tại và còn hoạt động không (tạo/sửa phiếu nhập).
    public boolean isSupplierActive(int supplierId) {
        if (conn == null || supplierId <= 0) {
            return false;
        }
        String sql = "SELECT 1 FROM suppliers WHERE supplier_id = ? AND is_active = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Lấy 1 nhà cung cấp theo id để view/edit.
    public Supplier getSupplierById(int id) {
        if (conn == null) {
            return null;
        }
        String sql = SQL_SELECT_BASE + ", created_at" + SQL_FROM + " WHERE supplier_id = ?";
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

    // Kiểm tra trùng "tên + địa chỉ".
    // excludeSupplierId > 0 dùng cho case update để bỏ qua chính bản ghi hiện tại.
    // Chuẩn hóa bằng LOWER/LTRIM/RTRIM để giảm lỗi do khác hoa-thường hoặc khoảng trắng.
    public boolean existsSameNameAndAddress(String trimmedName, String addressRaw, int excludeSupplierId) {
        if (conn == null || trimmedName == null) {
            return false;
        }
        String n = trimmedName.trim();
        if (n.isEmpty()) {
            return false;
        }
        String addrKey = addressRaw == null ? "" : addressRaw.trim();
        String sql = excludeSupplierId > 0
                ? "SELECT 1 FROM suppliers WHERE supplier_id <> ? AND LOWER(LTRIM(RTRIM(supplier_name))) = LOWER(?)"
                + " AND LOWER(LTRIM(RTRIM(ISNULL(address,'')))) = LOWER(?)"
                : "SELECT 1 FROM suppliers WHERE LOWER(LTRIM(RTRIM(supplier_name))) = LOWER(?)"
                + " AND LOWER(LTRIM(RTRIM(ISNULL(address,'')))) = LOWER(?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            if (excludeSupplierId > 0) {
                ps.setInt(1, excludeSupplierId);
                ps.setString(2, n);
                ps.setString(3, addrKey);
            } else {
                ps.setString(1, n);
                ps.setString(2, addrKey);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Kiểm tra email đã tồn tại hay chưa.
    // emailLower đã normalize ở Servlet (trim + lowercase).
    // excludeSupplierId > 0 dùng cho update.
    public boolean existsSupplierEmail(String emailLower, int excludeSupplierId) {
        if (conn == null || emailLower == null || emailLower.isEmpty()) {
            return false;
        }
        String sql = excludeSupplierId > 0
                ? "SELECT 1 FROM suppliers WHERE supplier_id <> ? AND LOWER(LTRIM(RTRIM(ISNULL(email,'')))) = ?"
                : "SELECT 1 FROM suppliers WHERE LOWER(LTRIM(RTRIM(ISNULL(email,'')))) = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            if (excludeSupplierId > 0) {
                ps.setInt(1, excludeSupplierId);
                ps.setString(2, emailLower);
            } else {
                ps.setString(1, emailLower);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Điện thoại đã dùng bởi nhà cung cấp khác (10 chữ số, đã normalize ở servlet).
    public boolean existsSupplierPhone(String phoneDigits, int excludeSupplierId) {
        if (conn == null || phoneDigits == null || phoneDigits.length() != 10) {
            return false;
        }
        String sql = excludeSupplierId > 0
                ? "SELECT 1 FROM suppliers WHERE supplier_id <> ? AND phone = ?"
                : "SELECT 1 FROM suppliers WHERE phone = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            if (excludeSupplierId > 0) {
                ps.setInt(1, excludeSupplierId);
                ps.setString(2, phoneDigits);
            } else {
                ps.setString(1, phoneDigits);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Thêm mới supplier.
    // Email/address rỗng sẽ đổi thành NULL cho dữ liệu sạch hơn.
    // created_at lấy giờ từ DB server để đồng nhất thời gian lưu.
    public boolean insertSupplier(Supplier s) {
        if (conn == null || s == null) {
            return false;
        }
        // Dùng SYSDATETIME() để thời gian tạo luôn theo server DB.
        String sql = "INSERT INTO suppliers (supplier_name, phone, email, address, is_active, created_at) VALUES (?, ?, ?, ?, ?, SYSDATETIME())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getSupplier_name());
            ps.setString(2, s.getPhone());
            ps.setString(3, emptyToNull(s.getEmail()));
            ps.setString(4, emptyToNull(s.getAddress()));
            ps.setBoolean(5, s.getIs_active());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Cập nhật thông tin supplier theo supplier_id.
    public boolean updateSupplier(Supplier s) {
        if (conn == null || s == null) {
            return false;
        }
        String sql = "UPDATE suppliers SET supplier_name = ?, phone = ?, email = ?, address = ?, is_active = ? WHERE supplier_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getSupplier_name());
            ps.setString(2, s.getPhone());
            ps.setString(3, emptyToNull(s.getEmail()));
            ps.setString(4, emptyToNull(s.getAddress()));
            ps.setBoolean(5, s.getIs_active());
            ps.setInt(6, s.getSupplier_id());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Tìm supplier theo tên hoặc số điện thoại cho ô search ở trang danh sách.
    // Nếu keyword rỗng -> trả toàn bộ list để giữ hành vi cũ.
    public List<Supplier> searchSuppliers(String keyword) {
        List<Supplier> list = new ArrayList<>();
        if (conn == null || keyword == null || keyword.trim().isEmpty()) {
            return getAllSuppliers();
        }
        String sql = SQL_SELECT_BASE + ", created_at" + SQL_FROM
                + " WHERE supplier_name LIKE ? OR phone LIKE ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword.trim() + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
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

    // Khóa supplier ở mức nghiệp vụ (is_active = 0), chưa xóa dữ liệu.
    public boolean deactivateSupplier(int id) {
        if (conn == null) {
            return false;
        }
        String sql = "UPDATE suppliers SET is_active = 0 WHERE supplier_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Mở lại supplier đã bị khóa (is_active = 1).
    public boolean restoreSupplier(int id) {
        if (conn == null) {
            return false;
        }
        String sql = "UPDATE suppliers SET is_active = 1 WHERE supplier_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Kiểm tra supplier đã từng được dùng trong import_receipts chưa.
    // Nếu query lỗi thì vẫn trả true để ưu tiên an toàn, không xóa nhầm.
    public boolean isReferencedByReceipts(int supplierId) {
        if (conn == null) {
            return true; // không query được → coi như đang dùng, khỏi xóa nhầm
        }
        // Còn liên kết với phiếu nhập thì không cho hard delete.
        String sql = "SELECT 1 FROM import_receipts WHERE supplier_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next(); // có ít nhất 1 phiếu nhập → đang reference
            }
        } catch (Exception e) {
            e.printStackTrace();
            return true; // lỗi thì không cho xóa
        }
    }

    // Chỉ xóa cứng khi chắc chắn supplier không còn bị bảng khác tham chiếu.
    public boolean deleteSupplierIfNoReferences(int id) {
        if (conn == null || isReferencedByReceipts(id)) {
            return false;
        }
        String sql = "DELETE FROM suppliers WHERE supplier_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Chuyển 1 dòng query thành Supplier object.
    private Supplier mapRow(ResultSet rs) throws Exception {
        Timestamp created = rs.getTimestamp("created_at");
        return new Supplier(
                rs.getInt("supplier_id"),
                rs.getString("supplier_name"),
                rs.getString("phone"),
                rs.getString("email"),
                rs.getString("address"),
                rs.getBoolean("is_active"),
                created
        );
    }

    // Chuỗi rỗng -> null để DB lưu trạng thái "không có dữ liệu" rõ ràng hơn.
    private static String emptyToNull(String s) {
        if (s == null) {
            return null;
        }
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}
