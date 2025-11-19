package com.dpm.payment.activities.user;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class CurrencyRateModel {

    @SerializedName("usd")
    @Expose
    private String usd;

    @SerializedName("le")
    @Expose
    private String le;
    public String getUsd() {
        return usd;
    }

    public void setUsd(String usd) {
        this.usd = usd;
    }

    public String getLe() {
        return le;
    }

    public void setLe(String le) {
        this.le = le;
    }





}
