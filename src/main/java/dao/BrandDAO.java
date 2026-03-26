package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Brand;
import utils.DBContext;

public class BrandDAO extends DBContext {

    // 1. Lấy tất cả Brand
    public List<Brand> getAllBrand() {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT * FROM brands ORDER BY brand_id DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Lấy Brand theo ID
    public Brand getBrandById(int id) {
        String sql = "SELECT * FROM brands WHERE brand_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSet(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 3. Thêm mới Brand
    public void insertBrand(String name, String imageUrl, boolean status) {
        String sql = "INSERT INTO brands (brand_name, image_url, is_active) VALUES (?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, imageUrl);
            ps.setBoolean(3, status);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 4. Cập nhật Brand
    public void updateBrand(Brand b) {
        String sql = "UPDATE brands SET brand_name = ?, image_url = ?, is_active = ? WHERE brand_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, b.getBrandName());
            ps.setString(2, b.getImageUrl());
            ps.setBoolean(3, b.isIsActive());
            ps.setInt(4, b.getBrandId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 5. Kiểm tra tên tồn tại (Cho Add)
    public boolean isBrandNameExists(String name) {
        String sql = "SELECT COUNT(*) FROM brands WHERE brand_name = ?";
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

    // 6. Kiểm tra tên tồn tại (Cho Update - loại trừ ID hiện tại)
    public boolean isBrandNameExists(String name, int id) {
        String sql = "SELECT COUNT(*) FROM brands WHERE brand_name = ? AND brand_id <> ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setInt(2, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 7. Các hàm xóa
    public void deactivateBrand(int id) {
        String sql = "UPDATE brands SET is_active = 0 WHERE brand_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteBrand(int id) {
        String sql = "DELETE FROM brands WHERE brand_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int countProductsByBrandId(int id) {
        String sql = "SELECT COUNT(*) FROM products WHERE brand_id = ?";
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

    public List<Brand> getAllActiveBrands() {
        List<Brand> list = new ArrayList<>();

        String sql = "SELECT * FROM brands WHERE is_active = 1 ORDER BY brand_name DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Hàm Map dữ liệu chuẩn Template
    private Brand mapResultSet(ResultSet rs) throws Exception {
        Brand b = new Brand();
        b.setBrandId(rs.getInt("brand_id"));
        b.setBrandName(rs.getString("brand_name"));
        b.setImageUrl(rs.getString("image_url")); // Lấy đường dẫn ảnh từ DB
        b.setIsActive(rs.getBoolean("is_active"));
        return b;
    }

    public static void main(String[] args) {
        BrandDAO a = new BrandDAO();

        List<Brand> list = a.getAllBrand();

        for (Brand brand : list) {
            System.out.println(brand.toString());
        }
    }

}
