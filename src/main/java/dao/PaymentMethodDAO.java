/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.PaymentMethod;
import utils.DBContext;

/**
 *
 * @author WIN11
 */
public class PaymentMethodDAO extends DBContext {

    //get all payment methods
    public List<PaymentMethod> getAllPaymentMethods() {
        List<PaymentMethod> list = new ArrayList<>();
        String sql = "SELECT * FROM payment_methods";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new PaymentMethod(
                        rs.getInt("method_id"),
                        rs.getString("method_name"),
                        rs.getBoolean("is_active")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    //get payment method by id
    public PaymentMethod getPaymentMethodById(int id) {
        String sql = "SELECT * FROM payment_methods WHERE method_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new PaymentMethod(
                        rs.getInt("method_id"),
                        rs.getString("method_name"),
                        rs.getBoolean("is_active")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    //create payment method
    public void insertPaymentMethod(String name, boolean is_active) {
        String sql = "INSERT INTO payment_methods(method_name,is_active) VALUES (?,?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setBoolean(2, is_active);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //update payment method
    public void updatePaymentMethod(PaymentMethod pm) {
        String sql = "UPDATE payment_methods SET method_name=?,is_active=? WHERE method_id=?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, pm.getMethod_name());
            ps.setBoolean(2, pm.isIs_active());
            ps.setInt(3, pm.getMethod_id());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //Hard delete
    public void deletePaymentMethod(int id) {
        String sql = "DELETE FROM payment_methods WHERE method_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    //Soft delete
    public void deactivatePaymentMethod(int id) {
        String sql = "UPDATE payment_methods SET is_active = 0 WHERE method_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //Count order with paymentmethod
    public int countOrdersByPaymentMethodId(int id) {
        String sql = "SELECT COUNT(*) FROM orders WHERE payment_method_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

//    //TEST
//    public static void main(String[] args) {
//        PaymentMethodDAO dao = new PaymentMethodDAO();

////         ===== INSERT =====
////         dao.insertPaymentMethod("COD");
////         dao.insertPaymentMethod("VNPAY");
////         dao.insertPaymentMethod("MOMO");
//        // ===== UPDATE =====
////         dao.updatePaymentMethod(new PaymentMethod(2, "Bank Transfer", true));
//        // ===== DISABLE (Soft delete) =====
////         dao.disablePaymentMethod(3);
//        // ===== GET BY ID  =====
//        System.out.println(dao.getActivePaymentMethodById(2));
////          ===== GET ALL UN-ACTIVE =====
////          List<PaymentMethod> list = dao.getAllInactivePaymentMethods();
////          for (PaymentMethod pm : list) {
////          System.out.println(pm);
////          }
//
//        // ===== GET ALL =====
////        List<PaymentMethod> allList = dao.getAllActivePaymentMethods();
////        for (PaymentMethod pm : allList) {
////            System.out.println(pm);
////        }
//    }

}
