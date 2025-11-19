package com.dpm.payment.models;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class AssessmentHistory {

    @SerializedName("id")
    private String id;
    @SerializedName("property_id")
    private String propertyId;
    @SerializedName("property_categories")

    private String propertyCategories;
    @SerializedName("property_wall_materials")

    private String propertyWallMaterials;
    @SerializedName("roofs_materials")

    private String roofsMaterials;
    @SerializedName("property_dimension")

    private String propertyDimension;
    @SerializedName("property_rate_without_gst")

    private String propertyRateWithoutGst;
    @SerializedName("property_gst")

    private String propertyGst;
    @SerializedName("property_rate_with_gst")

    private String propertyRateWithGst;
    @SerializedName("property_use")

    private String propertyUse;
    @SerializedName("zone")

    private String zone;
    @SerializedName("no_of_mast")

    private Object noOfMast;
    @SerializedName("no_of_shop")

    private Object noOfShop;
    @SerializedName("no_of_compound_house")

    private Object noOfCompoundHouse;
    @SerializedName("compound_name")

    private Object compoundName;
    @SerializedName("gated_community")

    private Object gatedCommunity;
    @SerializedName("swimming_id")

    private Object swimmingId;
    @SerializedName("assessment_images_2")

    private String assessmentImages2;
    @SerializedName("assessment_images_1")

    private String assessmentImages1;
    @SerializedName("demand_note_delivered_at")

    private Object demandNoteDeliveredAt;
    @SerializedName("demand_note_recipient_name")

    private Object demandNoteRecipientName;
    @SerializedName("demand_note_recipient_mobile")

    private Object demandNoteRecipientMobile;
    @SerializedName("demand_note_recipient_photo")

    private Object demandNoteRecipientPhoto;
    @SerializedName("last_printed_at")

    private Object lastPrintedAt;
    @SerializedName("created_at")

    private String createdAt;
    @SerializedName("updated_at")

    private String updatedAt;
    @SerializedName("original_one")

    private String originalOne;
    @SerializedName("small_preview_one")

    private String smallPreviewOne;
    @SerializedName("large_preview_one")

    private String largePreviewOne;
    @SerializedName("original_two")

    private String originalTwo;
    @SerializedName("small_preview_two")

    private String smallPreviewTwo;
    @SerializedName("large_preview_two")

    private String largePreviewTwo;
    @SerializedName("swimming_pool")

    private Object swimmingPool;
    @SerializedName("is_demand_note_delivered")

    private Boolean isDemandNoteDelivered;
    @SerializedName("demand_note_recipient_photo_url")

    private Object demandNoteRecipientPhotoUrl;
    @SerializedName("current_year_assessment_amount")

    private String currentYearAssessmentAmount;
    @SerializedName("arrear_due")
    private String arrearDue;

    @SerializedName("penalty")

    private String penalty;
    @SerializedName("amount_paid")

    private String amountPaid;
    @SerializedName("balance")

    private String balance;
    @SerializedName("assessment_year")
    private String assessmentYear;

    @SerializedName("amount_due")
    private String amountDue;


    @SerializedName("counsilAdjustment")
    private String counsilAdjustment;


    @SerializedName("ratePayable")
    private String ratePayable;


    @SerializedName("discountApplicable")
    private String discountApplicable;


    @SerializedName("discountRatePayable")
    private String discountRatePayable;

    @SerializedName("assedValue")
    private String assedValue;

    @SerializedName("balanceDueNew")
    @Expose
    private String balance_due_new;

    public String getBalance_due_new() {
        return balance_due_new;
    }

    public void setBalance_due_new(String balance_due_new) {
        this.balance_due_new = balance_due_new;
    }

    public String getAssedValue() {
        return assedValue;
    }

    public void setAssedValue(String assedValue) {
        this.assedValue = assedValue;
    }

    public String getCounsilAdjustment() {
        return counsilAdjustment;
    }

    public void setCounsilAdjustment(String counsilAdjustment) {
        this.counsilAdjustment = counsilAdjustment;
    }

    public String getRatePayable() {
        return ratePayable;
    }

    public void setRatePayable(String ratePayable) {
        this.ratePayable = ratePayable;
    }

    public String getDiscountApplicable() {
        return discountApplicable;
    }

    public void setDiscountApplicable(String discountApplicable) {
        this.discountApplicable = discountApplicable;
    }

    public String getDiscountRatePayable() {
        return discountRatePayable;
    }

    public void setDiscountRatePayable(String discountRatePayable) {
        this.discountRatePayable = discountRatePayable;
    }

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

    public String getPropertyRateWithoutGst() {
        return propertyRateWithoutGst;
    }

    public void setPropertyRateWithoutGst(String propertyRateWithoutGst) {
        this.propertyRateWithoutGst = propertyRateWithoutGst;
    }

    public String getPropertyGst() {
        return propertyGst;
    }

    public void setPropertyGst(String propertyGst) {
        this.propertyGst = propertyGst;
    }

    public String getPropertyRateWithGst() {
        return propertyRateWithGst;
    }

    public void setPropertyRateWithGst(String propertyRateWithGst) {
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

    public Object getNoOfCompoundHouse() {
        return noOfCompoundHouse;
    }

    public void setNoOfCompoundHouse(Object noOfCompoundHouse) {
        this.noOfCompoundHouse = noOfCompoundHouse;
    }

    public Object getCompoundName() {
        return compoundName;
    }

    public void setCompoundName(Object compoundName) {
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

    public String getCurrentYearAssessmentAmount() {
        return currentYearAssessmentAmount;
    }

    public void setCurrentYearAssessmentAmount(String currentYearAssessmentAmount) {
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
        return balance;
    }

    public void setBalance(String balance) {
        this.balance = balance;
    }

    public String getAssessmentYear() {
        return assessmentYear;
    }

    public void setAssessmentYear(String assessmentYear) {
        this.assessmentYear = assessmentYear;
    }

    public Boolean getDemandNoteDelivered() {
        return isDemandNoteDelivered;
    }

    public void setDemandNoteDelivered(Boolean demandNoteDelivered) {
        isDemandNoteDelivered = demandNoteDelivered;
    }


    public String getAmountDue() {
        return amountDue;
    }

    public void setAmountDue(String amountDue) {
        this.amountDue = amountDue;
    }

}

