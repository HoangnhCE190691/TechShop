package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.Voucher;
import utils.DBContext;

public class VoucherDAO extends DBContext {

    // Helper method: Map ResultSet to Voucher Object
    private Voucher mapResultSetToVoucher(ResultSet rs) throws Exception {
        return new Voucher(
                rs.getInt("voucher_id"),
                rs.getString("code"),
                rs.getInt("discount_percent"),
                rs.getDouble("max_discount_amount"),
                rs.getDouble("min_order_value"),
                rs.getTimestamp("valid_from").toLocalDateTime(),
                rs.getTimestamp("valid_to").toLocalDateTime(),
                rs.getInt("total_quantity"),
                rs.getInt("used_quantity"),
                rs.getString("status")
        );
    }

    // ===== GET ALL =====
    public List<Voucher> getAllVoucher() {
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT * FROM vouchers";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToVoucher(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Voucher> getVouchersByMonth(int month) {
        List<Voucher> list = new ArrayList<>();
        // Câu lệnh SQL lọc theo tháng của cột valid_from
        String sql = "SELECT * FROM vouchers WHERE MONTH(valid_from) = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToVoucher(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Voucher> getVouchersByYear(int year) {
        List<Voucher> list = new ArrayList<>();
        // Câu lệnh SQL lọc theo năm của cột valid_from
        String sql = "SELECT * FROM vouchers WHERE YEAR(valid_from) = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToVoucher(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ===== GET BY ID =====
    public Voucher getVoucherById(int id) {
        String sql = "SELECT * FROM vouchers WHERE voucher_id= ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToVoucher(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ===== GET BY CODE (Dùng cho tính năng áp dụng Voucher) =====
    public Voucher getVoucherByCode(String code) {
        String sql = "SELECT * FROM vouchers WHERE code = ? AND status = 'ACTIVE'";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, code);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToVoucher(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ===== INSERT =====
    public boolean insertVoucher(Voucher v) {
        String sql = """
            INSERT INTO vouchers 
            (code, discount_percent, max_discount_amount, min_order_value, 
             valid_from, valid_to, total_quantity, used_quantity, status) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, v.getCode());
            ps.setInt(2, v.getDiscountPercent());
            ps.setDouble(3, v.getMaxDiscountAmount());
            ps.setDouble(4, v.getMinOrderValue());
            ps.setTimestamp(5, Timestamp.valueOf(v.getValidFrom()));
            ps.setTimestamp(6, Timestamp.valueOf(v.getValidTo()));
            ps.setInt(7, v.getTotalQuantity());
            ps.setInt(8, v.getUsedQuantity());
            ps.setString(9, v.getStatus());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ===== UPDATE =====
    public boolean updateVoucher(Voucher v) {
        String sql = """
            UPDATE vouchers 
            SET code=?, discount_percent=?, max_discount_amount=?, min_order_value=?, 
                valid_from=?, valid_to=?, total_quantity=?, status=? 
            WHERE voucher_id=?
        """;
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, v.getCode());
            ps.setInt(2, v.getDiscountPercent());
            ps.setDouble(3, v.getMaxDiscountAmount());
            ps.setDouble(4, v.getMinOrderValue());
            ps.setTimestamp(5, Timestamp.valueOf(v.getValidFrom()));
            ps.setTimestamp(6, Timestamp.valueOf(v.getValidTo()));
            ps.setInt(7, v.getTotalQuantity());
            ps.setString(8, v.getStatus());
            ps.setInt(9, v.getVoucherId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ===== DELETE (Xóa cứng) =====
    public boolean deleteVoucher(int id) {
        String sql = "DELETE FROM vouchers WHERE voucher_id=?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Voucher> searchByCode(String code) {
        List<Voucher> list = new ArrayList<>();
        // Tìm kiếm gần đúng theo mã Voucher
        String sql = "SELECT * FROM vouchers WHERE code LIKE ?";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            // Gán tham số dạng %CODE%
            ps.setString(1, "%" + code + "%");

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                // Tái sử dụng hàm mapResultSetToVoucher có sẵn của bạn
                list.add(mapResultSetToVoucher(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    // ===== INCREMENT USED QUANTITY =====

    public boolean incrementUsedQuantity(int voucherId) {
        String sql = "UPDATE vouchers SET used_quantity = used_quantity + 1 WHERE voucher_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, voucherId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ===== TEST MAIN =====
    public static void main(String[] args) {
        VoucherDAO dao = new VoucherDAO();
        dao.getAllVoucher();

//        System.out.println("--- DANH SÁCH VOUCHER ---");
//        for (Voucher v : list) {
//            System.out.println(v);
//        }
        LocalDateTime startTime = LocalDateTime.now();
        LocalDateTime endTime = startTime.plusMonths(1); // Hết hạn sau 1 tháng

//        dao.insertVoucher(new Voucher(
//                0, // ID (sẽ tự tăng trong DB)
//                "SUMMER2026", // Code
//                15, // 15%
//                100000, // Max giảm 100k
//                500000, // Đơn tối thiểu 500k
//                startTime, // Ngày bắt đầu
//                endTime, // Ngày kết thúc
//                100, // Tổng số lượng 100 mã
//                0, // Đã dùng 0 mã
//                "ACTIVE" // Trạng thái
//        ));
        dao.updateVoucher(new Voucher(
                5, // ID (sẽ tự tăng trong DB)
                "SUMMER2026", // Code
                100, // 15%
                100000, // Max giảm 100k
                500000, // Đơn tối thiểu 500k
                startTime, // Ngày bắt đầu
                endTime, // Ngày kết thúc
                100, // Tổng số lượng 100 mã
                0, // Đã dùng 0 mã
                "ACTIVE" // Trạng thái
        ));

//        dao.deleteVoucher(6);
        System.out.println(dao.getVoucherById(5));
//        dao.getVoucherById(1);
    }
    // ===== SOFT DELETE =====
public boolean softDeleteVoucher(int id) {
    String sql = """
        UPDATE vouchers
        SET status = 'INACTIVE',
            deleted_at = CURRENT_TIMESTAMP
        WHERE voucher_id = ?
    """;
    try {
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, id);
        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
    }
    return false;
}
}
