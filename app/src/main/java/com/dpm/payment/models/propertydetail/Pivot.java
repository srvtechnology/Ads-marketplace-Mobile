package com.dpm.payment.models.propertydetail;

import com.google.gson.annotations.SerializedName;

public class Pivot{

	@SerializedName("property_category_id")
	private int propertyCategoryId;

	@SerializedName("assessment_id")
	private int assessmentId;

	@SerializedName("property_id")
	private int propertyId;

	public void setPropertyCategoryId(int propertyCategoryId){
		this.propertyCategoryId = propertyCategoryId;
	}

	public int getPropertyCategoryId(){
		return propertyCategoryId;
	}

	public void setAssessmentId(int assessmentId){
		this.assessmentId = assessmentId;
	}

	public int getAssessmentId(){
		return assessmentId;
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
			"Pivot{" + 
			"property_category_id = '" + propertyCategoryId + '\'' + 
			",assessment_id = '" + assessmentId + '\'' + 
			",property_id = '" + propertyId + '\'' + 
			"}";
		}
}