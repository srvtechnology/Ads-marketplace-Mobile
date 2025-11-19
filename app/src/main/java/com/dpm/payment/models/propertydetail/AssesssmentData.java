package com.dpm.payment.models.propertydetail;

import com.google.gson.annotations.SerializedName;

public class AssesssmentData{

	@SerializedName("amount_paid")
	private int amountPaid;

	@SerializedName("arrear")
	private Object arrear;

	@SerializedName("due")
	private Object due;

	@SerializedName("penalty")
	private int penalty;

	@SerializedName("assessment_year")
	private int assessmentYear;

	@SerializedName("assessment_amount")
	private Object assessmentAmount;

	public int getAmountPaid(){
		return amountPaid;
	}

	public Object getArrear(){
		return arrear;
	}

	public Object getDue(){
		return due;
	}

	public int getPenalty(){
		return penalty;
	}

	public int getAssessmentYear(){
		return assessmentYear;
	}

	public Object getAssessmentAmount(){
		return assessmentAmount;
	}
}