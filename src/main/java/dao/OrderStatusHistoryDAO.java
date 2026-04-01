/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import model.OrderStatusHistory;
import utils.DBContext;

/**
 *
 * @author WIN11
 */
public class OrderStatusHistoryDAO extends DBContext {

    //insert order status history
    public void insertOrderStatusHistory(int orderId, int statusId, Integer employeeId) {
        String sql = """
        INSERT INTO order_status_history
        (order_id, status_id, changed_by_employee, changed_at)
        VALUES (?, ?, ?, GETDATE())
    """;
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, orderId);
            ps.setInt(2, statusId);
            if (employeeId == null) {
                ps.setNull(3, Types.INTEGER);
            } else {
                ps.setInt(3, employeeId);
            }
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // READ HISTORY BY ORDER
    public List<OrderStatusHistory> getOrderStatusHistoryByOrder(int orderId) {
        List<OrderStatusHistory> list = new ArrayList<>();
        String sql = """
        SELECT 
            h.history_id,
            h.order_id,
            h.status_id,
            s.status_code,
            s.status_name,
            h.changed_by_employee,
            h.changed_at
        FROM order_status_history h
        JOIN order_statuses s 
            ON h.status_id = s.status_id
        WHERE h.order_id = ?
        ORDER BY h.changed_at
        """;
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new OrderStatusHistory(
                        rs.getInt("history_id"),
                        rs.getInt("order_id"),
                        rs.getInt("status_id"),
                        rs.getString("status_code"),
                        rs.getString("status_name"),
                        rs.getObject("changed_by_employee", Integer.class),
                        rs.getTimestamp("changed_at")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<OrderStatusHistory> getOrderStatusHistoryWithEmployeeName(int orderId) {
        List<OrderStatusHistory> list = new ArrayList<>();
        String sql = """
        SELECT 
            h.history_id, h.order_id, h.status_id,
            s.status_code, s.status_name,
            h.changed_by_employee, h.changed_at,
            e.full_name as employee_name
        FROM order_status_history h
        JOIN order_statuses s ON h.status_id = s.status_id
        LEFT JOIN employees e ON h.changed_by_employee = e.employee_id
        WHERE h.order_id = ?
        ORDER BY h.changed_at ASC
    """;
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String empName = rs.getString("employee_name");
                list.add(new OrderStatusHistory(
                        rs.getInt("history_id"),
                        rs.getInt("order_id"),
                        rs.getInt("status_id"),
                        rs.getString("status_code"),
                        rs.getString("status_name"),
                        rs.getObject("changed_by_employee", Integer.class),
                        rs.getTimestamp("changed_at"),
                        empName != null ? empName : "Customer"
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    //get all order status history
    public List<OrderStatusHistory> getAllOrderStatusHistory() {
        List<OrderStatusHistory> list = new ArrayList<>();
        String sql = "SELECT \n"
                + "    h.history_id,\n"
                + "    h.order_id,\n"
                + "    h.status_id,\n"
                + "    s.status_code,\n"
                + "    s.status_name,\n"
                + "    h.changed_by_employee,\n"
                + "    h.changed_at\n"
                + "FROM order_status_history h\n"
                + "JOIN order_statuses s ON h.status_id = s.status_id\n"
                + "ORDER BY h.changed_at";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new OrderStatusHistory(
                        rs.getInt("history_id"),
                        rs.getInt("order_id"),
                        rs.getInt("status_id"),
                        rs.getString("status_code"),
                        rs.getString("status_name"),
                        (Integer) rs.getObject("changed_by_employee"),
                        rs.getTimestamp("changed_at")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

// TEST
    public static void main(String[] args) {
        // OrderStatusHistoryDAO dao = new OrderStatusHistoryDAO();

        // ===== CREATE =====
//        dao.insertOrderStatusHistory(1, 1, 1); co test rieng biet thi tao id ao nhe
        // ===== GET BY ORDER =====
//        List<OrderStatusHistory> list = dao.getOrderStatusHistoryByOrder(2);
//        for (OrderStatusHistory h : list) {
//            System.out.println(h);
//        }
        // ===== GET ALL =====
//        List<OrderStatusHistory> all = dao.getAllOrderStatusHistory();
//        for (OrderStatusHistory h : all) {
//            System.out.println(h);
//        }
    }
}
