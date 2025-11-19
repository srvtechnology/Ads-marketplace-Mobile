package com.dpm.payment.models.propertydetail;

import com.google.gson.annotations.SerializedName;

public class OccupanciesItem{

	@SerializedName("updated_at")
	private String updatedAt;

	@SerializedName("created_at")
	private String createdAt;

	@SerializedName("id")
	private int id;

	@SerializedName("property_id")
	private int propertyId;

	@SerializedName("occupancy_type")
	private String occupancyType;

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

	public void setOccupancyType(String occupancyType){
		this.occupancyType = occupancyType;
	}

	public String getOccupancyType(){
		return occupancyType;
	}

	@Override
 	public String toString(){
		return 
			"OccupanciesItem{" + 
			"updated_at = '" + updatedAt + '\'' + 
			",created_at = '" + createdAt + '\'' + 
			",id = '" + id + '\'' + 
			",property_id = '" + propertyId + '\'' + 
			",occupancy_type = '" + occupancyType + '\'' + 
			"}";
		}
}