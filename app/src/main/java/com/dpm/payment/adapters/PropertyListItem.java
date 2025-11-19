package com.dpm.payment.adapters;

import com.google.gson.annotations.SerializedName;

public class PropertyListItem {

    @SerializedName("propertyId")
    private String propertyId;
    @SerializedName("assessment")
    private String assessment;
     @SerializedName("balance")
    private String balance;
    @SerializedName("propertyImg")
    private String propertyImg;

    public String getPropertyId() {
        return propertyId;
    }

    public void setPropertyId(String propertyId) {
        this.propertyId = propertyId;
    }

    public String getPropertyImg() {
        return propertyImg;
    }

    public void setPropertyImg(String propertyImg) {
        this.propertyImg = propertyImg;
    }

    public String getPropertyName() {
        return propertyId;
    }

    public void setPropertyName(String propertyName) {
        this.propertyId = propertyName;
    }

    public String getAssessment() {
        return assessment;
    }

    public void setAssessment(String assessment) {
        this.assessment = assessment;
    }
    public String getBalance() {
        return balance;
    }
    public void setBalance(String balance) {
        this.balance = balance;
    }

}
