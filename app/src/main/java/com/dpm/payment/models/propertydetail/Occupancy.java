package com.dpm.payment.models.propertydetail;

import com.google.gson.annotations.SerializedName;

public class Occupancy{

	@SerializedName("updated_at")
	private String updatedAt;

	@SerializedName("ownerTenantTitle_id")
	private Object ownerTenantTitleId;

	@SerializedName("surname")
	private String surname;

	@SerializedName("tenant_first_name")
	private String tenantFirstName;

	@SerializedName("created_at")
	private String createdAt;

	@SerializedName("id")
	private int id;

	@SerializedName("middle_name")
	private Object middleName;

	@SerializedName("mobile_1")
	private String mobile1;

	@SerializedName("type")
	private Object type;

	@SerializedName("ownerTenantTitle")
	private Object ownerTenantTitle;

	@SerializedName("mobile_2")
	private String mobile2;

	@SerializedName("property_id")
	private int propertyId;

	public void setUpdatedAt(String updatedAt){
		this.updatedAt = updatedAt;
	}

	public String getUpdatedAt(){
		return updatedAt;
	}

	public void setOwnerTenantTitleId(Object ownerTenantTitleId){
		this.ownerTenantTitleId = ownerTenantTitleId;
	}

	public Object getOwnerTenantTitleId(){
		return ownerTenantTitleId;
	}

	public void setSurname(String surname){
		this.surname = surname;
	}

	public String getSurname(){
		return surname;
	}

	public void setTenantFirstName(String tenantFirstName){
		this.tenantFirstName = tenantFirstName;
	}

	public String getTenantFirstName(){
		return tenantFirstName;
	}

	public void setCreatedAt(String createdAt){
		this.createdAt = createdAt;
	}

	public String getCreatedAt(){
		return createdAt;
	}

	public void setId(int id){
		this.id = id;
	}

	public int getId(){
		return id;
	}

	public void setMiddleName(Object middleName){
		this.middleName = middleName;
	}

	public Object getMiddleName(){
		return middleName;
	}

	public void setMobile1(String mobile1){
		this.mobile1 = mobile1;
	}

	public String getMobile1(){
		return mobile1;
	}

	public void setType(Object type){
		this.type = type;
	}

	public Object getType(){
		return type;
	}

	public void setOwnerTenantTitle(Object ownerTenantTitle){
		this.ownerTenantTitle = ownerTenantTitle;
	}

	public Object getOwnerTenantTitle(){
		return ownerTenantTitle;
	}

	public void setMobile2(String mobile2){
		this.mobile2 = mobile2;
	}

	public String getMobile2(){
		return mobile2;
	}

	public void setPropertyId(int propertyId){
		this.propertyId = propertyId;
	}

	public int getPropertyId(){
		return propertyId;
	}

	@Override
 	public String toString(){
		return 
			"Occupancy{" + 
			"updated_at = '" + updatedAt + '\'' + 
			",ownerTenantTitle_id = '" + ownerTenantTitleId + '\'' + 
			",surname = '" + surname + '\'' + 
			",tenant_first_name = '" + tenantFirstName + '\'' + 
			",created_at = '" + createdAt + '\'' + 
			",id = '" + id + '\'' + 
			",middle_name = '" + middleName + '\'' + 
			",mobile_1 = '" + mobile1 + '\'' + 
			",type = '" + type + '\'' + 
			",ownerTenantTitle = '" + ownerTenantTitle + '\'' + 
			",mobile_2 = '" + mobile2 + '\'' + 
			",property_id = '" + propertyId + '\'' + 
			"}";
		}
}