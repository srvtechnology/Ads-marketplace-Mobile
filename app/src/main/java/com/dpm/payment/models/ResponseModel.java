package com.dpm.payment.models;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class ResponseModel {

    @SerializedName("statusFalg")
    @Expose
    private String statusFalg;
    @SerializedName("statusMsg")
    @Expose
    private String statusMsg;
    @SerializedName("statusCode")
    @Expose
    private String statusCode;

    public String getStatusFalg() {
        return statusFalg;
    }

    public void setStatusFalg(String statusFalg) {
        this.statusFalg = statusFalg;
    }

    public String getStatusMsg() {
        return statusMsg;
    }

    public void setStatusMsg(String statusMsg) {
        this.statusMsg = statusMsg;
    }

    public String getStatusCode() {
        return statusCode;
    }

    public void setStatusCode(String statusCode) {
        this.statusCode = statusCode;
    }

}
