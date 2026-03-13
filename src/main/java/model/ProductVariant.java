package model;

/**
 *
 * @author CT
 */
public class ProductVariant {

    private int variantId;
    private int productId;
    private String sku;
    private long sellingPrice;
    private boolean isActive;

    private String productName;
    // Thêm thông tin hiển thị cho màn nhập hàng
    private String categoryName;
    private String brandName;

    public ProductVariant() {
    }

    public ProductVariant(int variantId, int productId, String sku, long sellingPrice, boolean isActive) {
        this.variantId = variantId;
        this.productId = productId;
        this.sku = sku;
        this.sellingPrice = sellingPrice;
        this.isActive = isActive;
    }

    // Getters and Setters
    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public long getSellingPrice() {
        return sellingPrice;
    }

    public void setSellingPrice(long sellingPrice) {
        this.sellingPrice = sellingPrice;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }
}
