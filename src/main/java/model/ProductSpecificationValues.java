package model;

public class ProductSpecificationValues {

    private int productId;
    private int specId;
    private String specValue;

    private String productName;
    private String specName;

    private String unit;

    public ProductSpecificationValues() {
    }

    public ProductSpecificationValues(int productId, int specId, String specValue) {
        this.productId = productId;
        this.specId = specId;
        this.specValue = specValue;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getSpecId() {
        return specId;
    }

    public void setSpecId(int specId) {
        this.specId = specId;
    }

    public String getSpecValue() {
        return specValue;
    }

    public void setSpecValue(String specValue) {
        this.specValue = specValue;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getSpecName() {
        return specName;
    }

    public void setSpecName(String specName) {
        this.specName = specName;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    @Override
    public String toString() {
        return "ProductSpecificationValues{" + "productId=" + productId + ", specId=" + specId + ", specValue="
                + specValue + ", unit=" + unit + '}';
    }
}
