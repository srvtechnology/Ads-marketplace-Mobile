package com.dpm.payment.activities.user;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class LandlordResponseModel {


    @SerializedName("token")
    private String token;

    @SerializedName("auth_type")
    private String auth_type;

    @SerializedName("expire_at")
    private String expire_at;

    @SerializedName("user")
    private LandlordUserModel user;

    @SerializedName("currency_rate")
    private CurrencyRateModel currency_rate;

    public CurrencyPoundRateModel getCurrency_rate_pound() {
        return currency_rate_pound;
    }

    public void setCurrency_rate_pound(CurrencyPoundRateModel currency_rate_pound) {
        this.currency_rate_pound = currency_rate_pound;
    }

    @SerializedName("currency_rate_pound")
    private CurrencyPoundRateModel currency_rate_pound;

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getAuth_type() {
        return auth_type;
    }

    public void setAuth_type(String auth_type) {
        this.auth_type = auth_type;
    }

    public String getExpire_at() {
        return expire_at;
    }

    public void setExpire_at(String expire_at) {
        this.expire_at = expire_at;
    }

    public LandlordUserModel getUser() {
        return user;
    }

    public void setUser(LandlordUserModel user) {
        this.user = user;
    }

    public CurrencyRateModel getCurrency_rate() {
        return currency_rate;
    }

    public void setCurrency_rate(CurrencyRateModel currency_rate) {
        this.currency_rate = currency_rate;
    }


    @Override
    public String toString() {
        return "LandlordResponseModel{" +
                "token='" + token + '\'' +
                ", auth_type='" + auth_type + '\'' +
                ", expire_at='" + expire_at + '\'' +
                ", user=" + user +
                ", currency_rate=" + currency_rate +
                '}';
    }
}
