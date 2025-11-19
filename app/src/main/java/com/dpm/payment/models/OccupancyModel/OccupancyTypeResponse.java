package com.dpm.payment.models.OccupancyModel;

import com.google.gson.annotations.SerializedName;

public class OccupancyTypeResponse{

	@SerializedName("code")
	private int code;

	@SerializedName("success")
	private boolean success;

	@SerializedName("datas")
	private Datas datas;

	public int getCode(){
		return code;
	}

	public boolean isSuccess(){
		return success;
	}

	public Datas getDatas(){
		return datas;
	}
}