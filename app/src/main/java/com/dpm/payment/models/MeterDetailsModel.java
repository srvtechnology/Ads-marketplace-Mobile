package com.dpm.payment.models;

import com.google.gson.annotations.SerializedName;

public class MeterDetailsModel {


    @SerializedName("id")
    private String id;
    @SerializedName("property_id")
    private String property_id;
    @SerializedName("number")
    private String number;
    @SerializedName("image")
    private String image;
    @SerializedName("created_at")
    private String created_at;
    @SerializedName("updated_at")
    private String updated_at;
    @SerializedName("original")
    private String original;
    @SerializedName("small_preview")
    private String small_preview;
    @SerializedName("large_preview")
    private String large_preview;
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getProperty_id() {
        return property_id;
    }

    public void setProperty_id(String property_id) {
        this.property_id = property_id;
    }

    public String getNumber() {
        return number;
    }

    public void setNumber(String number) {
        this.number = number;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
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

    public String getOriginal() {
        return original;
    }

    public void setOriginal(String original) {
        this.original = original;
    }

    public String getSmall_preview() {
        return small_preview;
    }

    public void setSmall_preview(String small_preview) {
        this.small_preview = small_preview;
    }

    public String getLarge_preview() {
        return large_preview;
    }

    public void setLarge_preview(String large_preview) {
        this.large_preview = large_preview;
    }


    @Override
    public String toString() {
        return "{" +
                "id='" + id + '\'' +
                ", property_id='" + property_id + '\'' +
                ", number='" + number + '\'' +
                ", image='" + image + '\'' +
                ", created_at='" + created_at + '\'' +
                ", updated_at='" + updated_at + '\'' +
                ", original='" + original + '\'' +
                ", small_preview='" + small_preview + '\'' +
                ", large_preview='" + large_preview + '\'' +
                '}';
    }
}
