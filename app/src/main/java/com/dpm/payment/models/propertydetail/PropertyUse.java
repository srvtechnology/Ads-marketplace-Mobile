package com.dpm.payment.models.propertydetail;

import com.google.gson.annotations.SerializedName;

public class PropertyUse{

	@SerializedName("is_active")
	private String isActive;

	@SerializedName("updated_at")
	private String updatedAt;

	@SerializedName("created_at")
	private String createdAt;

	@SerializedName("id")
	private String id;

	@SerializedName("label")
	private String label;

	@SerializedName("value")
	private String value;

	public void setIsActive(String isActive){
		this.isActive = isActive;
	}

	public String getIsActive(){
		return isActive;
	}

	public void setUpdatedAt(String updatedAt){
		this.updatedAt = updatedAt;
	}

	public String getUpdatedAt(){
		return updatedAt;
	}

	public void setCreatedAt(String createdAt){
		this.createdAt = createdAt;
	}

	public String getCreatedAt(){
		return createdAt;
	}

	public void setId(String id){
		this.id = id;
	}

	public String getId(){
		return id;
	}

	public void setLabel(String label){
		this.label = label;
	}

	public String getLabel(){
		return label;
	}

	public void setValue(String value){
		this.value = value;
	}

	public String getValue(){
		return value;
	}

	@Override
 	public String toString(){
		return 
			"PropertyUse{" + 
			"is_active = '" + isActive + '\'' + 
			",updated_at = '" + updatedAt + '\'' + 
			",created_at = '" + createdAt + '\'' + 
			",id = '" + id + '\'' + 
			",label = '" + label + '\'' + 
			",value = '" + value + '\'' + 
			"}";
		}
}