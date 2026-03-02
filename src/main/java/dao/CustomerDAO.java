/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.security.MessageDigest;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.Customer;
import utils.DBContext;

/**
 *
 * @author ASUS
 */
public class CustomerDAO extends DBContext {

    public List<Customer> getAllCustomer() {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT customers.*\n"
                + "FROM     customers";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int role_id = rs.getInt("customer_id");
                String username = rs.getString("username");
                String passwordHash = rs.getString("password_hash");
                String fullname = rs.getString("full_name");
                String email = rs.getString("email");
                String phoneNumber = rs.getString("phone_number");
                String status = rs.getString("status");
                LocalDateTime createdAt = rs.getTimestamp("created_at").toLocalDateTime();
                Customer customer = new Customer(role_id, username, passwordHash, fullname, email, phoneNumber, status, createdAt);
                list.add(customer);
            }
        } catch (Exception e) {
        }
        return list;
    }

    public Customer getCustomerById(int id) {
        String sql = "SELECT * FROM customers WHERE customer_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToCustomer(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private Customer mapResultSetToCustomer(ResultSet rs) throws Exception {
        return new Customer(
                rs.getInt("customer_id"),
                rs.getString("username"),
                rs.getString("password_hash"),
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getString("phone_number"),
                rs.getString("status"),
                rs.getTimestamp("created_at").toLocalDateTime()
        );
    }

    public boolean deleteCustomer(int id) {
        String sql = "DELETE FROM customers WHERE customer_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCustomer(Customer c) {
        String sql = "UPDATE customers SET full_name = ?, email = ?, phone_number = ?, status = ? WHERE customer_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setNString(1, c.getFullname());
            ps.setString(2, c.getEmail());
            ps.setString(3, c.getPhoneNumber());
            ps.setString(4, c.getStatus());
            ps.setInt(5, c.getCustomerID());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addCustomer(Customer c) {
        String sql = "INSERT INTO customers (username, password_hash, full_name, email, phone_number, status, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, c.getUserName());
            ps.setString(2, hashMD5(c.getPassword()));
            ps.setNString(3, c.getFullname()); // Dùng setNString cho dữ liệu có dấu (NVARCHAR)
            ps.setString(4, c.getEmail());
            ps.setString(5, c.getPhoneNumber());
            ps.setString(6, c.getStatus());
            ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public String hashMD5(String str) {
        try {
            MessageDigest mes = MessageDigest.getInstance("MD5");
            byte[] mesMD5 = mes.digest(str.getBytes());
            //[0x0a, 0x7a, 0x12, 0x09, 0x3,....]
            StringBuilder result = new StringBuilder();
            for (byte b : mesMD5) {
                //0x0a; 0x7a; 0x12; 0x09; 0x3
                String c = String.format("%02x", b);
                //0a; 7a;  12;  09; 03
                result.append(c);
            }
            return result.toString();
            //0a7a120903
        } catch (Exception e) {
        }
        return "";
    }

    // 1. Hàm cập nhật thông tin cá nhân (không đụng đến mật khẩu)
    public boolean updateCustomerNopassword(Customer c) {
        String sql = "UPDATE customers SET full_name = ?, email = ?, phone_number = ? WHERE customer_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setNString(1, c.getFullname());
            ps.setString(2, c.getEmail());
            ps.setString(3, c.getPhoneNumber());
            ps.setInt(4, c.getCustomerID());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

// 2. Hàm riêng để đổi mật khẩu (có thực hiện Hash MD5)
    public boolean changePassword(int customerId, String newPassword) {
        String sql = "UPDATE customers SET password_hash = ? WHERE customer_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, hashMD5(newPassword)); // Hash mật khẩu mới ở đây
            ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Customer login(String user, String pass) {
        Customer u = new Customer();
        //u.id = -1
        u.setCustomerID(-1);
        // 123 -> hash -> so sanh -> tra ve doi tuong
        String sql = "SELECT customers.*\n"
                + "FROM     customers\n"
                + "where username = ? and password_hash = ?;";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, user);  // ac
            ps.setString(2, hashMD5(pass)); // pas

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                u.setCustomerID(rs.getInt("customer_id"));
                u.setUserName(rs.getString("username"));
                u.setPassword(rs.getString("password_hash"));
                u.setFullname(rs.getString("full_name"));
                u.setEmail(rs.getString("email"));
                u.setPhoneNumber(rs.getString("phone_number"));
                u.setStatus(rs.getString("status"));
                u.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
            }

        } catch (Exception e) {
        }

        return u;

    }
public List<Customer> searchByName(String name) {
    List<Customer> list = new ArrayList<>();
    // Câu lệnh SQL với toán tử LIKE để tìm kiếm gần đúng
    String sql = "SELECT * FROM customers WHERE full_name LIKE ?";
    
    try {
        PreparedStatement ps = conn.prepareStatement(sql);
        
        // Thêm dấu % vào trước và sau từ khóa
        // Ví dụ: name = "Minh" -> sẽ tìm "%Minh%"
        ps.setNString(1, "%" + name + "%");
        
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            // Tái sử dụng hàm mapResultSetToCustomer bạn đã viết
            list.add(mapResultSetToCustomer(rs));
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}
    public static void main(String[] args) {
        CustomerDAO a = new CustomerDAO();
        a.getAllCustomer();
//        for (Customer customer : list) {
//            System.out.println(customer);
//        }
//        System.out.println(a.login("L", "123"));

        a.addCustomer(new Customer(0, "222", "123", "L", "L", "L", "L", LocalDateTime.MAX));
    }
}
