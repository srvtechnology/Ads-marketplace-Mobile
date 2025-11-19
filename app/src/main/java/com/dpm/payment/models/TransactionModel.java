package com.dpm.payment.models;

import com.google.gson.annotations.SerializedName;

public class TransactionModel {
    @SerializedName("transaction_id")
    private String transaction_id;
    @SerializedName("amount")
    private String amount;
    @SerializedName("admin_user_id")
    private String admin_user_id;
    @SerializedName("cheque_number")
    private String cheque_number;
    @SerializedName("penalty")
    private String penalty;
    @SerializedName("created_at")
    private String created_at;
    @SerializedName("property_id")
    private String property_id;
    @SerializedName("assessment")
    private String assessment;
    @SerializedName("total")
    private String total;
    @SerializedName("payment_type")
    private String payment_type;
    @SerializedName("balance")
    private String balance;
    @SerializedName("updated_at")
    private String updated_at;
    @SerializedName("payee_name")
    private String payee_name;
    @SerializedName("id")
    private String id;

    @SerializedName("physical_receipt_image_path")
    private String physical_receipt_image_path;

    @SerializedName("disability_discount_image_path")
    private String disability_discount_image_path;

    @SerializedName("pensioner_discount_image_path")
    private String pensioner_discount_image_path;

    @SerializedName("disability_discount_approve")
    private String disability_discount_approve;

    @SerializedName("pensioner_discount_approve")
    private String pensioner_discount_approve;

    public String getDisability_discount_approve() {
        return disability_discount_approve;
    }

    public void setDisability_discount_approve(String disability_discount_approve) {
        this.disability_discount_approve = disability_discount_approve;
    }

    public String getPensioner_discount_approve() {
        return pensioner_discount_approve;
    }

    public void setPensioner_discount_approve(String pensioner_discount_approve) {
        this.pensioner_discount_approve = pensioner_discount_approve;
    }

    @SerializedName("admin")
    private AdminTransactionModel adminTransactionModel;

    public AdminTransactionModel getAdminTransactionModel() {
        return adminTransactionModel;
    }

    public void setAdminTransactionModel(AdminTransactionModel adminTransactionModel) {
        this.adminTransactionModel = adminTransactionModel;
    }

    public String getPhysical_receipt_image_path() {
        return physical_receipt_image_path;
    }

    public void setPhysical_receipt_image_path(String physical_receipt_image_path) {
        this.physical_receipt_image_path = physical_receipt_image_path;
    }

    public String getDisability_discount_image_path() {
        return disability_discount_image_path;
    }

    public void setDisability_discount_image_path(String disability_discount_image_path) {
        this.disability_discount_image_path = disability_discount_image_path;
    }

    public String getPensioner_discount_image_path() {
        return pensioner_discount_image_path;
    }

    public void setPensioner_discount_image_path(String pensioner_discount_image_path) {
        this.pensioner_discount_image_path = pensioner_discount_image_path;
    }

    public String getTransaction_id() {
        return transaction_id;
    }

    public void setTransaction_id(String transaction_id) {
        this.transaction_id = transaction_id;
    }

    public String getAmount() {
        return amount;
    }

    public void setAmount(String amount) {
        this.amount = amount;
    }

    public String getAdmin_user_id() {
        return admin_user_id;
    }

    public void setAdmin_user_id(String admin_user_id) {
        this.admin_user_id = admin_user_id;
    }

    public String getCheque_number() {
        return cheque_number;
    }

    public void setCheque_number(String cheque_number) {
        this.cheque_number = cheque_number;
    }

    public String getPenalty() {
        return penalty;
    }

    public void setPenalty(String penalty) {
        this.penalty = penalty;
    }

    public String getCreated_at() {
        return created_at;
    }

    public void setCreated_at(String created_at) {
        this.created_at = created_at;
    }

    public String getProperty_id() {
        return property_id;
    }

    public void setProperty_id(String property_id) {
        this.property_id = property_id;
    }

    public String getAssessment() {
        return assessment;
    }

    public void setAssessment(String assessment) {
        this.assessment = assessment;
    }

    public String getTotal() {
        return total;
    }

    public void setTotal(String total) {
        this.total = total;
    }

    public String getPayment_type() {
        return payment_type;
    }

    public void setPayment_type(String payment_type) {
        this.payment_type = payment_type;
    }

    public String getBalance() {
        return balance;
    }

    public void setBalance(String balance) {
        this.balance = balance;
    }

    public String getUpdated_at() {
        return updated_at;
    }

    public void setUpdated_at(String updated_at) {
        this.updated_at = updated_at;
    }

    public String getPayee_name() {
        return payee_name;
    }

    public void setPayee_name(String payee_name) {
        this.payee_name = payee_name;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    @Override
    public String toString() {
        return "ClassPojo [transaction_id = " + transaction_id + ", amount = " + amount + ", admin_user_id = " + admin_user_id + ", cheque_number = " + cheque_number + ", penalty = " + penalty + ", created_at = " + created_at + ", property_id = " + property_id + ", assessment = " + assessment + ", total = " + total + ", payment_type = " + payment_type + ", balance = " + balance + ", updated_at = " + updated_at + ", payee_name = " + payee_name + ", id = " + id + "]";
    }
}
