package com.dpm.payment.models;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class SearchOccupancyModel {


    @SerializedName("id")
    @Expose
    private Integer id;
    @SerializedName("property_id")
    @Expose
    private Integer propertyId;
    @SerializedName("tenant_first_name")
    @Expose
    private String tenantFirstName;

    @SerializedName("ownerTenantTitle")
    @Expose
    private String ownerTenantTitle;

     @SerializedName("ownerTenantTitle_id")
    @Expose
    private String ownerTenantTitle_id;



    @SerializedName("middle_name")
    @Expose
    private String middleName;
    @SerializedName("surname")
    @Expose
    private String surname;
    @SerializedName("mobile_1")
    @Expose
    private String mobile1;
    @SerializedName("mobile_2")
    @Expose
    private String mobile2;
    @SerializedName("created_at")
    @Expose
    private String createdAt;
    @SerializedName("updated_at")
    @Expose
    private String updatedAt;
    @SerializedName("type")
    @Expose
    private String type;
   @SerializedName("organizational_school_type")
    @Expose
    private String organizational_school_type;


    @SerializedName("titles")
    @Expose
    private Titles titles;

    public Titles getTitles() {
        return titles==null? new Titles() : titles;
    }


    public String getOwnerTenantTitle() {
        return ownerTenantTitle;
    }

    public void setOwnerTenantTitle(String ownerTenantTitle) {
        this.ownerTenantTitle = ownerTenantTitle;
    }

    public String getOwnerTenantTitle_id() {
        return ownerTenantTitle_id;
    }

    public void setOwnerTenantTitle_id(String ownerTenantTitle_id) {
        this.ownerTenantTitle_id = ownerTenantTitle_id;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getPropertyId() {
        return propertyId;
    }

    public void setPropertyId(Integer propertyId) {
        this.propertyId = propertyId;
    }

    public String getTenantFirstName() {
        return tenantFirstName;
    }

    public void setTenantFirstName(String tenantFirstName) {
        this.tenantFirstName = tenantFirstName;
    }

    public String getMiddleName() {
        return middleName;
    }

    public void setMiddleName(String middleName) {
        this.middleName = middleName;
    }

    public String getSurname() {
        return surname;
    }

    public void setSurname(String surname) {
        this.surname = surname;
    }

    public String getMobile1() {
        return mobile1;
    }

    public void setMobile1(String mobile1) {
        this.mobile1 = mobile1;
    }

    public String getMobile2() {
        return mobile2;
    }

    public void setMobile2(String mobile2) {
        this.mobile2 = mobile2;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getOrganizational_school_type() {
        return organizational_school_type;
    }

    public void setOrganizational_school_type(String organizational_school_type) {
        this.organizational_school_type = organizational_school_type;
    }
}
