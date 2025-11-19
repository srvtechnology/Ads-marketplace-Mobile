package com.dpm.payment.models.propertydetail;

import com.google.gson.annotations.SerializedName;

public class WindowType{

	@SerializedName("is_active")
	private int isActive;

	@SerializedName("updated_at")
	private String updatedAt;

	@SerializedName("average_precent")
	private int averagePrecent;

	@SerializedName("bad_percent")
	private double badPercent;

	@SerializedName("created_at")
	private String createdAt;

	@SerializedName("id")
	private int id;

	@SerializedName("label")
	private String label;

	@SerializedName("bad_value")
	private int badValue;

	@SerializedName("good_value")
	private int goodValue;

	@SerializedName("good_percent")
	private double goodPercent;

	@SerializedName("value")
	private int value;

	public void setIsActive(int isActive){
		this.isActive = isActive;
	}

	public int getIsActive(){
		return isActive;
	}

	public void setUpdatedAt(String updatedAt){
		this.updatedAt = updatedAt;
	}

	public String getUpdatedAt(){
		return updatedAt;
	}

	public void setAveragePrecent(int averagePrecent){
		this.averagePrecent = averagePrecent;
	}

	public int getAveragePrecent(){
		return averagePrecent;
	}

	public void setBadPercent(double badPercent){
		this.badPercent = badPercent;
	}

	public double getBadPercent(){
		return badPercent;
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

	public void setLabel(String label){
		this.label = label;
	}

	public String getLabel(){
		return label;
	}

	public void setBadValue(int badValue){
		this.badValue = badValue;
	}

	public int getBadValue(){
		return badValue;
	}

	public void setGoodValue(int goodValue){
		this.goodValue = goodValue;
	}

	public int getGoodValue(){
		return goodValue;
	}

	public void setGoodPercent(double goodPercent){
		this.goodPercent = goodPercent;
	}

	public double getGoodPercent(){
		return goodPercent;
	}

	public void setValue(int value){
		this.value = value;
	}

	public int getValue(){
		return value;
	}

	@Override
 	public String toString(){
		return 
			"WindowType{" + 
			"is_active = '" + isActive + '\'' + 
			",updated_at = '" + updatedAt + '\'' + 
			",average_precent = '" + averagePrecent + '\'' + 
			",bad_percent = '" + badPercent + '\'' + 
			",created_at = '" + createdAt + '\'' + 
			",id = '" + id + '\'' + 
			",label = '" + label + '\'' + 
			",bad_value = '" + badValue + '\'' + 
			",good_value = '" + goodValue + '\'' + 
			",good_percent = '" + goodPercent + '\'' + 
			",value = '" + value + '\'' + 
			"}";
		}
}