package com.dpm.payment.models.propertydetail;

import java.util.List;
import com.google.gson.annotations.SerializedName;

public class PropertyModelResponse{

	@SerializedName("paymentInQuarter")
	private List<Object> paymentInQuarter;

	@SerializedName("landlord")
	private Landlord landlord;

	@SerializedName("property")
	private List<PropertyItem> property;

	@SerializedName("history")
	private List<Object> history;



	@SerializedName("result")
	private List<AssesssmentData> assesssmentDataList;

	public void setPaymentInQuarter(List<Object> paymentInQuarter){
		this.paymentInQuarter = paymentInQuarter;
	}



	public List<Object> getPaymentInQuarter(){
		return paymentInQuarter;
	}

	public void setLandlord(Landlord landlord){
		this.landlord = landlord;
	}

	public Landlord getLandlord(){
		return landlord;
	}

	public void setProperty(List<PropertyItem> property){
		this.property = property;
	}

	public List<PropertyItem> getProperty(){
		return property;
	}

	public void setHistory(List<Object> history){
		this.history = history;
	}

	public List<Object> getHistory(){
		return history;
	}

	@Override
 	public String toString(){
		return 
			"PropertyModelResponse{" + 
			"paymentInQuarter = '" + paymentInQuarter + '\'' + 
			",landlord = '" + landlord + '\'' + 
			",property = '" + property + '\'' + 
			",history = '" + history + '\'' + 
			"}";
		}

	public List<AssesssmentData> getAssesssmentDataList() {
		return assesssmentDataList;
	}
}