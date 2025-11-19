package com.dpm.payment.models.OccupancyModel;

import com.google.gson.annotations.SerializedName;

public class TitlesItem{

	@SerializedName("is_active")
	private int isActive;

	@SerializedName("updated_at")
	private String updatedAt;

	@SerializedName("created_at")
	private String createdAt;

	@SerializedName("id")
	private int id;

	@SerializedName("label")
	private String label;

	public int getIsActive(){
		return isActive;
	}

	public String getUpdatedAt(){
		return updatedAt;
	}

	public String getCreatedAt(){
		return createdAt;
	}

	public int getId(){
		return id;
	}

	public String getLabel(){
		return label;
	}
}