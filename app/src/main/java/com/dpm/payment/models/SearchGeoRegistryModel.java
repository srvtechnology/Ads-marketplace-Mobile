package com.dpm.payment.models;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class SearchGeoRegistryModel {


    @SerializedName("id")
    @Expose
    private Integer id;
    @SerializedName("property_id")
    @Expose
    private Integer propertyId;
    @SerializedName("meter_number")
    @Expose
    private Object meterNumber;
    @SerializedName("meter_images")
    @Expose
    private Object meterImages;
    @SerializedName("point1")
    @Expose
    private String point1;
    @SerializedName("point2")
    @Expose
    private String point2;
    @SerializedName("point3")
    @Expose
    private String point3;
    @SerializedName("point4")
    @Expose
    private String point4;
    @SerializedName("point5")
    @Expose
    private Object point5;
    @SerializedName("point6")
    @Expose
    private Object point6;
    @SerializedName("point7")
    @Expose
    private Object point7;
    @SerializedName("point8")
    @Expose
    private Object point8;
    @SerializedName("digital_address")
    @Expose
    private String digitalAddress;
    @SerializedName("open_location_code")
    @Expose
    private String openLocationCode;
    @SerializedName("old_digital_address")
    @Expose
    private String oldDigitalAddress;
    @SerializedName("dor_lat_long")
    @Expose
    private String dorLatLong;
    @SerializedName("created_at")
    @Expose
    private String createdAt;
    @SerializedName("updated_at")
    @Expose
    private String updatedAt;
    @SerializedName("small_preview")
    @Expose
    private Object smallPreview;
    @SerializedName("large_preview")
    @Expose
    private Object largePreview;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getPropertyId() {
        return propertyId;
    }

    public void setPropertyId(Integer propertyId) {
        this.propertyId = propertyId;
    }

    public Object getMeterNumber() {
        return meterNumber;
    }

    public void setMeterNumber(Object meterNumber) {
        this.meterNumber = meterNumber;
    }

    public Object getMeterImages() {
        return meterImages;
    }

    public void setMeterImages(Object meterImages) {
        this.meterImages = meterImages;
    }

    public String getPoint1() {
        return point1;
    }

    public void setPoint1(String point1) {
        this.point1 = point1;
    }

    public String getPoint2() {
        return point2;
    }

    public void setPoint2(String point2) {
        this.point2 = point2;
    }

    public String getPoint3() {
        return point3;
    }

    public void setPoint3(String point3) {
        this.point3 = point3;
    }

    public String getPoint4() {
        return point4;
    }

    public void setPoint4(String point4) {
        this.point4 = point4;
    }

    public Object getPoint5() {
        return point5;
    }

    public void setPoint5(Object point5) {
        this.point5 = point5;
    }

    public Object getPoint6() {
        return point6;
    }

    public void setPoint6(Object point6) {
        this.point6 = point6;
    }

    public Object getPoint7() {
        return point7;
    }

    public void setPoint7(Object point7) {
        this.point7 = point7;
    }

    public Object getPoint8() {
        return point8;
    }

    public void setPoint8(Object point8) {
        this.point8 = point8;
    }

    public String getDigitalAddress() {
        return digitalAddress;
    }

    public void setDigitalAddress(String digitalAddress) {
        this.digitalAddress = digitalAddress;
    }

    public String getOpenLocationCode() {
        return openLocationCode;
    }

    public void setOpenLocationCode(String openLocationCode) {
        this.openLocationCode = openLocationCode;
    }

    public String getOldDigitalAddress() {
        return oldDigitalAddress;
    }

    public void setOldDigitalAddress(String oldDigitalAddress) {
        this.oldDigitalAddress = oldDigitalAddress;
    }

    public String getDorLatLong() {
        return dorLatLong;
    }

    public void setDorLatLong(String dorLatLong) {
        this.dorLatLong = dorLatLong;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Object getSmallPreview() {
        return smallPreview;
    }

    public void setSmallPreview(Object smallPreview) {
        this.smallPreview = smallPreview;
    }

    public Object getLargePreview() {
        return largePreview;
    }

    public void setLargePreview(Object largePreview) {
        this.largePreview = largePreview;
    }


}
