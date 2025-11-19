package com.dpm.payment.models;

import androidx.annotation.Dimension;

import com.dpm.payment.NumberFormater;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class SearchAssessmentHistoryModel {



    @SerializedName("id")
    @Expose
    private String id;
    @SerializedName("property_id")
    @Expose
    private String propertyId;
    @SerializedName("property_categories")
    @Expose
    private String propertyCategories;
    @SerializedName("property_wall_materials")
    @Expose
    private String propertyWallMaterials;
    @SerializedName("roofs_materials")
    @Expose
    private String roofsMaterials;
    @SerializedName("property_dimension")
    @Expose
    private String propertyDimension;
    @SerializedName("property_rate_without_gst")
    @Expose
    private Double propertyRateWithoutGst;
    @SerializedName("property_gst")
    @Expose
    private Double propertyGst;
    @SerializedName("property_rate_with_gst")
    @Expose
    private Double propertyRateWithGst;
    @SerializedName("property_use")
    @Expose
    private String propertyUse;
    @SerializedName("zone")
    @Expose
    private String zone;
    @SerializedName("no_of_mast")
    @Expose
    private Object noOfMast;
    @SerializedName("no_of_shop")
    @Expose
    private Object noOfShop;
    @SerializedName("no_of_compound_house")
    @Expose
    private String noOfCompoundHouse;
    @SerializedName("compound_name")
    @Expose
    private String compoundName;
    @SerializedName("gated_community")
    @Expose
    private Object gatedCommunity;
    @SerializedName("swimming_id")
    @Expose
    private Object swimmingId;
    @SerializedName("assessment_images_2")
    @Expose
    private String assessmentImages2;
    @SerializedName("assessment_images_1")
    @Expose
    private String assessmentImages1;
    @SerializedName("demand_note_delivered_at")
    @Expose
    private Object demandNoteDeliveredAt;
    @SerializedName("demand_note_recipient_name")
    @Expose
    private Object demandNoteRecipientName;
    @SerializedName("demand_note_recipient_mobile")
    @Expose
    private Object demandNoteRecipientMobile;
    @SerializedName("demand_note_recipient_photo")
    @Expose
    private Object demandNoteRecipientPhoto;
    @SerializedName("last_printed_at")
    @Expose
    private Object lastPrintedAt;
    @SerializedName("created_at")
    @Expose
    private String createdAt;
    @SerializedName("updated_at")
    @Expose
    private String updatedAt;
    @SerializedName("original_one")
    @Expose
    private String originalOne;
    @SerializedName("small_preview_one")
    @Expose
    private String smallPreviewOne;
    @SerializedName("large_preview_one")
    @Expose
    private String largePreviewOne;
    @SerializedName("original_two")
    @Expose
    private String originalTwo;
    @SerializedName("small_preview_two")
    @Expose
    private String smallPreviewTwo;
    @SerializedName("large_preview_two")
    @Expose
    private String largePreviewTwo;
    @SerializedName("swimming_pool")
    @Expose
    private Object swimmingPool;
    @SerializedName("is_demand_note_delivered")
    @Expose
    private Boolean isDemandNoteDelivered;
    @SerializedName("demand_note_recipient_photo_url")
    @Expose
    private Object demandNoteRecipientPhotoUrl;
    @SerializedName("current_year_assessment_amount")
    @Expose
    private Double currentYearAssessmentAmount;
    @SerializedName("arrear_due")
    @Expose
    private String arrearDue;
    @SerializedName("penalty")
    @Expose
    private String penalty;
    @SerializedName("amount_paid")
    @Expose
    private String amountPaid;
    @SerializedName("balance")
    @Expose
    private Double balance;
    @SerializedName("assessment_year")
    @Expose
    private String assessmentYear;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPropertyId() {
        return propertyId;
    }

    public void setPropertyId(String propertyId) {
        this.propertyId = propertyId;
    }

    public String getPropertyCategories() {
        return propertyCategories;
    }

    public void setPropertyCategories(String propertyCategories) {
        this.propertyCategories = propertyCategories;
    }

    public String getPropertyWallMaterials() {
        return propertyWallMaterials;
    }

    public void setPropertyWallMaterials(String propertyWallMaterials) {
        this.propertyWallMaterials = propertyWallMaterials;
    }

    public String getRoofsMaterials() {
        return roofsMaterials;
    }

    public void setRoofsMaterials(String roofsMaterials) {
        this.roofsMaterials = roofsMaterials;
    }

    public String getPropertyDimension() {
        return propertyDimension;
    }

    public void setPropertyDimension(String propertyDimension) {
        this.propertyDimension = propertyDimension;
    }

    public Double getPropertyRateWithoutGst() {
        return propertyRateWithoutGst;
    }

    public void setPropertyRateWithoutGst(Double propertyRateWithoutGst) {
        this.propertyRateWithoutGst = propertyRateWithoutGst;
    }

    public Double getPropertyGst() {
        return propertyGst;
    }

    public void setPropertyGst(Double propertyGst) {
        this.propertyGst = propertyGst;
    }

    public Double getPropertyRateWithGst() {
        return propertyRateWithGst;
    }

    public void setPropertyRateWithGst(Double propertyRateWithGst) {
        this.propertyRateWithGst = propertyRateWithGst;
    }

    public String getPropertyUse() {
        return propertyUse;
    }

    public void setPropertyUse(String propertyUse) {
        this.propertyUse = propertyUse;
    }

    public String getZone() {
        return zone;
    }

    public void setZone(String zone) {
        this.zone = zone;
    }

    public Object getNoOfMast() {
        return noOfMast;
    }

    public void setNoOfMast(Object noOfMast) {
        this.noOfMast = noOfMast;
    }

    public Object getNoOfShop() {
        return noOfShop;
    }

    public void setNoOfShop(Object noOfShop) {
        this.noOfShop = noOfShop;
    }

    public String getNoOfCompoundHouse() {
        return noOfCompoundHouse;
    }

    public void setNoOfCompoundHouse(String noOfCompoundHouse) {
        this.noOfCompoundHouse = noOfCompoundHouse;
    }

    public String getCompoundName() {
        return compoundName;
    }

    public void setCompoundName(String compoundName) {
        this.compoundName = compoundName;
    }

    public Object getGatedCommunity() {
        return gatedCommunity;
    }

    public void setGatedCommunity(Object gatedCommunity) {
        this.gatedCommunity = gatedCommunity;
    }

    public Object getSwimmingId() {
        return swimmingId;
    }

    public void setSwimmingId(Object swimmingId) {
        this.swimmingId = swimmingId;
    }

    public String getAssessmentImages2() {
        return assessmentImages2;
    }

    public void setAssessmentImages2(String assessmentImages2) {
        this.assessmentImages2 = assessmentImages2;
    }

    public String getAssessmentImages1() {
        return assessmentImages1;
    }

    public void setAssessmentImages1(String assessmentImages1) {
        this.assessmentImages1 = assessmentImages1;
    }

    public Object getDemandNoteDeliveredAt() {
        return demandNoteDeliveredAt;
    }

    public void setDemandNoteDeliveredAt(Object demandNoteDeliveredAt) {
        this.demandNoteDeliveredAt = demandNoteDeliveredAt;
    }

    public Object getDemandNoteRecipientName() {
        return demandNoteRecipientName;
    }

    public void setDemandNoteRecipientName(Object demandNoteRecipientName) {
        this.demandNoteRecipientName = demandNoteRecipientName;
    }

    public Object getDemandNoteRecipientMobile() {
        return demandNoteRecipientMobile;
    }

    public void setDemandNoteRecipientMobile(Object demandNoteRecipientMobile) {
        this.demandNoteRecipientMobile = demandNoteRecipientMobile;
    }

    public Object getDemandNoteRecipientPhoto() {
        return demandNoteRecipientPhoto;
    }

    public void setDemandNoteRecipientPhoto(Object demandNoteRecipientPhoto) {
        this.demandNoteRecipientPhoto = demandNoteRecipientPhoto;
    }

    public Object getLastPrintedAt() {
        return lastPrintedAt;
    }

    public void setLastPrintedAt(Object lastPrintedAt) {
        this.lastPrintedAt = lastPrintedAt;
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

    public String getOriginalOne() {
        return originalOne;
    }

    public void setOriginalOne(String originalOne) {
        this.originalOne = originalOne;
    }

    public String getSmallPreviewOne() {
        return smallPreviewOne;
    }

    public void setSmallPreviewOne(String smallPreviewOne) {
        this.smallPreviewOne = smallPreviewOne;
    }

    public String getLargePreviewOne() {
        return largePreviewOne;
    }

    public void setLargePreviewOne(String largePreviewOne) {
        this.largePreviewOne = largePreviewOne;
    }

    public String getOriginalTwo() {
        return originalTwo;
    }

    public void setOriginalTwo(String originalTwo) {
        this.originalTwo = originalTwo;
    }

    public String getSmallPreviewTwo() {
        return smallPreviewTwo;
    }

    public void setSmallPreviewTwo(String smallPreviewTwo) {
        this.smallPreviewTwo = smallPreviewTwo;
    }

    public String getLargePreviewTwo() {
        return largePreviewTwo;
    }

    public void setLargePreviewTwo(String largePreviewTwo) {
        this.largePreviewTwo = largePreviewTwo;
    }

    public Object getSwimmingPool() {
        return swimmingPool;
    }

    public void setSwimmingPool(Object swimmingPool) {
        this.swimmingPool = swimmingPool;
    }

    public Boolean getIsDemandNoteDelivered() {
        return isDemandNoteDelivered;
    }

    public void setIsDemandNoteDelivered(Boolean isDemandNoteDelivered) {
        this.isDemandNoteDelivered = isDemandNoteDelivered;
    }

    public Object getDemandNoteRecipientPhotoUrl() {
        return demandNoteRecipientPhotoUrl;
    }

    public void setDemandNoteRecipientPhotoUrl(Object demandNoteRecipientPhotoUrl) {
        this.demandNoteRecipientPhotoUrl = demandNoteRecipientPhotoUrl;
    }

    public Double getCurrentYearAssessmentAmount() {
        return currentYearAssessmentAmount;
    }

    public void setCurrentYearAssessmentAmount(Double currentYearAssessmentAmount) {
        this.currentYearAssessmentAmount = currentYearAssessmentAmount;
    }

    public String getArrearDue() {
        return arrearDue;
    }

    public void setArrearDue(String arrearDue) {
        this.arrearDue = arrearDue;
    }

    public String getPenalty() {
        return penalty;
    }

    public void setPenalty(String penalty) {
        this.penalty = penalty;
    }

    public String getAmountPaid() {
        return amountPaid;
    }

    public void setAmountPaid(String amountPaid) {
        this.amountPaid = amountPaid;
    }

    public String getBalance() {
        return NumberFormater.Companion.formatToTwoDecimalPlaces(balance);
    }

    public void setBalance(Double balance) {
        this.balance = balance;
    }

    public String getAssessmentYear() {
        return assessmentYear;
    }

    public void setAssessmentYear(String assessmentYear) {
        this.assessmentYear = assessmentYear;
    }


}
