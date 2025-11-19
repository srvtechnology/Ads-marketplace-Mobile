package com.dpm.payment.models.propertydetail;

import java.util.List;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Assessment {

    @SerializedName("roofs_materials")
    private String roofsMaterials;

    @SerializedName("gated_community")
    private String gatedCommunity;

    @SerializedName("amount_paid")
    private String amountPaid;

    @SerializedName("breadth")
    private String breadth;

    @SerializedName("electricity_percentage")
    private String electricityPercentage;

    @SerializedName("demand_note_recipient_photo_url")
    private String demandNoteRecipientPhotoUrl;

    @SerializedName("demand_note_recipient_name")
    private String demandNoteRecipientName;

    @SerializedName("window_type")
    private WindowType windowType;

    @SerializedName("rate_payable")
    private String rate_payable;


    @SerializedName("rate_payable_new")
    private String rate_payable_new;

    @SerializedName("discounted_value")
    private String discounted_value;

    @SerializedName("property_net_assessed_vaue")
    private String property_net_assessed_value;

    @SerializedName("council_adjustments_parameters")
    private String council_adjustments_parameters;


    @SerializedName("wall_material_type")
    private String wallMaterialType;

    @SerializedName("property_categories")
    private String propertyCategories;

    @SerializedName("original_one")
    private String originalOne;

    @SerializedName("informal_settlement_percentage")
    private String informalSettlementPercentage;

    @SerializedName("value_added_type")
    private String valueAddedType;

    @SerializedName("values_added")
    private List<ValuesAddedItem> valuesAdded;

    @SerializedName("drainage_percentage")
    private String drainagePercentage;

    @SerializedName("balance")
    private String balance;

    @SerializedName("zone")
    private Zone zone;

    @SerializedName("is_demand_note_delivered")
    private boolean isDemandNoteDelivered;

    @SerializedName("current_installment_due_amount")
    private String currentInstallmentDueAmount;

    @SerializedName("id")
    private String id;

    @SerializedName("property_rate_with_gst")
    private String propertyRateWithGst;

    @SerializedName("paved_tarred_street_percentage")
    private String pavedTarredStreetPercentage;

    @SerializedName("wall_material")
    private WallMaterial wallMaterial;

    @SerializedName("window_type_percentage")
    private String windowTypePercentage;

    @SerializedName("swimming_pool")
    private String swimmingPool;

    @SerializedName("sanitation_type")
    private SanitationType sanitationType;

  @SerializedName("discounted_rate_payable_2022")
    private String discounted_rate_payable_2022;


/*	@SerializedName("pensioner_discount")
	private SanitationType pensioner_discount;

	@SerializedName("disability_discount")
	private SanitationType disability_discount;*/

    @SerializedName("group_name")
    private String groupName;

    @SerializedName("assessment_year")
    private String assessmentYear;

    @SerializedName("waste_management_percentage")
    private String wasteManagementPercentage;

    @SerializedName("no_of_compound_house")
    private String noOfCompoundHouse;

    @SerializedName("assessment_square_meter")
    private String assessmentSquareMeter;

    @SerializedName("original_two")
    private String originalTwo;

    @SerializedName("property_id")
    private String propertyId;

    @SerializedName("demand_note_delivered_at")
    private String demandNoteDeliveredAt;

    @SerializedName("wall_material_percentage")
    private String wallMaterialPercentage;

    @SerializedName("demand_note_recipient_photo")
    private String demandNoteRecipientPhoto;

    @SerializedName("assessment_images_2")
    private String assessmentImages2;

    @SerializedName("value_added_percentage")
    private String valueAddedPercentage;

    @SerializedName("hazardous_precentage")
    private String hazardousPrecentage;

    @SerializedName("roof_material")
    private RoofMaterial roofMaterial;

    @SerializedName("is_map_set")
    private String isMapSet;

    @SerializedName("assessment_images_1")
    private String assessmentImages1;

    @SerializedName("roof_material_type")
    private String roofMaterialType;

    @SerializedName("property_rate_without_gst")
    private String propertyRateWithoutGst;


    @SerializedName("square_meter")
    private String squareMeter;

    @SerializedName("property_window_type")
    private String propertyWindowType;

    @SerializedName("window_type_type")
    private String windowTypeType;

    @SerializedName("no_of_mast")
    private String noOfMast;

    @SerializedName("demand_note_recipient_mobile")
    private String demandNoteRecipientMobile;

    @SerializedName("penalty")
    private String penalty;

    @SerializedName("created_at")
    private String createdAt;

    @SerializedName("pensioner_discount")
    private String pensionerDiscount;

    @SerializedName("property_wall_materials")
    private String propertyWallMaterials;

    @SerializedName("sanitation")
    private String sanitation;

    @SerializedName("swimming")
    private Swimming swimming;

    @SerializedName("disability_discount")
    private String disabilityDiscount;

    @SerializedName("updated_at")
    private String updatedAt;

    @SerializedName("total_adjustment_percent")
    private String totalAdjustmentPercent;

    @SerializedName("compound_name")
    private String compoundName;

    @SerializedName("small_preview_one")
    private String smallPreviewOne;

    @SerializedName("categories")
    private List<CategoriesItem> categories;

    @SerializedName("large_preview_two")
    private String largePreviewTwo;

    @SerializedName("dimension")
    private String dimension;

    @SerializedName("property_dimension")
    private String propertyDimension;

    @SerializedName("property_use")
    private PropertyUse propertyUse;

    @SerializedName("market_percentage")
    private String marketPercentage;

    @SerializedName("types")
    private List<TypesItem> types;

    @SerializedName("property_gst")
    private String propertyGst;

    @SerializedName("assessment_length")
    private String assessmentLength;

    @SerializedName("large_preview_one")
    private String largePreviewOne;

    @SerializedName("length")
    private String length;

    @SerializedName("last_prStringed_at")
    private String lastPrStringedAt;

    @SerializedName("water_percentage")
    private String waterPercentage;

    @SerializedName("arrear_due")
    private String arrearDue;

    @SerializedName("council_group_name")
    private String councilGroupName;

    @SerializedName("roof_material_percentage")
    private String roofMaterialPercentage;

    @SerializedName("current_year_assessment_amount")
    private String currentYearAssessmentAmount;

    @SerializedName("easy_street_access_percentage")
    private String easyStreetAccessPercentage;

    @SerializedName("mill_rate")
    private String millRate;

    @SerializedName("no_of_shop")
    private String noOfShop;

    @SerializedName("small_preview_two")
    private String smallPreviewTwo;

    @SerializedName("swimming_id")
    private String swimmingId;

    @SerializedName("assessment_breadth")
    private String assessmentBreadth;



    @SerializedName("balance_due")
    @Expose
    private String balance_due;

    @SerializedName("discounted_rate_payable")
    @Expose
    private String discounted_rate_payable;


    public String getDiscounted_rate_payable() {
        return discounted_rate_payable;
    }


    public String getBalanceDue() {
        return balance_due;
    }


    public String getDiscounted_rate_payable_2022() {
        return discounted_rate_payable_2022;
    }

    public void setDiscounted_rate_payable_2022(String discounted_rate_payable_2022) {
        this.discounted_rate_payable_2022 = discounted_rate_payable_2022;
    }

    public void setRate_payable(String rate_payable) {
        this.rate_payable = rate_payable;
    }

    public String getRate_payable_new() {
        return rate_payable_new;
    }

    public void setRate_payable_new(String rate_payable_new) {
        this.rate_payable_new = rate_payable_new;
    }

    public String getDiscounted_value() {
        return discounted_value;
    }

    public void setDiscounted_value(String discounted_value) {
        this.discounted_value = discounted_value;
    }

    public void setProperty_net_assessed_value(String property_net_assessed_value) {
        this.property_net_assessed_value = property_net_assessed_value;
    }

    public void setDemandNoteDelivered(boolean demandNoteDelivered) {
        isDemandNoteDelivered = demandNoteDelivered;
    }

    public String getCouncil_adjustments_parameters() {
        return council_adjustments_parameters;
    }

    public void setCouncil_adjustments_parameters(String council_adjustments_parameters) {
        this.council_adjustments_parameters = council_adjustments_parameters;
    }

    public String getProperty_net_assessed_value() {
        return property_net_assessed_value;
    }

    public boolean isDemandNoteDelivered() {
        return isDemandNoteDelivered;
    }

    public String getRate_payable() {
        return rate_payable;
    }

    public void setRoofsMaterials(String roofsMaterials) {
        this.roofsMaterials = roofsMaterials;
    }

    public String getRoofsMaterials() {
        return roofsMaterials;
    }

    public void setGatedCommunity(String gatedCommunity) {
        this.gatedCommunity = gatedCommunity;
    }

    public String getGatedCommunity() {
        return gatedCommunity;
    }

    public void setAmountPaid(String amountPaid) {
        this.amountPaid = amountPaid;
    }

    public String getAmountPaid() {
        return amountPaid;
    }

    public void setBreadth(String breadth) {
        this.breadth = breadth;
    }

    public String getBreadth() {
        return breadth;
    }

    public void setElectricityPercentage(String electricityPercentage) {
        this.electricityPercentage = electricityPercentage;
    }

    public String getElectricityPercentage() {
        return electricityPercentage;
    }

    public void setDemandNoteRecipientPhotoUrl(String demandNoteRecipientPhotoUrl) {
        this.demandNoteRecipientPhotoUrl = demandNoteRecipientPhotoUrl;
    }

    public String getDemandNoteRecipientPhotoUrl() {
        return demandNoteRecipientPhotoUrl;
    }

    public void setDemandNoteRecipientName(String demandNoteRecipientName) {
        this.demandNoteRecipientName = demandNoteRecipientName;
    }

    public String getDemandNoteRecipientName() {
        return demandNoteRecipientName;
    }

    public void setWindowType(WindowType windowType) {
        this.windowType = windowType;
    }

    public WindowType getWindowType() {
        return windowType;
    }

    public void setWallMaterialType(String wallMaterialType) {
        this.wallMaterialType = wallMaterialType;
    }

    public String getWallMaterialType() {
        return wallMaterialType;
    }

    public void setPropertyCategories(String propertyCategories) {
        this.propertyCategories = propertyCategories;
    }

    public String getPropertyCategories() {
        return propertyCategories;
    }

    public void setOriginalOne(String originalOne) {
        this.originalOne = originalOne;
    }

    public String getOriginalOne() {
        return originalOne;
    }

    public void setInformalSettlementPercentage(String informalSettlementPercentage) {
        this.informalSettlementPercentage = informalSettlementPercentage;
    }

    public String getInformalSettlementPercentage() {
        return informalSettlementPercentage;
    }

    public void setValueAddedType(String valueAddedType) {
        this.valueAddedType = valueAddedType;
    }

    public String getValueAddedType() {
        return valueAddedType;
    }

    public void setValuesAdded(List<ValuesAddedItem> valuesAdded) {
        this.valuesAdded = valuesAdded;
    }

    public List<ValuesAddedItem> getValuesAdded() {
        return valuesAdded;
    }

    public void setDrainagePercentage(String drainagePercentage) {
        this.drainagePercentage = drainagePercentage;
    }

    public String getDrainagePercentage() {
        return drainagePercentage;
    }

    public void setBalance(String balance) {
        this.balance = balance;
    }

    public String getBalance() {
        return balance;
    }

    public void setZone(Zone zone) {
        this.zone = zone;
    }

    public Zone getZone() {
        return zone;
    }

    public void setIsDemandNoteDelivered(boolean isDemandNoteDelivered) {
        this.isDemandNoteDelivered = isDemandNoteDelivered;
    }

    public boolean isIsDemandNoteDelivered() {
        return isDemandNoteDelivered;
    }

    public void setCurrentInstallmentDueAmount(String currentInstallmentDueAmount) {
        this.currentInstallmentDueAmount = currentInstallmentDueAmount;
    }

    public String getCurrentInstallmentDueAmount() {
        return currentInstallmentDueAmount;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getId() {
        return id;
    }

    public void setPropertyRateWithGst(String propertyRateWithGst) {
        this.propertyRateWithGst = propertyRateWithGst;
    }

    public String getPropertyRateWithGst() {
        return propertyRateWithGst;
    }

    public void setPavedTarredStreetPercentage(String pavedTarredStreetPercentage) {
        this.pavedTarredStreetPercentage = pavedTarredStreetPercentage;
    }

    public String getPavedTarredStreetPercentage() {
        return pavedTarredStreetPercentage;
    }

    public void setWallMaterial(WallMaterial wallMaterial) {
        this.wallMaterial = wallMaterial;
    }

    public WallMaterial getWallMaterial() {
        return wallMaterial;
    }

    public void setWindowTypePercentage(String windowTypePercentage) {
        this.windowTypePercentage = windowTypePercentage;
    }

    public String getWindowTypePercentage() {
        return windowTypePercentage;
    }

    public void setSwimmingPool(String swimmingPool) {
        this.swimmingPool = swimmingPool;
    }

    public String getSwimmingPool() {
        return swimmingPool;
    }

    public void setSanitationType(SanitationType sanitationType) {
        this.sanitationType = sanitationType;
    }

    public SanitationType getSanitationType() {
        return sanitationType;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setAssessmentYear(String assessmentYear) {
        this.assessmentYear = assessmentYear;
    }

    public String getAssessmentYear() {
        return assessmentYear;
    }

    public void setWasteManagementPercentage(String wasteManagementPercentage) {
        this.wasteManagementPercentage = wasteManagementPercentage;
    }

    public String getWasteManagementPercentage() {
        return wasteManagementPercentage;
    }

    public void setNoOfCompoundHouse(String noOfCompoundHouse) {
        this.noOfCompoundHouse = noOfCompoundHouse;
    }

    public String getNoOfCompoundHouse() {
        return noOfCompoundHouse;
    }

    public void setAssessmentSquareMeter(String assessmentSquareMeter) {
        this.assessmentSquareMeter = assessmentSquareMeter;
    }

    public String getAssessmentSquareMeter() {
        return assessmentSquareMeter;
    }

    public void setOriginalTwo(String originalTwo) {
        this.originalTwo = originalTwo;
    }

    public String getOriginalTwo() {
        return originalTwo;
    }

    public void setPropertyId(String propertyId) {
        this.propertyId = propertyId;
    }

    public String getPropertyId() {
        return propertyId;
    }

    public void setDemandNoteDeliveredAt(String demandNoteDeliveredAt) {
        this.demandNoteDeliveredAt = demandNoteDeliveredAt;
    }

    public String getDemandNoteDeliveredAt() {
        return demandNoteDeliveredAt;
    }

    public void setWallMaterialPercentage(String wallMaterialPercentage) {
        this.wallMaterialPercentage = wallMaterialPercentage;
    }

    public String getWallMaterialPercentage() {
        return wallMaterialPercentage;
    }

    public void setDemandNoteRecipientPhoto(String demandNoteRecipientPhoto) {
        this.demandNoteRecipientPhoto = demandNoteRecipientPhoto;
    }

    public String getDemandNoteRecipientPhoto() {
        return demandNoteRecipientPhoto;
    }

    public void setAssessmentImages2(String assessmentImages2) {
        this.assessmentImages2 = assessmentImages2;
    }

    public String getAssessmentImages2() {
        return assessmentImages2;
    }

    public void setValueAddedPercentage(String valueAddedPercentage) {
        this.valueAddedPercentage = valueAddedPercentage;
    }

    public String getValueAddedPercentage() {
        return valueAddedPercentage;
    }

    public void setHazardousPrecentage(String hazardousPrecentage) {
        this.hazardousPrecentage = hazardousPrecentage;
    }

    public String getHazardousPrecentage() {
        return hazardousPrecentage;
    }

    public void setRoofMaterial(RoofMaterial roofMaterial) {
        this.roofMaterial = roofMaterial;
    }

    public RoofMaterial getRoofMaterial() {
        return roofMaterial;
    }

    public void setIsMapSet(String isMapSet) {
        this.isMapSet = isMapSet;
    }

    public String getIsMapSet() {
        return isMapSet;
    }

    public void setAssessmentImages1(String assessmentImages1) {
        this.assessmentImages1 = assessmentImages1;
    }

    public String getAssessmentImages1() {
        return assessmentImages1;
    }

    public void setRoofMaterialType(String roofMaterialType) {
        this.roofMaterialType = roofMaterialType;
    }

    public String getRoofMaterialType() {
        return roofMaterialType;
    }

    public void setPropertyRateWithoutGst(String propertyRateWithoutGst) {
        this.propertyRateWithoutGst = propertyRateWithoutGst;
    }

    public String getPropertyRateWithoutGst() {
        return propertyRateWithoutGst;
    }

    public void setSquareMeter(String squareMeter) {
        this.squareMeter = squareMeter;
    }

    public String getSquareMeter() {
        return squareMeter;
    }

    public void setPropertyWindowType(String propertyWindowType) {
        this.propertyWindowType = propertyWindowType;
    }

    public String getPropertyWindowType() {
        return propertyWindowType;
    }

    public void setWindowTypeType(String windowTypeType) {
        this.windowTypeType = windowTypeType;
    }

    public String getWindowTypeType() {
        return windowTypeType;
    }

    public void setNoOfMast(String noOfMast) {
        this.noOfMast = noOfMast;
    }

    public String getNoOfMast() {
        return noOfMast;
    }

    public void setDemandNoteRecipientMobile(String demandNoteRecipientMobile) {
        this.demandNoteRecipientMobile = demandNoteRecipientMobile;
    }

    public String getDemandNoteRecipientMobile() {
        return demandNoteRecipientMobile;
    }

    public void setPenalty(String penalty) {
        this.penalty = penalty;
    }

    public String getPenalty() {
        return penalty;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setPensionerDiscount(String pensionerDiscount) {
        this.pensionerDiscount = pensionerDiscount;
    }

    public String getPensionerDiscount() {
        return pensionerDiscount;
    }

    public void setPropertyWallMaterials(String propertyWallMaterials) {
        this.propertyWallMaterials = propertyWallMaterials;
    }

    public String getPropertyWallMaterials() {
        return propertyWallMaterials;
    }

    public void setSanitation(String sanitation) {
        this.sanitation = sanitation;
    }

    public String getSanitation() {
        return sanitation;
    }

    public void setSwimming(Swimming swimming) {
        this.swimming = swimming;
    }

    public Swimming getSwimming() {
        return swimming;
    }

    public void setDisabilityDiscount(String disabilityDiscount) {
        this.disabilityDiscount = disabilityDiscount;
    }

    public String getDisabilityDiscount() {
        return disabilityDiscount;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setTotalAdjustmentPercent(String totalAdjustmentPercent) {
        this.totalAdjustmentPercent = totalAdjustmentPercent;
    }

    public String getTotalAdjustmentPercent() {
        return totalAdjustmentPercent;
    }

    public void setCompoundName(String compoundName) {
        this.compoundName = compoundName;
    }

    public String getCompoundName() {
        return compoundName;
    }

    public void setSmallPreviewOne(String smallPreviewOne) {
        this.smallPreviewOne = smallPreviewOne;
    }

    public String getSmallPreviewOne() {
        return smallPreviewOne;
    }

    public void setCategories(List<CategoriesItem> categories) {
        this.categories = categories;
    }

    public List<CategoriesItem> getCategories() {
        return categories;
    }

    public void setLargePreviewTwo(String largePreviewTwo) {
        this.largePreviewTwo = largePreviewTwo;
    }

    public String getLargePreviewTwo() {
        return largePreviewTwo;
    }

    public void setDimension(String dimension) {
        this.dimension = dimension;
    }

    public String getDimension() {
        return dimension;
    }

    public void setPropertyDimension(String propertyDimension) {
        this.propertyDimension = propertyDimension;
    }

    public String getPropertyDimension() {
        return propertyDimension;
    }

    public void setPropertyUse(PropertyUse propertyUse) {
        this.propertyUse = propertyUse;
    }

    public PropertyUse getPropertyUse() {
        return propertyUse;
    }

    public void setMarketPercentage(String marketPercentage) {
        this.marketPercentage = marketPercentage;
    }

    public String getMarketPercentage() {
        return marketPercentage;
    }

    public void setTypes(List<TypesItem> types) {
        this.types = types;
    }

    public List<TypesItem> getTypes() {
        return types;
    }

    public void setPropertyGst(String propertyGst) {
        this.propertyGst = propertyGst;
    }

    public String getPropertyGst() {
        return propertyGst;
    }

    public void setAssessmentLength(String assessmentLength) {
        this.assessmentLength = assessmentLength;
    }

    public String getAssessmentLength() {
        return assessmentLength;
    }

    public void setLargePreviewOne(String largePreviewOne) {
        this.largePreviewOne = largePreviewOne;
    }

    public String getLargePreviewOne() {
        return largePreviewOne;
    }

    public void setLength(String length) {
        this.length = length;
    }

    public String getLength() {
        return length;
    }

    public void setLastPrStringedAt(String lastPrStringedAt) {
        this.lastPrStringedAt = lastPrStringedAt;
    }

    public String getLastPrStringedAt() {
        return lastPrStringedAt;
    }

    public void setWaterPercentage(String waterPercentage) {
        this.waterPercentage = waterPercentage;
    }

    public String getWaterPercentage() {
        return waterPercentage;
    }

    public void setArrearDue(String arrearDue) {
        this.arrearDue = arrearDue;
    }

    public String getArrearDue() {
        return arrearDue;
    }

    public void setCouncilGroupName(String councilGroupName) {
        this.councilGroupName = councilGroupName;
    }

    public String getCouncilGroupName() {
        return councilGroupName;
    }

    public void setRoofMaterialPercentage(String roofMaterialPercentage) {
        this.roofMaterialPercentage = roofMaterialPercentage;
    }

    public String getRoofMaterialPercentage() {
        return roofMaterialPercentage;
    }

    public void setCurrentYearAssessmentAmount(String currentYearAssessmentAmount) {
        this.currentYearAssessmentAmount = currentYearAssessmentAmount;
    }

    public String getCurrentYearAssessmentAmount() {
        return currentYearAssessmentAmount;
    }

    public void setEasyStreetAccessPercentage(String easyStreetAccessPercentage) {
        this.easyStreetAccessPercentage = easyStreetAccessPercentage;
    }

    public String getEasyStreetAccessPercentage() {
        return easyStreetAccessPercentage;
    }

    public void setMillRate(String millRate) {
        this.millRate = millRate;
    }

    public String getMillRate() {
        return millRate;
    }

    public void setNoOfShop(String noOfShop) {
        this.noOfShop = noOfShop;
    }

    public String getNoOfShop() {
        return noOfShop;
    }

    public void setSmallPreviewTwo(String smallPreviewTwo) {
        this.smallPreviewTwo = smallPreviewTwo;
    }

    public String getSmallPreviewTwo() {
        return smallPreviewTwo;
    }

    public void setSwimmingId(String swimmingId) {
        this.swimmingId = swimmingId;
    }

    public String getSwimmingId() {
        return swimmingId;
    }

    public void setAssessmentBreadth(String assessmentBreadth) {
        this.assessmentBreadth = assessmentBreadth;
    }

    public String getAssessmentBreadth() {
        return assessmentBreadth;
    }

    @Override
    public String toString() {
        return
                "Assessment{" +
                        "roofs_materials = '" + roofsMaterials + '\'' +
                        ",gated_community = '" + gatedCommunity + '\'' +
                        ",amount_paid = '" + amountPaid + '\'' +
                        ",breadth = '" + breadth + '\'' +
                        ",electricity_percentage = '" + electricityPercentage + '\'' +
                        ",demand_note_recipient_photo_url = '" + demandNoteRecipientPhotoUrl + '\'' +
                        ",demand_note_recipient_name = '" + demandNoteRecipientName + '\'' +
                        ",window_type = '" + windowType + '\'' +
                        ",wall_material_type = '" + wallMaterialType + '\'' +
                        ",property_categories = '" + propertyCategories + '\'' +
                        ",original_one = '" + originalOne + '\'' +
                        ",informal_settlement_percentage = '" + informalSettlementPercentage + '\'' +
                        ",value_added_type = '" + valueAddedType + '\'' +
                        ",values_added = '" + valuesAdded + '\'' +
                        ",drainage_percentage = '" + drainagePercentage + '\'' +
                        ",balance = '" + balance + '\'' +
                        ",zone = '" + zone + '\'' +
                        ",is_demand_note_delivered = '" + isDemandNoteDelivered + '\'' +
                        ",current_installment_due_amount = '" + currentInstallmentDueAmount + '\'' +
                        ",id = '" + id + '\'' +
                        ",property_rate_with_gst = '" + propertyRateWithGst + '\'' +
                        ",paved_tarred_street_percentage = '" + pavedTarredStreetPercentage + '\'' +
                        ",wall_material = '" + wallMaterial + '\'' +
                        ",window_type_percentage = '" + windowTypePercentage + '\'' +
                        ",swimming_pool = '" + swimmingPool + '\'' +
                        ",sanitation_type = '" + sanitationType + '\'' +
                        ",group_name = '" + groupName + '\'' +
                        ",assessment_year = '" + assessmentYear + '\'' +
                        ",waste_management_percentage = '" + wasteManagementPercentage + '\'' +
                        ",no_of_compound_house = '" + noOfCompoundHouse + '\'' +
                        ",assessment_square_meter = '" + assessmentSquareMeter + '\'' +
                        ",original_two = '" + originalTwo + '\'' +
                        ",property_id = '" + propertyId + '\'' +
                        ",demand_note_delivered_at = '" + demandNoteDeliveredAt + '\'' +
                        ",wall_material_percentage = '" + wallMaterialPercentage + '\'' +
                        ",demand_note_recipient_photo = '" + demandNoteRecipientPhoto + '\'' +
                        ",assessment_images_2 = '" + assessmentImages2 + '\'' +
                        ",value_added_percentage = '" + valueAddedPercentage + '\'' +
                        ",hazardous_precentage = '" + hazardousPrecentage + '\'' +
                        ",roof_material = '" + roofMaterial + '\'' +
                        ",is_map_set = '" + isMapSet + '\'' +
                        ",assessment_images_1 = '" + assessmentImages1 + '\'' +
                        ",roof_material_type = '" + roofMaterialType + '\'' +
                        ",property_rate_without_gst = '" + propertyRateWithoutGst + '\'' +
                        ",square_meter = '" + squareMeter + '\'' +
                        ",property_window_type = '" + propertyWindowType + '\'' +
                        ",window_type_type = '" + windowTypeType + '\'' +
                        ",no_of_mast = '" + noOfMast + '\'' +
                        ",demand_note_recipient_mobile = '" + demandNoteRecipientMobile + '\'' +
                        ",penalty = '" + penalty + '\'' +
                        ",created_at = '" + createdAt + '\'' +
                        ",pensioner_discount = '" + pensionerDiscount + '\'' +
                        ",property_wall_materials = '" + propertyWallMaterials + '\'' +
                        ",sanitation = '" + sanitation + '\'' +
                        ",swimming = '" + swimming + '\'' +
                        ",disability_discount = '" + disabilityDiscount + '\'' +
                        ",updated_at = '" + updatedAt + '\'' +
                        ",total_adjustment_percent = '" + totalAdjustmentPercent + '\'' +
                        ",compound_name = '" + compoundName + '\'' +
                        ",small_preview_one = '" + smallPreviewOne + '\'' +
                        ",categories = '" + categories + '\'' +
                        ",large_preview_two = '" + largePreviewTwo + '\'' +
                        ",dimension = '" + dimension + '\'' +
                        ",property_dimension = '" + propertyDimension + '\'' +
                        ",property_use = '" + propertyUse + '\'' +
                        ",market_percentage = '" + marketPercentage + '\'' +
                        ",types = '" + types + '\'' +
                        ",property_gst = '" + propertyGst + '\'' +
                        ",assessment_length = '" + assessmentLength + '\'' +
                        ",large_preview_one = '" + largePreviewOne + '\'' +
                        ",length = '" + length + '\'' +
                        ",last_prStringed_at = '" + lastPrStringedAt + '\'' +
                        ",water_percentage = '" + waterPercentage + '\'' +
                        ",arrear_due = '" + arrearDue + '\'' +
                        ",council_group_name = '" + councilGroupName + '\'' +
                        ",roof_material_percentage = '" + roofMaterialPercentage + '\'' +
                        ",current_year_assessment_amount = '" + currentYearAssessmentAmount + '\'' +
                        ",easy_street_access_percentage = '" + easyStreetAccessPercentage + '\'' +
                        ",mill_rate = '" + millRate + '\'' +
                        ",no_of_shop = '" + noOfShop + '\'' +
                        ",small_preview_two = '" + smallPreviewTwo + '\'' +
                        ",swimming_id = '" + swimmingId + '\'' +
                        ",assessment_breadth = '" + assessmentBreadth + '\'' +
                        "}";
    }
}