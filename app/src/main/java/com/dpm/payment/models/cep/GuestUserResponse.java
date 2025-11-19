package com.dpm.payment.models.cep;

import com.google.gson.annotations.SerializedName;

public class GuestUserResponse{

	@SerializedName("auth_type")
	private String authType;

	@SerializedName("expired_at")
	private String expiredAt;

	@SerializedName("user")
	private GuestUser user;

	@SerializedName("token")
	private String token;

	public String getAuthType(){
		return authType;
	}

	public String getExpiredAt(){
		return expiredAt;
	}

	public GuestUser getUser(){
		return user;
	}

	public String getToken(){
		return token;
	}
}