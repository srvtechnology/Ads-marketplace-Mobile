package com.dpm.payment.models.propertydetail;

import com.google.gson.annotations.SerializedName;

public class RegistryMetersItem{

	@SerializedName("number")
	private String number;

	@SerializedName("image")
	private Object image;

	@SerializedName("original")
	private String original;

	@SerializedName("updated_at")
	private String updatedAt;

	@SerializedName("large_preview")
	private String largePreview;

	@SerializedName("created_at")
	private String createdAt;

	@SerializedName("small_preview")
	private String smallPreview;

	@SerializedName("id")
	private int id;

	@SerializedName("property_id")
	private int propertyId;

	public void setNumber(String number){
		this.number = number;
	}

	public String getNumber(){
		return number;
	}

	public void setImage(Object image){
		this.image = image;
	}

	public Object getImage(){
		return image;
	}

	public void setOriginal(String original){
		this.original = original;
	}

	public String getOriginal(){
		return original;
	}

	public void setUpdatedAt(String updatedAt){
		this.updatedAt = updatedAt;
	}

	public String getUpdatedAt(){
		return updatedAt;
	}

	public void setLargePreview(String largePreview){
		this.largePreview = largePreview;
	}

	public String getLargePreview(){
		return largePreview;
	}

	public void setCreatedAt(String createdAt){
		this.createdAt = createdAt;
	}

	public String getCreatedAt(){
		return createdAt;
	}

	public void setSmallPreview(String smallPreview){
		this.smallPreview = smallPreview;
	}

	public String getSmallPreview(){
		return smallPreview;
	}

	public void setId(int id){
		this.id = id;
	}

	public int getId(){
		return id;
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
			"RegistryMetersItem{" + 
			"number = '" + number + '\'' + 
			",image = '" + image + '\'' + 
			",original = '" + original + '\'' + 
			",updated_at = '" + updatedAt + '\'' + 
			",large_preview = '" + largePreview + '\'' + 
			",created_at = '" + createdAt + '\'' + 
			",small_preview = '" + smallPreview + '\'' + 
			",id = '" + id + '\'' + 
			",property_id = '" + propertyId + '\'' + 
			"}";
		}
}