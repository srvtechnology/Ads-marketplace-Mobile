package com.dpm.payment.models;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class LoginModel {


    @SerializedName("success")
    @Expose
    private Boolean success;


    @SerializedName("code")
    @Expose
    private Integer code;

    @SerializedName("token")
    @Expose
    private String token;

    @SerializedName("auth_type")
    @Expose
    private String authType;

    @SerializedName("expired_at")
    @Expose
    private String expiredAt;

    @SerializedName("user")
    @Expose
    private UserProfileModel user;

    public Boolean getSuccess() {
        return success;
    }

    public void setSuccess(Boolean success) {
        this.success = success;
    }

    public Integer getCode() {
        return code;
    }

    public void setCode(Integer code) {
        this.code = code;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getAuthType() {
        return authType;
    }

    public void setAuthType(String authType) {
        this.authType = authType;
    }

    public String getExpiredAt() {
        return expiredAt;
    }

    public void setExpiredAt(String expiredAt) {
        this.expiredAt = expiredAt;
    }

    public UserProfileModel getUser() {
        return user;
    }

    public void setUser(UserProfileModel user) {
        this.user = user;
    }
}
