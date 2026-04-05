/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.ProductImage;
import model.Product;
import utils.DBContext;

/**
 *
 * @author ASUS
 */
public class ProductImageDAO extends DBContext {

    private ProductDAO productDAO = new ProductDAO();

    // 1. READ: Lấy tất cả ảnh (Existing)
    public List<ProductImage> getAllProductImage() {
        List<ProductImage> list = new ArrayList<>();
        String sql = "SELECT * FROM product_images";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ProductImage pi = mapRowToProductImage(rs);
                list.add(pi);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. READ: Lấy ảnh theo ID (Get By ID)
    public ProductImage getProductImageById(int id) {
        String sql = "SELECT * FROM product_images WHERE image_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRowToProductImage(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 2.1 READ: Lấy danh sách ảnh của một sản phẩm cụ thể (Rất quan trọng cho trang chi tiết SP)
    public List<ProductImage> getImagesByProductId(int productId) {
        List<ProductImage> list = new ArrayList<>();
        String sql = "SELECT * FROM product_images WHERE product_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRowToProductImage(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. CREATE: Thêm mới ảnh
    public boolean addProductImage(ProductImage pi) {
        String sql = "INSERT INTO [product_images] ([product_id], [image_url], [is_thumbnail]) VALUES (?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, pi.getProduct().getProductId());
            ps.setString(2, pi.getImageUrl());
            ps.setByte(3, pi.getIs_thumbnail()); 

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 4. UPDATE: Cập nhật thông tin ảnh
    public boolean updateProductImage(ProductImage pi) {
        String sql = "UPDATE [product_images] SET [product_id] = ?, [image_url] = ?, [is_thumbnail] = ? WHERE [image_id] = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, pi.getProduct().getProductId());
            ps.setString(2, pi.getImageUrl());
            ps.setByte(3, pi.getIs_thumbnail());
            ps.setInt(4, pi.getImageID());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 5. DELETE: Xóa ảnh
    public boolean deleteProductImage(int id) {
        String sql = "DELETE FROM [product_images] WHERE [image_id] = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Helper method để map dữ liệu từ ResultSet sang Object (Tránh lặp code)
    private ProductImage mapRowToProductImage(ResultSet rs) throws SQLException {
        int imageId = rs.getInt("image_id");
        int productID = rs.getInt("product_id");
        String imageURL = rs.getString("image_url");
        byte isThumbnail = rs.getByte("is_thumbnail");

        Product product = productDAO.getProductById(productID);

        return new ProductImage(imageId, product, imageURL, isThumbnail);
    }

    // ================= MAIN TEST CASE =================
    public static void main(String[] args) {
        ProductImageDAO dao = new ProductImageDAO();
        // ProductDAO pDao = new ProductDAO(); // Cần cái này để giả lập object Product khi thêm mới

        System.out.println("--- TEST 1: LIST ALL IMAGES ---");
        List<ProductImage> list = dao.getAllProductImage();
        for (ProductImage pi : list) {
            System.out.println(pi); // Đảm bảo class ProductImage có hàm toString()
        }

        System.out.println("\n--- TEST 2: CREATE NEW IMAGE FOR PRODUCT ID 1 ---");
//         Giả lập tạo object ProductImage mới. 
//        product p1 = pDao.getProductById(1);
//        if (p1 != null) {
//            ProductImage newImg = new ProductImage(0, p1, "test-image-url.jpg", (byte)0);
//            boolean isAdded = dao.addProductImage(newImg);
//            System.out.println("Insert result: " + isAdded);
//        }

//   dao.addProductImage(new ProductImage(0, p1, "hihi",(byte) 0));
//        if (dao.deleteProductImage(1)) {
//            System.out.println("Xóa thành cong");
//        }
//        dao.updateProductImage(new ProductImage(19, p1, "haha",(byte) 1));
    }
}
