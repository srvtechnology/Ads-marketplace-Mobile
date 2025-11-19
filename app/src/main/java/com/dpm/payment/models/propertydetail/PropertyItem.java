package com.dpm.payment.models.propertydetail;

import java.util.List;
import com.google.gson.annotations.SerializedName;

public class PropertyItem{

	@SerializedName("street_numbernew")
	private Object streetNumbernew;

	@SerializedName("landlord")
	private Landlord landlord;

	@SerializedName("occupancy")
	private Occupancy occupancy;

	@SerializedName("occupancies")
	private List<OccupanciesItem> occupancies;

	@SerializedName("payments")
	private List<PaymentsItem> payments;

	@SerializedName("delivered_image_path")
	private String deliveredImagePath;

	@SerializedName("created_at")
	private String createdAt;

	@SerializedName("section")
	private String section;

	@SerializedName("ward")
	private int ward;

	@SerializedName("is_completed")
	private boolean isCompleted;

	@SerializedName("is_draft_delivered")
	private int isDraftDelivered;

	@SerializedName("delivered_number")
	private String deliveredNumber;

	@SerializedName("street_name")
	private String streetName;

	@SerializedName("organization_tin")
	private Object organizationTin;

	@SerializedName("assessment")
	private Assessment assessment;

	@SerializedName("organization_addresss")
	private Object organizationAddresss;

	@SerializedName("province")
	private String province;

	@SerializedName("updated_at")
	private String updatedAt;

	@SerializedName("chiefdom")
	private String chiefdom;

	@SerializedName("assessment_area")
	private Object assessmentArea;

	@SerializedName("id")
	private int id;

	@SerializedName("is_property_inaccessible")
	private boolean isPropertyInaccessible;

	@SerializedName("payment_migrate_from")
	private Object paymentMigrateFrom;

	@SerializedName("is_admin_created")
	private int isAdminCreated;

	@SerializedName("geo_registry")
	private GeoRegistry geoRegistry;

	@SerializedName("registry_meters")
	private List<RegistryMetersItem> registryMeters;

	@SerializedName("postcode")
	private String postcode;

	@SerializedName("organization_name")
	private Object organizationName;

	@SerializedName("is_organization")
	private boolean isOrganization;

	@SerializedName("deleted_at")
	private Object deletedAt;

	@SerializedName("delivered_image")
	private String deliveredImage;

	@SerializedName("constituency")
	private String constituency;

	@SerializedName("user_id")
	private int userId;

	@SerializedName("district")
	private String district;

	@SerializedName("street_number")
	private String streetNumber;

	@SerializedName("organization_type")
	private Object organizationType;

	@SerializedName("random_id")
	private String randomId;

	@SerializedName("delivered_name")
	private String deliveredName;

	@SerializedName("created_from")
	private Object createdFrom;

	@SerializedName("assessment_history")
	private List<AssessmentHistoryItem> assessmentHistory;

	public void setStreetNumbernew(Object streetNumbernew){
		this.streetNumbernew = streetNumbernew;
	}

	public Object getStreetNumbernew(){
		return streetNumbernew;
	}

	public void setLandlord(Landlord landlord){
		this.landlord = landlord;
	}

	public Landlord getLandlord(){
		return landlord;
	}

	public void setOccupancy(Occupancy occupancy){
		this.occupancy = occupancy;
	}

	public Occupancy getOccupancy(){
		return occupancy;
	}

	public void setOccupancies(List<OccupanciesItem> occupancies){
		this.occupancies = occupancies;
	}

	public List<OccupanciesItem> getOccupancies(){
		return occupancies;
	}

	public void setPayments(List<PaymentsItem> payments){
		this.payments = payments;
	}

	public List<PaymentsItem> getPayments(){
		return payments;
	}

	public void setDeliveredImagePath(String deliveredImagePath){
		this.deliveredImagePath = deliveredImagePath;
	}

	public String getDeliveredImagePath(){
		return deliveredImagePath;
	}

	public void setCreatedAt(String createdAt){
		this.createdAt = createdAt;
	}

	public String getCreatedAt(){
		return createdAt;
	}

	public void setSection(String section){
		this.section = section;
	}

	public String getSection(){
		return section;
	}

	public void setWard(int ward){
		this.ward = ward;
	}

	public int getWard(){
		return ward;
	}

	public void setIsCompleted(boolean isCompleted){
		this.isCompleted = isCompleted;
	}

	public boolean isIsCompleted(){
		return isCompleted;
	}

	public void setIsDraftDelivered(int isDraftDelivered){
		this.isDraftDelivered = isDraftDelivered;
	}

	public int getIsDraftDelivered(){
		return isDraftDelivered;
	}

	public void setDeliveredNumber(String deliveredNumber){
		this.deliveredNumber = deliveredNumber;
	}

	public String getDeliveredNumber(){
		return deliveredNumber;
	}

	public void setStreetName(String streetName){
		this.streetName = streetName;
	}

	public String getStreetName(){
		return streetName;
	}

	public void setOrganizationTin(Object organizationTin){
		this.organizationTin = organizationTin;
	}

	public Object getOrganizationTin(){
		return organizationTin;
	}

	public void setAssessment(Assessment assessment){
		this.assessment = assessment;
	}

	public Assessment getAssessment(){
		return assessment;
	}

	public void setOrganizationAddresss(Object organizationAddresss){
		this.organizationAddresss = organizationAddresss;
	}

	public Object getOrganizationAddresss(){
		return organizationAddresss;
	}

	public void setProvince(String province){
		this.province = province;
	}

	public String getProvince(){
		return province;
	}

	public void setUpdatedAt(String updatedAt){
		this.updatedAt = updatedAt;
	}

	public String getUpdatedAt(){
		return updatedAt;
	}

	public void setChiefdom(String chiefdom){
		this.chiefdom = chiefdom;
	}

	public String getChiefdom(){
		return chiefdom;
	}

	public void setAssessmentArea(Object assessmentArea){
		this.assessmentArea = assessmentArea;
	}

	public Object getAssessmentArea(){
		return assessmentArea;
	}

	public void setId(int id){
		this.id = id;
	}

	public int getId(){
		return id;
	}

	public void setIsPropertyInaccessible(boolean isPropertyInaccessible){
		this.isPropertyInaccessible = isPropertyInaccessible;
	}

	public boolean isIsPropertyInaccessible(){
		return isPropertyInaccessible;
	}

	public void setPaymentMigrateFrom(Object paymentMigrateFrom){
		this.paymentMigrateFrom = paymentMigrateFrom;
	}

	public Object getPaymentMigrateFrom(){
		return paymentMigrateFrom;
	}

	public void setIsAdminCreated(int isAdminCreated){
		this.isAdminCreated = isAdminCreated;
	}

	public int getIsAdminCreated(){
		return isAdminCreated;
	}

	public void setGeoRegistry(GeoRegistry geoRegistry){
		this.geoRegistry = geoRegistry;
	}

	public GeoRegistry getGeoRegistry(){
		return geoRegistry;
	}

	public void setRegistryMeters(List<RegistryMetersItem> registryMeters){
		this.registryMeters = registryMeters;
	}

	public List<RegistryMetersItem> getRegistryMeters(){
		return registryMeters;
	}

	public void setPostcode(String postcode){
		this.postcode = postcode;
	}

	public String getPostcode(){
		return postcode;
	}

	public void setOrganizationName(Object organizationName){
		this.organizationName = organizationName;
	}

	public Object getOrganizationName(){
		return organizationName;
	}

	public void setIsOrganization(boolean isOrganization){
		this.isOrganization = isOrganization;
	}

	public boolean isIsOrganization(){
		return isOrganization;
	}

	public void setDeletedAt(Object deletedAt){
		this.deletedAt = deletedAt;
	}

	public Object getDeletedAt(){
		return deletedAt;
	}

	public void setDeliveredImage(String deliveredImage){
		this.deliveredImage = deliveredImage;
	}

	public String getDeliveredImage(){
		return deliveredImage;
	}

	public void setConstituency(String constituency){
		this.constituency = constituency;
	}

	public String getConstituency(){
		return constituency;
	}

	public void setUserId(int userId){
		this.userId = userId;
	}

	public int getUserId(){
		return userId;
	}

	public void setDistrict(String district){
		this.district = district;
	}

	public String getDistrict(){
		return district;
	}

	public void setStreetNumber(String streetNumber){
		this.streetNumber = streetNumber;
	}

	public String getStreetNumber(){
		return streetNumber;
	}

	public void setOrganizationType(Object organizationType){
		this.organizationType = organizationType;
	}

	public Object getOrganizationType(){
		return organizationType;
	}

	public void setRandomId(String randomId){
		this.randomId = randomId;
	}

	public String getRandomId(){
		return randomId;
	}

	public void setDeliveredName(String deliveredName){
		this.deliveredName = deliveredName;
	}

	public String getDeliveredName(){
		return deliveredName;
	}

	public void setCreatedFrom(Object createdFrom){
		this.createdFrom = createdFrom;
	}

	public Object getCreatedFrom(){
		return createdFrom;
	}

	public void setAssessmentHistory(List<AssessmentHistoryItem> assessmentHistory){
		this.assessmentHistory = assessmentHistory;
	}

	public List<AssessmentHistoryItem> getAssessmentHistory(){
		return assessmentHistory;
	}

	@Override
 	public String toString(){
		return 
			"PropertyItem{" + 
			"street_numbernew = '" + streetNumbernew + '\'' + 
			",landlord = '" + landlord + '\'' + 
			",occupancy = '" + occupancy + '\'' + 
			",occupancies = '" + occupancies + '\'' + 
			",payments = '" + payments + '\'' + 
			",delivered_image_path = '" + deliveredImagePath + '\'' + 
			",created_at = '" + createdAt + '\'' + 
			",section = '" + section + '\'' + 
			",ward = '" + ward + '\'' + 
			",is_completed = '" + isCompleted + '\'' + 
			",is_draft_delivered = '" + isDraftDelivered + '\'' + 
			",delivered_number = '" + deliveredNumber + '\'' + 
			",street_name = '" + streetName + '\'' + 
			",organization_tin = '" + organizationTin + '\'' + 
			",assessment = '" + assessment + '\'' + 
			",organization_addresss = '" + organizationAddresss + '\'' + 
			",province = '" + province + '\'' + 
			",updated_at = '" + updatedAt + '\'' + 
			",chiefdom = '" + chiefdom + '\'' + 
			",assessment_area = '" + assessmentArea + '\'' + 
			",id = '" + id + '\'' + 
			",is_property_inaccessible = '" + isPropertyInaccessible + '\'' + 
			",payment_migrate_from = '" + paymentMigrateFrom + '\'' + 
			",is_admin_created = '" + isAdminCreated + '\'' + 
			",geo_registry = '" + geoRegistry + '\'' + 
			",registry_meters = '" + registryMeters + '\'' + 
			",postcode = '" + postcode + '\'' + 
			",organization_name = '" + organizationName + '\'' + 
			",is_organization = '" + isOrganization + '\'' + 
			",deleted_at = '" + deletedAt + '\'' + 
			",delivered_image = '" + deliveredImage + '\'' + 
			",constituency = '" + constituency + '\'' + 
			",user_id = '" + userId + '\'' + 
			",district = '" + district + '\'' + 
			",street_number = '" + streetNumber + '\'' + 
			",organization_type = '" + organizationType + '\'' + 
			",random_id = '" + randomId + '\'' + 
			",delivered_name = '" + deliveredName + '\'' + 
			",created_from = '" + createdFrom + '\'' + 
			",assessment_history = '" + assessmentHistory + '\'' + 
			"}";
		}
}