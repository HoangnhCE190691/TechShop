/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 *
 * @author WIN11
 */
public class Order {

    private int orderId;
    private String orderName;
    private int customerId;
    private String customerName;
    private Voucher voucher;
    private int paymentMethodId;
    private String shippingAddress;
    private BigDecimal totalAmount;
    private String paymentStatus;
    private String status;
    private Timestamp createdAt;
    private String phone;
    private String email;
    private String paymentMethodName;
    private String productImageUrl;

    public Order() {
    }

    //INSERT constructor
    public Order(int customerId, Voucher voucher, int paymentMethodId,
            String shippingAddress, BigDecimal totalAmount) {
        this.customerId = customerId;
        this.voucher = voucher;
        this.paymentMethodId = paymentMethodId;
        this.shippingAddress = shippingAddress;
        this.totalAmount = totalAmount;
    }

    //READ constructor 
    public Order(int orderId, int customerId, Voucher voucher, int paymentMethodId,
            String shippingAddress, BigDecimal totalAmount,
            String paymentStatus, String status, Timestamp createdAt) {
        this.orderId = orderId;
        this.customerId = customerId;
        this.voucher = voucher;
        this.paymentMethodId = paymentMethodId;
        this.shippingAddress = shippingAddress;
        this.totalAmount = totalAmount;
        this.paymentStatus = paymentStatus;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public String getOrderName() {
        return orderName;
    }

    public void setOrderName(String orderName) {
        this.orderName = orderName;
    }

    public int getCustomerId() {
        return customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public Voucher getVoucher() {
        return voucher;
    }

    public void setVoucher(Voucher voucher) {
        this.voucher = voucher;
    }

    public int getPaymentMethodId() {
        return paymentMethodId;
    }

    public void setPaymentMethodId(int paymentMethodId) {
        this.paymentMethodId = paymentMethodId;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPaymentMethodName() {
        return paymentMethodName;
    }

    public void setPaymentMethodName(String paymentMethodName) {
        this.paymentMethodName = paymentMethodName;
    }

    public String getProductImageUrl() {
        return productImageUrl;
    }

    public void setProductImageUrl(String productImageUrl) {
        this.productImageUrl = productImageUrl;
    }

    @Override
    public String toString() {
        return "Order{"
                + "orderId=" + orderId
                + ", customerId=" + customerId
                + ", voucher=" + (voucher != null ? voucher.getCode() : "None")
                + ", paymentMethodId=" + paymentMethodId
                + ", shippingAddress='" + shippingAddress + '\''
                + ", totalAmount=" + totalAmount
                + ", paymentStatus='" + paymentStatus + '\''
                + ", status='" + status + '\''
                + ", createdAt=" + createdAt
                + '}';
    }

}
