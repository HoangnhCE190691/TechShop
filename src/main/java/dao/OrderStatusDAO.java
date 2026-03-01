/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.OrderStatus;
import utils.DBContext;

/**
 *
 * @author WIN11
 */
public class OrderStatusDAO extends DBContext {

    //get all order statuses
    public List<OrderStatus> getAllOrderStatuses() {
        List<OrderStatus> list = new ArrayList<>();
        String sql = "SELECT * FROM order_statuses ORDER BY step_order";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new OrderStatus(
                        rs.getInt("status_id"),
                        rs.getString("status_code"),
                        rs.getString("status_name"),
                        rs.getInt("step_order"),
                        rs.getBoolean("is_final")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    //get order status by id
    public OrderStatus getOrderStatusById(int id) {
        String sql = "SELECT * FROM order_statuses WHERE status_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new OrderStatus(
                        rs.getInt("status_id"),
                        rs.getString("status_code"),
                        rs.getString("status_name"),
                        rs.getInt("step_order"),
                        rs.getBoolean("is_final")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    //insert order status
    public void insertOrderStatus(OrderStatus os) {
        String sql = """
            INSERT INTO order_statuses(status_code, status_name, step_order, is_final)
            VALUES (?, ?, ?, ?)
        """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, os.getStatusCode());
            ps.setString(2, os.getStatusName());
            ps.setInt(3, os.getStepOrder());
            ps.setBoolean(4, os.isIsFinal());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //Only update status name, step order, is_final
    public void updateOrderStatus(OrderStatus os) {
        String sql = """
        UPDATE order_statuses
        SET status_name = ?, step_order = ?, is_final = ?
        WHERE status_id = ? """;
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, os.getStatusName());
            ps.setInt(2, os.getStepOrder());
            ps.setBoolean(3, os.isIsFinal());
            ps.setInt(4, os.getStatusId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //Hard delete
    public void deleteOrderStatus(int id) {
        String sql = "DELETE FROM order_statuses WHERE status_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Đếm số đơn hàng đang dùng status này
    public int countOrdersByStatusId(int id) {
        String sql = "SELECT "
                + "(SELECT COUNT(*) FROM orders WHERE UPPER(status) = "
                + "    (SELECT UPPER(status_code) FROM order_statuses WHERE status_id = ?)) "
                + "+ "
                + "(SELECT COUNT(*) FROM order_status_history WHERE status_id = ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.setInt(2, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // TEST
    public static void main(String[] args) {
        OrderStatusDAO dao = new OrderStatusDAO();

        // ===== CREATE =====
//         dao.insertOrderStatus(new OrderStatus("CREATED", "Đã tạo đơn", 1, false));
        // ===== UPDATE =====
//         dao.updateOrderStatus(new OrderStatus(1,"CREATED", "Đơn đã tạo", 1, false));
        // ===== GET BY ID =====
//         System.out.println(dao.getOrderStatusById(1));
        // ===== GET ALL =====
        List<OrderStatus> list = dao.getAllOrderStatuses();
        for (OrderStatus os : list) {
            System.out.println(os);
        }
    }

}
