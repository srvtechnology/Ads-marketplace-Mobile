package com.dpm.payment.activities.user;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class CurrencyPoundRateModel {

    public String getPound() {
        return pound;
    }

    public void setPound(String pound) {
        this.pound = pound;
    }

    @SerializedName("pound")
    @Expose
    private String pound;

    @SerializedName("le")
    @Expose
    private String le;

    public String getLe() {
        return le;
    }
    public void setLe(String le) {
        this.le = le;
    }





}
