package model;

public class Brand {

    private int brandId;
    private String brandName;
    private String imageUrl;
    private boolean isActive;

    public Brand() {
    }

    public Brand(int brandId, String brandName, String imageUrl, boolean isActive) {
        this.brandId = brandId;
        this.brandName = brandName;
        this.imageUrl = imageUrl;
        this.isActive = isActive;
    }

    public Brand(String brandName, String imageUrl, boolean isActive) {
        this.brandName = brandName;
        this.imageUrl = imageUrl;
        this.isActive = isActive;
    }

    // Getters and Setters
    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    @Override
    public String toString() {
        return "Brand{" + "brandId=" + brandId + ", brandName=" + brandName + ", imageUrl=" + imageUrl + ", isActive=" + isActive + '}';
    }
    
}
