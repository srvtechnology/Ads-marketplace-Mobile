package com.dpm.payment.models;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class SearchPropertyModel {


    @SerializedName("id")
    @Expose
    private Integer id;
    @SerializedName("user_id")
    @Expose
    private Integer userId;
    @SerializedName("street_number")
    @Expose
    private String streetNumber;
    @SerializedName("street_numbernew")
    @Expose
    private String street_numbernew = "";
    @SerializedName("street_name")
    @Expose
    private String streetName;
    @SerializedName("ward")
    @Expose
    private Integer ward;
    @SerializedName("constituency")
    @Expose
    private String constituency;
    @SerializedName("section")
    @Expose
    private String section;
    @SerializedName("chiefdom")
    @Expose
    private String chiefdom;
    @SerializedName("district")
    @Expose
    private String district;
    @SerializedName("province")
    @Expose
    private String province;
    @SerializedName("postcode")
    @Expose
    private String postcode;
    @SerializedName("organization_addresss")
    @Expose
    private Object organizationAddresss;
    @SerializedName("organization_tin")
    @Expose
    private Object organizationTin;
    @SerializedName("organization_type")
    @Expose
    private Object organizationType;
    @SerializedName("organization_name")
    @Expose
    private Object organizationName;
    @SerializedName("is_organization")
    @Expose
    private Boolean isOrganization;
    @SerializedName("is_completed")
    @Expose
    private Boolean isCompleted;
    @SerializedName("is_draft_delivered")
    @Expose
    private Integer isDraftDelivered;
    @SerializedName("delivered_name")
    @Expose
    private String deliveredName;
    @SerializedName("delivered_number")
    @Expose
    private String deliveredNumber;
    @SerializedName("delivered_image")
    @Expose
    private String deliveredImage;
    @SerializedName("is_property_inaccessible")
    @Expose
    private Boolean isPropertyInaccessible;
    @SerializedName("created_at")
    @Expose
    private String createdAt;
    @SerializedName("updated_at")
    @Expose
    private String updatedAt;
    @SerializedName("delivered_image_path")
    @Expose
    private String deliveredImagePath;
    @SerializedName("landlord")
    @Expose
    private SearchLandlordModel landlord;
    @SerializedName("occupancy")
    @Expose
    private SearchOccupancyModel occupancy;
    @SerializedName("assessment")
    @Expose
    private SearchAssessmentModel assessment;

    @SerializedName("property_area")
    @Expose
    private String property_area;


    @SerializedName("geo_registry")
    @Expose
    private SearchGeoRegistryModel geoRegistry;
    @SerializedName("payments")
    @Expose
    private List<Object> payments = null;
    @SerializedName("assessment_history")
    @Expose
    private List<SearchAssessmentHistoryModel> assessmentHistory = null;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getProperty_area() {
        return property_area;
    }

    public void setProperty_area(String property_area) {
        this.property_area = property_area;
    }

    public String getStreet_numbernew() {
        return street_numbernew;
    }

    public void setStreet_numbernew(String street_numbernew) {
        this.street_numbernew = street_numbernew;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getStreetNumber() {
        return streetNumber;
    }

    public void setStreetNumber(String streetNumber) {
        this.streetNumber = streetNumber;
    }

    public String getStreetName() {
        return streetName;
    }

    public void setStreetName(String streetName) {
        this.streetName = streetName;
    }

    public Integer getWard() {
        return ward;
    }

    public void setWard(Integer ward) {
        this.ward = ward;
    }

    public String getConstituency() {
        return constituency;
    }

    public void setConstituency(String constituency) {
        this.constituency = constituency;
    }

    public String getSection() {
        return section;
    }

    public void setSection(String section) {
        this.section = section;
    }

    public String getChiefdom() {
        return chiefdom;
    }

    public void setChiefdom(String chiefdom) {
        this.chiefdom = chiefdom;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public String getPostcode() {
        return postcode;
    }

    public void setPostcode(String postcode) {
        this.postcode = postcode;
    }

    public Object getOrganizationAddresss() {
        return organizationAddresss;
    }

    public void setOrganizationAddresss(Object organizationAddresss) {
        this.organizationAddresss = organizationAddresss;
    }

    public Object getOrganizationTin() {
        return organizationTin;
    }

    public void setOrganizationTin(Object organizationTin) {
        this.organizationTin = organizationTin;
    }

    public Object getOrganizationType() {
        return organizationType;
    }

    public void setOrganizationType(Object organizationType) {
        this.organizationType = organizationType;
    }

    public Object getOrganizationName() {
        return organizationName;
    }

    public void setOrganizationName(Object organizationName) {
        this.organizationName = organizationName;
    }

    public Boolean getIsOrganization() {
        return isOrganization;
    }

    public void setIsOrganization(Boolean isOrganization) {
        this.isOrganization = isOrganization;
    }

    public Boolean getIsCompleted() {
        return isCompleted;
    }

    public void setIsCompleted(Boolean isCompleted) {
        this.isCompleted = isCompleted;
    }

    public Integer getIsDraftDelivered() {
        return isDraftDelivered;
    }

    public void setIsDraftDelivered(Integer isDraftDelivered) {
        this.isDraftDelivered = isDraftDelivered;
    }

    public String getDeliveredName() {
        return deliveredName;
    }

    public void setDeliveredName(String deliveredName) {
        this.deliveredName = deliveredName;
    }

    public String getDeliveredNumber() {
        return deliveredNumber;
    }

    public void setDeliveredNumber(String deliveredNumber) {
        this.deliveredNumber = deliveredNumber;
    }

    public String getDeliveredImage() {
        return deliveredImage;
    }

    public void setDeliveredImage(String deliveredImage) {
        this.deliveredImage = deliveredImage;
    }

    public Boolean getIsPropertyInaccessible() {
        return isPropertyInaccessible;
    }

    public void setIsPropertyInaccessible(Boolean isPropertyInaccessible) {
        this.isPropertyInaccessible = isPropertyInaccessible;
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

    public String getDeliveredImagePath() {
        return deliveredImagePath;
    }

    public void setDeliveredImagePath(String deliveredImagePath) {
        this.deliveredImagePath = deliveredImagePath;
    }

    public SearchLandlordModel getLandlord() {
        return landlord;
    }

    public void setLandlord(SearchLandlordModel landlord) {
        this.landlord = landlord;
    }

    public SearchOccupancyModel getOccupancy() {
        return occupancy;
    }

    public void setOccupancy(SearchOccupancyModel occupancy) {
        this.occupancy = occupancy;
    }

    public SearchAssessmentModel getAssessment() {
        return assessment;
    }

    public void setAssessment(SearchAssessmentModel assessment) {
        this.assessment = assessment;
    }

    public SearchGeoRegistryModel getGeoRegistry() {
        return geoRegistry;
    }

    public void setGeoRegistry(SearchGeoRegistryModel geoRegistry) {
        this.geoRegistry = geoRegistry;
    }

    public List<Object> getPayments() {
        return payments;
    }

    public void setPayments(List<Object> payments) {
        this.payments = payments;
    }

    public List<SearchAssessmentHistoryModel> getAssessmentHistory() {
        return assessmentHistory;
    }

    public void setAssessmentHistory(List<SearchAssessmentHistoryModel> assessmentHistory) {
        this.assessmentHistory = assessmentHistory;
    }

}
