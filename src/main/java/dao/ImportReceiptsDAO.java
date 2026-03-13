/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.ImportReceipts;
import utils.DBContext;

/**
 *
 * @author LE HOANG NHAN
 */
public class ImportReceiptsDAO extends DBContext {

    // 1. GET ALL
    public List<ImportReceipts> getAllReceipts() {
        List<ImportReceipts> list = new ArrayList<>();
        String sql = "SELECT * FROM import_receipts";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new ImportReceipts(
                        rs.getInt("receipt_id"),
                        rs.getInt("supplier_id"),
                        rs.getInt("employee_id"),
                        rs.getDouble("total_cost"),
                        rs.getTimestamp("import_date")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. GET BY ID
    public ImportReceipts getReceiptById(int id) {
        String sql = "SELECT * FROM import_receipts WHERE receipt_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new ImportReceipts(
                        rs.getInt("receipt_id"),
                        rs.getInt("supplier_id"),
                        rs.getInt("employee_id"),
                        rs.getDouble("total_cost"),
                        rs.getTimestamp("import_date")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 3. INSERT (returns generated receipt_id, or 0 on failure)
    public int insertReceiptReturnId(ImportReceipts p) {
        String sql = "INSERT INTO import_receipts (supplier_id, employee_id, total_cost) VALUES (?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
            ps.setInt(1, p.getSupplier_id());
            ps.setInt(2, p.getEmployee_id());
            ps.setDouble(3, p.getTotal_cost());
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public void insertReceipt(ImportReceipts p) {
        insertReceiptReturnId(p);
    }

    // 4. UPDATE
    public void updateReceipt(ImportReceipts p) {
        String sql = "UPDATE import_receipts SET supplier_id=?, employee_id=?, total_cost=? WHERE receipt_id=?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, p.getSupplier_id());
            ps.setInt(2, p.getEmployee_id());
            ps.setDouble(3, p.getTotal_cost());
            ps.setInt(4, p.getReceipt_id());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 5. DELETE - trả về true nếu xóa thành công, false nếu lỗi (ví dụ dính khóa ngoại)
    public boolean deleteReceipt(int id) {
        String sql = "DELETE FROM import_receipts WHERE receipt_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // --- MAIN TEST ---
    public static void main(String[] args) {
        ImportReceiptsDAO dao = new ImportReceiptsDAO();

        // 1. Xem danh sach
        System.out.println("--- LIST ALL ---");
        List<ImportReceipts> list = dao.getAllReceipts();
        for (ImportReceipts item : list) {
            System.out.println(item);
        }

        // 2. Insert (Chèn)
        // LƯU Ý: Thay ID 1, 1 bang ID Supplier/Employee CO THAT cua ban
        dao.insertReceipt(new ImportReceipts(0, 1, 1, 550000, null));
        System.out.println("Da them phieu nhap.");

        // 3. Update (Sửa) - Thay ID = 1 bang ID phieu nhap CO THAT
        // dao.updateReceipt(new ImportReceipts(1, 1, 1, 888888, null));
        // System.out.println("Da update phieu ID = 1.");
        // 4. Get By ID
        // System.out.println(dao.getReceiptById(1));
    }
}
