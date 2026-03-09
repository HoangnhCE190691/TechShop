package model;

public class SpecificationDefinition {

    private int specId;
    private int categoryId;
    private String specName;
    private String unit;
    private boolean isActive;
    private boolean isVariant;

    private String categoryName;

    public SpecificationDefinition() {
    }

    public SpecificationDefinition(int specId, int categoryId, String specName, String unit, boolean isActive) {
        this.specId = specId;
        this.categoryId = categoryId;
        this.specName = specName;
        this.unit = unit;
        this.isActive = isActive;
    }

    public int getSpecId() {
        return specId;
    }

    public void setSpecId(int specId) {
        this.specId = specId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
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

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    public boolean isIsVariant() {
        return isVariant;
    }

    public void setIsVariant(boolean isVariant) {
        this.isVariant = isVariant;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    @Override
    public String toString() {
        return "SpecificationDefinition{" + "specId=" + specId + ", categoryId=" + categoryId + ", specName=" + specName
                + ", unit=" + unit + ", isActive=" + isActive + '}';
    }

}
