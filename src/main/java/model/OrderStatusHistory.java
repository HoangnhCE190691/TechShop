/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

/**
 *
 * @author WIN11
 */
public class OrderStatusHistory {

    private int historyId;
    private int orderId;
    private int statusId;
    private String statusCode;
    private String statusName;
    private Integer changedByEmployee;
    private Timestamp changedAt;
    private String employeeName;

    //Insert Constructor
    public OrderStatusHistory(int orderId, int statusId, Integer changedByEmployee) {
        this.orderId = orderId;
        this.statusId = statusId;
        this.changedByEmployee = changedByEmployee;
    }

    public OrderStatusHistory(int historyId, int orderId, int statusId, Integer changedByEmployee, Timestamp changedAt) {
        this.historyId = historyId;
        this.orderId = orderId;
        this.statusId = statusId;
        this.changedByEmployee = changedByEmployee;
        this.changedAt = changedAt;
    }

    //Read constructor
    public OrderStatusHistory(int historyId, int orderId, int statusId, String statusCode, String statusName, Integer changedByEmployee, Timestamp changedAt) {
        this.historyId = historyId;
        this.orderId = orderId;
        this.statusId = statusId;
        this.statusCode = statusCode;
        this.statusName = statusName;
        this.changedByEmployee = changedByEmployee;
        this.changedAt = changedAt;
    }

    public OrderStatusHistory(int historyId, int orderId, int statusId, String statusCode, String statusName, Integer changedByEmployee, Timestamp changedAt, String employeeName) {
        this.historyId = historyId;
        this.orderId = orderId;
        this.statusId = statusId;
        this.statusCode = statusCode;
        this.statusName = statusName;
        this.changedByEmployee = changedByEmployee;
        this.changedAt = changedAt;
        this.employeeName = employeeName;
    }

    public int getHistoryId() {
        return historyId;
    }

    public void setHistoryId(int historyId) {
        this.historyId = historyId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getStatusId() {
        return statusId;
    }

    public void setStatusId(int statusId) {
        this.statusId = statusId;
    }

    public Integer getChangedByEmployee() {
        return changedByEmployee;
    }

    public void setChangedByEmployee(Integer changedByEmployee) {
        this.changedByEmployee = changedByEmployee;
    }

    public Timestamp getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(Timestamp changedAt) {
        this.changedAt = changedAt;
    }

    public String getStatusCode() {
        return statusCode;
    }

    public void setStatusCode(String statusCode) {
        this.statusCode = statusCode;
    }

    public String getStatusName() {
        return statusName;
    }

    public void setStatusName(String statusName) {
        this.statusName = statusName;
    }

    public String getEmployeeName() {
        return employeeName;
    }

    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }
    

    @Override
    public String toString() {
        return "OrderStatusHistory{"
                + "historyId=" + historyId
                + ", orderId=" + orderId
                + ", statusId=" + statusId
                + ", statusCode='" + statusCode + '\''
                + ", statusName='" + statusName + '\''
                + ", changedByEmployee=" + changedByEmployee
                + ", changedAt=" + changedAt
                + '}';
    }

}
