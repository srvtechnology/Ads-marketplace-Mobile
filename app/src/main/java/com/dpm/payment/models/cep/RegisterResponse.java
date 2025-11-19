package com.dpm.payment.models.cep;

import com.google.gson.annotations.SerializedName;

public class RegisterResponse{

	@SerializedName("success")
	private RegisterData success;

	public RegisterData getSuccess(){
		return success;
	}
}