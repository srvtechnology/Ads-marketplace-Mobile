package com.dpm.payment.models.LandloradPenDisImage;

public class LandlordPenDIsImage {

    public String id;
    public String pensioner_discount_image_path;
    public String disability_discount_image_path;

    public LandlordPenDIsImage(String id, String pensioner_discount_image_path, String disability_discount_image_path) {
        this.id = id;
        this.pensioner_discount_image_path = pensioner_discount_image_path;
        this.disability_discount_image_path = disability_discount_image_path;
    }

    public String getId() {
        return id;
    }

    public String getPensioner_discount_image_path() {
        return pensioner_discount_image_path;
    }

    public String getDisability_discount_image_path() {
        return disability_discount_image_path;
    }
}
