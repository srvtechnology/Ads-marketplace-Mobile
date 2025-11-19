package com.dpm.payment.models.cep;

import com.google.gson.annotations.SerializedName;

public class RegisterData{

	@SerializedName("phone")
	private String phone;

	@SerializedName("name")
	private String name;

	@SerializedName("email")
	private String email;

	public String getPhone(){
		return phone;
	}

	public String getName(){
		return name;
	}

	public String getEmail(){
		return email;
	}
}