package dao;

import java.security.MessageDigest;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.Employees;
import utils.DBContext;

public class EmployeesDAO extends DBContext {

    public List<Employees> getAllEmployeeses() {
        RoleDAO dAO = new RoleDAO();
        List<Employees> list = new ArrayList<>();
        String sql = "SELECT        employees.*, roles.*\n"
                + "FROM            roles INNER JOIN\n"
                + "                         employees ON roles.role_id = employees.role_id";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {

                int employeesId = rs.getInt("employee_id");
                String username = rs.getString("username");
                String password = rs.getString("password_hash");
                String fullname = rs.getString("full_name");
                String email = rs.getString("email");
                String phone = rs.getString("phone_number");
                int roleId = rs.getInt("role_id");
                String status = rs.getString("status");
                LocalDateTime createdAt = rs.getTimestamp("created_at").toLocalDateTime();

                Employees employees = new Employees(employeesId, username, password, fullname, email, phone, dAO.getRoleById(roleId), status, createdAt);

                list.add(employees);
            }
        } catch (Exception e) {
        }
        return list;
    }

    // 17.5 Hard Delete Employee Record
    public boolean deleteEmployee(int id) {
        // Câu lệnh SQL xóa vĩnh viễn dựa trên ID
        String sql = "DELETE FROM employees WHERE employee_id = ?";

        try {
            // Sử dụng getConnection() từ DBContext để thực thi
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            // Trả về true nếu xóa thành công ít nhất 1 dòng
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            // Log lỗi nếu có ràng buộc khóa ngoại (Foreign Key) không cho xóa
            e.printStackTrace();
        }
        return false;
    }

    // 17.1 View Employee Detail - Get Data by ID
    public Employees getEmployeeById(int id) {
        RoleDAO dAO = new RoleDAO();

        String sql = "SELECT e.*, r.role_name FROM employees e "
                + "JOIN roles r ON e.role_id = r.role_id WHERE e.employee_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                // Đổ dữ liệu trực tiếp vào object

                int employeesId = rs.getInt("employee_id");
                String username = rs.getString("username");
                String password = rs.getString("password_hash");
                String fullname = rs.getString("full_name");
                String email = rs.getString("email");
                String phone = rs.getString("phone_number");
                int roleId = rs.getInt("role_id");
                String status = rs.getString("status");
                LocalDateTime createdAt = rs.getTimestamp("created_at").toLocalDateTime();

                Employees employees = new Employees(employeesId, username, password, fullname, email, phone, dAO.getRoleById(roleId), status, createdAt);

                return employees;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    // 17.3 Modify Employee Record
    
    public List<Employees> searchByName(String name) {
    List<Employees> list = new ArrayList<>();
    RoleDAO rdao = new RoleDAO();
    // Sử dụng LIKE để tìm kiếm gần đúng
    String sql = "SELECT * FROM employees WHERE full_name LIKE ?";
    
    try {
        PreparedStatement ps = conn.prepareStatement(sql);
        // Gán tham số dạng %tên%
        ps.setNString(1, "%" + name + "%");
        
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            int employeesId = rs.getInt("employee_id");
            String username = rs.getString("username");
            String password = rs.getString("password_hash");
            String fullname = rs.getString("full_name");
            String email = rs.getString("email");
            String phone = rs.getString("phone_number");
            int roleId = rs.getInt("role_id");
            String status = rs.getString("status");
            LocalDateTime createdAt = rs.getTimestamp("created_at").toLocalDateTime();

            // Khởi tạo đối tượng nhân viên
            Employees employees = new Employees(employeesId, username, password, fullname, 
                                                email, phone, rdao.getRoleById(roleId), 
                                                status, createdAt);
            list.add(employees);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}

    public boolean updateEmployee(Employees e) {
        // Câu lệnh SQL cập nhật các trường thông tin dựa trên employee_id
        String sql = "UPDATE employees SET "
                + "full_name = ?, "
                + "email = ?, "
                + "phone_number = ?, "
                + "role_id = ?, "
                + "status = ? "
                + "WHERE employee_id = ?";
        try {
            // Sử dụng getConnection() để đảm bảo kết nối luôn sẵn sàng
            PreparedStatement ps = conn.prepareStatement(sql);

            // Mapping dữ liệu từ object vào câu lệnh SQL
            ps.setNString(1, e.getFullName()); // Hỗ trợ tiếng Việt
            ps.setString(2, e.getEmail());
            ps.setString(3, e.getPhoneNumber());

            // Lấy ID từ đối tượng Role bên trong Employee
            ps.setInt(4, e.getRole().getRole_id());

            ps.setString(5, e.getStatus());
            ps.setInt(6, e.getEmployeeId());

            // Trả về true nếu cập nhật thành công ít nhất 1 dòng
            return ps.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public void insertEmployee(Employees e) {
        // 1. Correct the SQL string: remove the 8th '?' and add closing bracket
        String sql = "INSERT INTO employees ("
                + "username, "
                + "password_hash, "
                + "full_name, "
                + "email, "
                + "phone_number, "
                + "role_id, "
                + "status, "
                + "created_at"
                + ") "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())"; // Use GETDATE() for created_at

        try {
            // Use getConnection() to ensure the connection is active
            PreparedStatement ps = conn.prepareStatement(sql);

            // 2. Map the 7 parameters
            ps.setString(1, e.getUsername());
            ps.setString(2, hashMD5(e.getPasswordHash()));
            ps.setNString(3, e.getFullName()); // Use setNString for Vietnamese support
            ps.setString(4, e.getEmail());
            ps.setString(5, e.getPhoneNumber());

            // Ensure your role object is not null to avoid NullPointerException
            ps.setInt(6, e.getRole().getRole_id());

            ps.setString(7, e.getStatus());

            // 3. Execute the update
            ps.executeUpdate();

        } catch (Exception ex) {
            ex.printStackTrace();
        }
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

    public Employees login(String user, String pass) {
        Employees u = new Employees();
        u.setEmployeeId(-1);
        RoleDAO rdao = new RoleDAO();
        //u.id = -1
        // 123 -> hash -> so sanh -> tra ve doi tuong
        String sql = "SELECT Employees.*\n"
                + "FROM     Employees\n"
                + "where username = ? and password_hash = ?;";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, user);  // ac
            ps.setString(2, hashMD5(pass)); // pas

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                u.setEmployeeId(rs.getInt("employee_id"));
                u.setUsername(rs.getString("username"));
                u.setPasswordHash(rs.getString("password_hash"));
                u.setFullName(rs.getString("full_name"));
                u.setEmail(rs.getString("email"));
                u.setPhoneNumber(rs.getString("phone_number"));
                int roleID = rs.getInt("role_id");
                u.setRole(rdao.getRoleById(roleID));
                u.setStatus(rs.getString("status"));
                u.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
            }

        } catch (Exception e) {
        }

        return u;
    }

    // Test Main
    public static void main(String[] args) {
        EmployeesDAO dao = new EmployeesDAO();
         RoleDAO aO = new RoleDAO();
//        System.out.println("--- 1. TEST READ ---");
//        dao.getAllEmployeeses().forEach(System.out::println);

// 2. Khởi tạo Employee với các giá trị thực tế để test
         String username = "test_staff_" + System.currentTimeMillis() % 1000; // Tạo username không trùng
         String passwordHash = "123456"; // Mật khẩu mẫu
         String fullName = "Nguyen Van Test";
         String email = username + "@phonestore.com";
         String phoneNumber = "0912345678";
         String status = "ACTIVE";

        System.out.println(dao.login("test_staff_241", "123456"));

        dao.insertEmployee(new Employees(0, username, passwordHash, fullName, email, phoneNumber, aO.getRoleById(2), status, LocalDateTime.MAX));
// 3. Gọi hàm DAO để chèn vào Database
//        System.out.println(dao.getEmployeeById(2));
    }
}
