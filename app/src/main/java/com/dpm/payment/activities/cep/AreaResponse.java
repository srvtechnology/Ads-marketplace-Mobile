package com.dpm.payment.activities.cep;

import java.util.List;
import com.google.gson.annotations.SerializedName;

public class AreaResponse{

	@SerializedName("result")
	private List<String> result;

	public List<String> getResult(){
		return result;
	}
}