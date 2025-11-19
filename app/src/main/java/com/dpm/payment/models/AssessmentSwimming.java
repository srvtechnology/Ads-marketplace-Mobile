package com.dpm.payment.models;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class AssessmentSwimming {

   // {"swimming":{"id":1,
    // "label":"Residential",
    // "value":280000,
    // "is_active":1,
    // "created_at":"2019-09-05 15:52:31",
    // "updated_at":"2019-09-05 15:52:31"}}

    @SerializedName("id")
    @Expose
    private Integer id;

    @SerializedName("label")
    @Expose
    private String label;

    @SerializedName("value")
    @Expose
    private String value;
    @SerializedName("is_active")
    @Expose
    private String is_active;
    @SerializedName("created_at")
    @Expose
    private String created_at;
    @SerializedName("updated_at")
    @Expose
    private String updated_at;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String getIs_active() {
        return is_active;
    }

    public void setIs_active(String is_active) {
        this.is_active = is_active;
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
}
