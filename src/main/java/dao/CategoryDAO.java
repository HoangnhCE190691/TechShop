/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Category;
import utils.DBContext;

/**
 *
 * @author CT
 */
public class CategoryDAO extends DBContext {

    // Lấy tất cả danh mục
    public List<Category> getAllCategory() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM categories";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Category(
                        rs.getInt("category_id"),
                        rs.getString("category_name"),
                        rs.getBoolean("is_active")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy danh mục theo ID
    public Category getCategoryById(int id) {
        String sql = "SELECT category_id, category_name, is_active FROM categories WHERE category_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Category(
                        rs.getInt("category_id"),
                        rs.getString("category_name"),
                        rs.getBoolean("is_active")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Thêm danh mục mới
    public void insertCategory(String name, boolean is_active) {
        String sql = "INSERT INTO categories (category_name, is_active) VALUES (?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setBoolean(2, is_active);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Cập nhật danh mục
    public void updateCategory(Category c) {
        String sql = "UPDATE categories SET category_name = ?, is_active = ? WHERE category_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, c.getCategoryName());
            ps.setBoolean(2, c.isIsActive());
            ps.setInt(3, c.getCategoryId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Xóa danh mục
    public void deleteCategory(int id) {
        String sql = "DELETE FROM categories WHERE category_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

// 1. Đếm số lượng sản phẩm thuộc danh mục
    public int countProductsByCategoryId(int id) {
        String sql = "SELECT COUNT(*) FROM products WHERE category_id = ?";
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

// 2. Chuyển trạng thái sang Inactive (Soft Delete)
    public void deactivateCategory(int id) {
        String sql = "UPDATE categories SET is_active = 0 WHERE category_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Kiểm tra tên đã tồn tại chưa (dùng cho Add)
    public boolean isCategoryNameExists(String name) {
        String sql = "SELECT COUNT(*) FROM categories WHERE category_name = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

// Kiểm tra tên đã tồn tại cho các ID khác chưa (dùng cho Update)
    public boolean isCategoryNameExists(String name, int excludeId) {
        String sql = "SELECT COUNT(*) FROM categories WHERE category_name = ? AND category_id <> ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setInt(2, excludeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public static void main(String[] args) {
        CategoryDAO dao = new CategoryDAO();
        // Test: In ra tất cả danh mục
        for (Category c : dao.getAllCategory()) {
            System.out.println(c);
        }
    }
}
