package com.dpm.payment.models;

import com.dpm.payment.NumberFormater;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class SearchAssessmentModel {


    @SerializedName("id")
    @Expose
    private Integer id;
    @SerializedName("property_id")
    @Expose
    private Integer propertyId;
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
    private String propertyRateWithoutGst;
    @SerializedName("property_gst")
    @Expose
    private String propertyGst;
    @SerializedName("property_rate_with_gst")
    @Expose
    private String propertyRateWithGst;
    @SerializedName("property_use")
    @Expose
    private SearchPropertyUseModel propertyUse;
    @SerializedName("zone")
    @Expose
    private SearchZoneModel zone;
    @SerializedName("no_of_mast")
    @Expose
    private String noOfMast;
    @SerializedName("no_of_shop")
    @Expose
    private String noOfShop;
    @SerializedName("no_of_compound_house")
    @Expose
    private String noOfCompoundHouse;
    @SerializedName("compound_name")
    @Expose
    private String compoundName;
    @SerializedName("gated_community")
    @Expose
    private String gatedCommunity;


    @SerializedName("swimming_id")
    @Expose
    private String swimmingId;
    @SerializedName("assessment_images_2")
    @Expose
    private String assessmentImages2;
    @SerializedName("assessment_images_1")
    @Expose
    private String assessmentImages1;
    @SerializedName("demand_note_delivered_at")
    @Expose
    private String demandNoteDeliveredAt;
    @SerializedName("demand_note_recipient_name")
    @Expose
    private String demandNoteRecipientName;
    @SerializedName("demand_note_recipient_mobile")
    @Expose
    private String demandNoteRecipientMobile;
    @SerializedName("demand_note_recipient_photo")
    @Expose
    private String demandNoteRecipientPhoto;
    @SerializedName("last_printed_at")
    @Expose
    private String lastPrintedAt;
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
    private String swimmingPool;
    @SerializedName("is_demand_note_delivered")
    @Expose
    private Boolean isDemandNoteDelivered;
    @SerializedName("demand_note_recipient_photo_url")
    @Expose
    private String demandNoteRecipientPhotoUrl;
    @SerializedName("current_year_assessment_amount")
    @Expose
    private String currentYearAssessmentAmount;
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
    private String balance;
    @SerializedName("assessment_year")
    @Expose
    private String assessmentYear;

    @SerializedName("discounted_value")
    @Expose
    private String discounted_value;

    @SerializedName("rate_payable")
    @Expose
    private String rate_payable;

    @SerializedName("rate_payable_new")
    private String rate_payable_new;

    @SerializedName("discounted_value_new")
    private String discounted_value_new;

    @SerializedName("property_net_assessed_vaue")
    @Expose
    private String property_net_assessed_vaue;

    @SerializedName("council_adjustments_parameters")
    @Expose
    private String council_adjustments_parameters;

    @SerializedName("discounted_rate_payable_2022")
    @Expose
    private String discounted_rate_payable_2022;


    @SerializedName("balance_due_new")
    @Expose
    private String balance_due_new;

    @SerializedName("new_balance_due")
    @Expose
    private String new_balance_due;


    @SerializedName("categories")
    @Expose
    private List<SearchCategoryModel> categories = null;


    @SerializedName("types")
    @Expose
    private List<SearchTypeModel> types = null;
    @SerializedName("wall_material")
    @Expose
    private SearchWallMaterialModel wallMaterial;
    @SerializedName("roof_material")
    @Expose
    private SearchRoofMaterialModel roofMaterial;
    @SerializedName("values_added")
    @Expose
    private List<SearchValueAddedModel> valuesAdded = null;
    @SerializedName("dimension")
    @Expose
    private SearchDimensionModel dimension;


    @SerializedName("swimming")
    @Expose
    private AssessmentSwimming swimming;

    @SerializedName("pensioner_discount")
    @Expose
    private String pensioner_discount;



    @SerializedName("disability_discount")
    @Expose
    private String disability_discount;


    @SerializedName("balance_due")
    @Expose
    private String balance_due;
  @SerializedName("discounted_rate_payable")
    @Expose
    private String discounted_rate_payable;


    public String getDiscounted_rate_payable() {
        return discounted_rate_payable;
    }

    public void setDiscounted_rate_payable(String discounted_rate_payable) {
        this.discounted_rate_payable = discounted_rate_payable;
    }

    public String getBalanceDue() {
        return balance_due;
    }

    public String getPensioner_discount() {
        return pensioner_discount;
    }

    public String getDisability_discount() {
        return disability_discount;
    }

    public String getNew_balance_due() {
        return new_balance_due;
    }

    public void setNew_balance_due(String new_balance_due) {
        this.new_balance_due = new_balance_due;
    }

    public String getBalance_due_new() {
        return balance_due_new;
    }

    public void setBalance_due_new(String balance_due_new) {
        this.balance_due_new = balance_due_new;
    }

    public String getRate_payable_new() {
        return rate_payable_new;
    }

    public void setRate_payable_new(String rate_payable_new) {
        this.rate_payable_new = rate_payable_new;
    }

    public String getDiscounted_value_new() {
        return discounted_value_new;
    }

    public void setDiscounted_value_new(String discounted_value_new) {
        this.discounted_value_new = discounted_value_new;
    }

    public String getDiscounted_rate_payable_2022() {
        return discounted_rate_payable_2022;
    }

    public void setDiscounted_rate_payable_2022(String discounted_rate_payable_2022) {
        this.discounted_rate_payable_2022 = discounted_rate_payable_2022;
    }

    public String getCouncil_adjustments_parameters() {
        return council_adjustments_parameters;
    }

    public void setCouncil_adjustments_parameters(String council_adjustments_parameters) {
        this.council_adjustments_parameters = council_adjustments_parameters;
    }

    public Boolean getDemandNoteDelivered() {
        return isDemandNoteDelivered;
    }

    public void setDemandNoteDelivered(Boolean demandNoteDelivered) {
        isDemandNoteDelivered = demandNoteDelivered;
    }

    public String getDiscounted_value() {
        return discounted_value;
    }

    public void setDiscounted_value(String discounted_value) {
        this.discounted_value = discounted_value;
    }

    public String getRate_payable() {
        return rate_payable;
    }

    public void setRate_payable(String rate_payable) {
        this.rate_payable = rate_payable;
    }

    public String getProperty_net_assessed_vaue() {
        return property_net_assessed_vaue;
    }

    public void setProperty_net_assessed_vaue(String property_net_assessed_vaue) {
        this.property_net_assessed_vaue = property_net_assessed_vaue;
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

    public SearchPropertyUseModel getPropertyUse() {
        return propertyUse;
    }

    public void setPropertyUse(SearchPropertyUseModel propertyUse) {
        this.propertyUse = propertyUse;
    }

    public SearchZoneModel getZone() {
        return zone;
    }

    public void setZone(SearchZoneModel zone) {
        this.zone = zone;
    }

    public String getNoOfMast() {
        return noOfMast;
    }

    public void setNoOfMast(String noOfMast) {
        this.noOfMast = noOfMast;
    }

    public String getNoOfShop() {
        return noOfShop;
    }

    public void setNoOfShop(String noOfShop) {
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

    public String getGatedCommunity() {
        return gatedCommunity;
    }

    public void setGatedCommunity(String gatedCommunity) {
        this.gatedCommunity = gatedCommunity;
    }

    public String getSwimmingId() {
        return swimmingId;
    }

    public void setSwimmingId(String swimmingId) {
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

    public String getDemandNoteDeliveredAt() {
        return demandNoteDeliveredAt;
    }

    public void setDemandNoteDeliveredAt(String demandNoteDeliveredAt) {
        this.demandNoteDeliveredAt = demandNoteDeliveredAt;
    }

    public String getDemandNoteRecipientName() {
        return demandNoteRecipientName;
    }

    public void setDemandNoteRecipientName(String demandNoteRecipientName) {
        this.demandNoteRecipientName = demandNoteRecipientName;
    }

    public String getDemandNoteRecipientMobile() {
        return demandNoteRecipientMobile;
    }

    public void setDemandNoteRecipientMobile(String demandNoteRecipientMobile) {
        this.demandNoteRecipientMobile = demandNoteRecipientMobile;
    }

    public String getDemandNoteRecipientPhoto() {
        return demandNoteRecipientPhoto;
    }

    public void setDemandNoteRecipientPhoto(String demandNoteRecipientPhoto) {
        this.demandNoteRecipientPhoto = demandNoteRecipientPhoto;
    }

    public String getLastPrintedAt() {
        return lastPrintedAt;
    }

    public void setLastPrintedAt(String lastPrintedAt) {
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

    public String getSwimmingPool() {
        return swimmingPool;
    }

    public void setSwimmingPool(String swimmingPool) {
        this.swimmingPool = swimmingPool;
    }

    public Boolean getIsDemandNoteDelivered() {
        return isDemandNoteDelivered;
    }

    public void setIsDemandNoteDelivered(Boolean isDemandNoteDelivered) {
        this.isDemandNoteDelivered = isDemandNoteDelivered;
    }

    public String getDemandNoteRecipientPhotoUrl() {
        return demandNoteRecipientPhotoUrl;
    }

    public void setDemandNoteRecipientPhotoUrl(String demandNoteRecipientPhotoUrl) {
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
        return NumberFormater.Companion.formatToTwoDecimalPlaces(NumberFormater.Companion.parseDouble(balance));
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

    public List<SearchCategoryModel> getCategories() {
        return categories;
    }

    public void setCategories(List<SearchCategoryModel> categories) {
        this.categories = categories;
    }

    public List<SearchTypeModel> getTypes() {
        return types;
    }

    public void setTypes(List<SearchTypeModel> types) {
        this.types = types;
    }

    public SearchWallMaterialModel getWallMaterial() {
        return wallMaterial;
    }

    public void setWallMaterial(SearchWallMaterialModel wallMaterial) {
        this.wallMaterial = wallMaterial;
    }

    public SearchRoofMaterialModel getRoofMaterial() {
        return roofMaterial;
    }

    public void setRoofMaterial(SearchRoofMaterialModel roofMaterial) {
        this.roofMaterial = roofMaterial;
    }

    public List<SearchValueAddedModel> getValuesAdded() {
        return valuesAdded;
    }

    public void setValuesAdded(List<SearchValueAddedModel> valuesAdded) {
        this.valuesAdded = valuesAdded;
    }

    public SearchDimensionModel getDimension() {
        return dimension;
    }

    public void setDimension(SearchDimensionModel dimension) {
        this.dimension = dimension;
    }

    public AssessmentSwimming getSwimming() {
        return swimming;
    }

    public void setSwimming(AssessmentSwimming swimming) {
        this.swimming = swimming;
    }


}
