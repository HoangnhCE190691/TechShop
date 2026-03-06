package model;

import java.time.LocalDateTime;

public class Voucher {

    private int voucherId;
    private String code;
    private int discountPercent;
    private double maxDiscountAmount;
    private double minOrderValue;
    private LocalDateTime validFrom;
    private LocalDateTime validTo;
    private int totalQuantity;
    private int usedQuantity;
    private String status; // Khớp với VARCHAR(20) trong DB (ACTIVE, EXPIRED,...)

    // Constructor mặc định
    public Voucher() {
    }

    // Constructor đầy đủ tham số
    public Voucher(int voucherId, String code, int discountPercent, double maxDiscountAmount,
            double minOrderValue, LocalDateTime validFrom, LocalDateTime validTo,
            int totalQuantity, int usedQuantity, String status) {
        this.voucherId = voucherId;
        this.code = code;
        this.discountPercent = discountPercent;
        this.maxDiscountAmount = maxDiscountAmount;
        this.minOrderValue = minOrderValue;
        this.validFrom = validFrom;
        this.validTo = validTo;
        this.totalQuantity = totalQuantity;
        this.usedQuantity = usedQuantity;
        this.status = status;
    }

    // Getter và Setter
    public int getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(int voucherId) {
        this.voucherId = voucherId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public int getDiscountPercent() {
        return discountPercent;
    }

    public void setDiscountPercent(int discountPercent) {
        this.discountPercent = discountPercent;
    }

    public double getMaxDiscountAmount() {
        return maxDiscountAmount;
    }

    public void setMaxDiscountAmount(double maxDiscountAmount) {
        this.maxDiscountAmount = maxDiscountAmount;
    }

    public double getMinOrderValue() {
        return minOrderValue;
    }

    public void setMinOrderValue(double minOrderValue) {
        this.minOrderValue = minOrderValue;
    }

    public LocalDateTime getValidFrom() {
        return validFrom;
    }

    public void setValidFrom(LocalDateTime validFrom) {
        this.validFrom = validFrom;
    }

    public LocalDateTime getValidTo() {
        return validTo;
    }

    public void setValidTo(LocalDateTime validTo) {
        this.validTo = validTo;
    }

    public int getTotalQuantity() {
        return totalQuantity;
    }

    public void setTotalQuantity(int totalQuantity) {
        this.totalQuantity = totalQuantity;
    }

    public int getUsedQuantity() {
        return usedQuantity;
    }

    public void setUsedQuantity(int usedQuantity) {
        this.usedQuantity = usedQuantity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    // Helper method: Kiểm tra xem voucher còn lượt dùng không
    public boolean isAvailable() {
//        return "ACTIVE".equalsIgnoreCase(this.status) && (usedQuantity < totalQuantity);
        LocalDateTime now = LocalDateTime.now();

        // 1. Check trạng thái
        boolean isStatusActive = "ACTIVE".equalsIgnoreCase(this.status);

        // 2. Check số lượng
        boolean isNotOutOfStock = this.usedQuantity < this.totalQuantity;

        // 3. Check thời gian (Đã đến giờ bắt đầu chưa & Đã hết hạn chưa)
        boolean isStarted = (this.validFrom == null || !now.isBefore(this.validFrom));
        boolean isNotExpired = (this.validTo == null || !now.isAfter(this.validTo));

        // Phải thỏa mãn TẤT CẢ các điều kiện trên
        return isStatusActive && isNotOutOfStock && isStarted && isNotExpired;
    }

    @Override
    public String toString() {
        return String.format("Voucher[ID=%d, Code=%s, %d%%, Min=%.2f, Status=%s, Qty=%d/%d]",
                voucherId, code, discountPercent, minOrderValue, status, usedQuantity, totalQuantity);
    }

}
