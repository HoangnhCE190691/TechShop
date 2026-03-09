package model;

public class VariantSpecValue {

    private int variantId;
    private int specId;
    private String specValue;
    private String specName;

    public VariantSpecValue() {
    }

    public VariantSpecValue(int variantId, int specId, String specValue, String specName) {
        this.variantId = variantId;
        this.specId = specId;
        this.specValue = specValue;
        this.specName = specName;
    }

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
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

    public String getSpecName() {
        return specName;
    }

    public void setSpecName(String specName) {
        this.specName = specName;
    }

    @Override
    public String toString() {
        return "VariantSpecValue{" + "variantId=" + variantId + ", specId=" + specId
                + ", specName=" + specName + ", specValue=" + specValue + '}';
    }
}
