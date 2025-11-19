package com.dpm.payment.activities.user;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class LandlordUserModel {

    @SerializedName("id")
    @Expose
    private String id;

    @SerializedName("mobile")
    @Expose
    private String mobile;

    @SerializedName("code")
    @Expose
    private String code;

    @SerializedName("expired_at")
    @Expose
    private String expired_at;

    @SerializedName("created_at")
    @Expose
    private String created_at;

    @SerializedName("updated_at")
    @Expose
    private String updated_at;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getMobile() {
        return mobile;
    }

    public void setMobile(String mobile) {
        this.mobile = mobile;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getExpired_at() {
        return expired_at;
    }

    public void setExpired_at(String expired_at) {
        this.expired_at = expired_at;
    }

    public String getCreated_at() {
        return created_at;
    }

    public void setCreated_at(String created_at) {
        this.created_at = created_at;
    }

    public String getUpdated_at() {
        return updated_at;
    }

    public void setUpdated_at(String updated_at) {
        this.updated_at = updated_at;
    }

    @Override
    public String toString() {
        return "LandlordUserModel{" +
                "id='" + id + '\'' +
                ", mobile='" + mobile + '\'' +
                ", code='" + code + '\'' +
                ", expired_at='" + expired_at + '\'' +
                ", created_at='" + created_at + '\'' +
                ", updated_at='" + updated_at + '\'' +
                '}';
    }



  /*  "id": 1,
            "mobile": "+919982653053",
            "code": 9241,
            "is_active": 1,
            "expired_at": "2020-07-21 16:22:42",
            "created_at": "2020-07-19 11:34:45",
            "updated_at": "2020-07-21 16:07:42"*/
}
