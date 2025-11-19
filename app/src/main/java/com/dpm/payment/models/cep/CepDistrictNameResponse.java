package com.dpm.payment.models.cep;

import java.util.List;
import com.google.gson.annotations.SerializedName;

public class CepDistrictNameResponse{

	@SerializedName("result")
	private List<DistrictItem> result;

	@SerializedName("code")
	private int code;

	@SerializedName("success")
	private boolean success;

	public List<DistrictItem> getResult(){
		return result;
	}

	public int getCode(){
		return code;
	}

	public boolean isSuccess(){
		return success;
	}
}