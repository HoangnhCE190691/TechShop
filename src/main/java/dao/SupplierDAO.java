/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Supplier;
import utils.DBContext;

/**
 *
 * @author LE HOANG NHAN
 */
public class SupplierDAO extends DBContext {

    // READ ALL
    public List<Supplier> getAllSuppliers() {
        List<Supplier> list = new ArrayList<>();
        if (conn == null) {
            return list;
        }
        String sql = "SELECT * FROM suppliers";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Supplier s = new Supplier(
                        rs.getInt("supplier_id"),
                        rs.getString("supplier_name"),
                        rs.getString("phone"),
                        rs.getBoolean("is_active")
                );
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // GET BY ID 
    public Supplier getSupplierById(int id) {
        String sql = "SELECT * FROM suppliers WHERE supplier_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Supplier(
                        rs.getInt("supplier_id"),
                        rs.getString("supplier_name"),
                        rs.getString("phone"),
                        rs.getBoolean("is_active")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // CREATE
    public void insertSupplier(Supplier s) {
        String sql = "INSERT INTO suppliers (supplier_name, phone, is_active) VALUES (?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, s.getSupplier_name());
            ps.setString(2, s.getPhone());
            ps.setBoolean(3, s.getIs_active());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // UPDATE
    public void updateSupplier(Supplier s) {
        String sql = "UPDATE suppliers SET supplier_name = ?, phone = ?, is_active = ? WHERE supplier_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, s.getSupplier_name());
            ps.setString(2, s.getPhone());
            ps.setBoolean(3, s.getIs_active());
            ps.setInt(4, s.getSupplier_id());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Search by name or phone
    public List<Supplier> searchSuppliers(String keyword) {
        List<Supplier> list = new ArrayList<>();
        if (conn == null || keyword == null || keyword.trim().isEmpty()) {
            return getAllSuppliers();
        }
        String sql = "SELECT * FROM suppliers WHERE supplier_name LIKE ? OR phone LIKE ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword.trim() + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Supplier(
                            rs.getInt("supplier_id"),
                            rs.getString("supplier_name"),
                            rs.getString("phone"),
                            rs.getBoolean("is_active")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Deactivate (soft delete)
    public void deactivateSupplier(int id) {
        String sql = "UPDATE suppliers SET is_active = 0 WHERE supplier_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Restore
    public void restoreSupplier(int id) {
        String sql = "UPDATE suppliers SET is_active = 1 WHERE supplier_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * True if supplier is used in import_receipts (FK), cannot hard-delete.
     */
    public boolean isReferencedByReceipts(int supplierId) {
        String sql = "SELECT 1 FROM import_receipts WHERE supplier_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return true; // safe: assume referenced on error
        }
    }

    /**
     * Hard delete only when not referenced by import_receipts. Returns true if
     * deleted.
     */
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

    // TEST
    public static void main(String[] args) {
        SupplierDAO dao = new SupplierDAO();

        // 1. Get All
        System.out.println("--- DANH SACH ---");
        List<Supplier> list = dao.getAllSuppliers();
        for (Supplier s : list) {
            System.out.println(s);
        }

        // 2. Insert
        dao.insertSupplier(new Supplier(0, "NCC Test Simple", "0123456789", true));
        System.out.println("Da them 1 NCC.");

        // 3. Update 
        dao.updateSupplier(new Supplier(10, "Le Hoàng Nhẩn", "0348808113", false));
        System.out.println("Da update NCC co ID = 1.");

        // 4. Delete (only if not referenced by import_receipts)
        boolean deleted = dao.deleteSupplierIfNoReferences(3);
        System.out.println(deleted ? "Deleted supplier 3." : "Supplier 3 not deleted (in use).");

        // 5. Get By ID
        System.out.println("--- TIM KIEM ID = 1 ---");
        System.out.println(dao.getSupplierById(1));
    }
}
