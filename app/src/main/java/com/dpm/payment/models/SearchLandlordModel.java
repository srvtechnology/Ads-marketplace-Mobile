package com.dpm.payment.models;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class SearchLandlordModel {


    @SerializedName("id")
    @Expose
    private Integer id;
    @SerializedName("property_id")
    @Expose
    private Integer propertyId;
    @SerializedName("first_name")
    @Expose
    private String firstName = "";

    @SerializedName("ownerTitle")
    @Expose
    private String ownerTitle = "";
    @SerializedName("ownerTitle_id")
    @Expose
    private String ownerTitle_id = "";

    @SerializedName("middle_name")
    @Expose
    private String middleName = "";
    @SerializedName("surname")
    @Expose
    private String surname = "";
    @SerializedName("email")
    @Expose
    private Object email = "";
    @SerializedName("sex")
    @Expose
    private String sex = "";
    @SerializedName("street_number")
    @Expose
    private String streetNumber = "";

    @SerializedName("street_numbernew")
    @Expose
    private String street_numbernew = "";


    @SerializedName("street_name")
    @Expose
    private String streetName = "";
    @SerializedName("image")
    @Expose
    private Object image;
    @SerializedName("id_number")
    @Expose
    private Object idNumber;
    @SerializedName("id_type")
    @Expose
    private Object idType;
    @SerializedName("tin")
    @Expose
    private Object tin;
    @SerializedName("ward")
    @Expose
    private String ward;
    @SerializedName("constituency")
    @Expose
    private String constituency;
    @SerializedName("section")
    @Expose
    private String section;
    @SerializedName("chiefdom")
    @Expose
    private String chiefdom;
    @SerializedName("district")
    @Expose
    private String district;
    @SerializedName("province")
    @Expose
    private String province;
    @SerializedName("postcode")
    @Expose
    private String postcode;
    @SerializedName("mobile_1")
    @Expose
    private String mobile1;
    @SerializedName("mobile_2")
    @Expose
    private String mobile2;
    @SerializedName("created_at")
    @Expose
    private String createdAt;
    @SerializedName("updated_at")
    @Expose
    private String updatedAt;
    @SerializedName("original")
    @Expose
    private Object original;
    @SerializedName("small_preview")
    @Expose
    private Object smallPreview;
    @SerializedName("large_preview")
    @Expose
    private Object largePreview;
    @SerializedName("phone_number")
    @Expose
    private String phoneNumber;

    @SerializedName("titles")
    @Expose
    private Titles titles;

    public Titles getTitles() {
        return titles==null? new Titles() : titles;
    }


    public String getOwnerTitle() {
        return ownerTitle;
    }






    public void setOwnerTitle(String ownerTitle) {
        this.ownerTitle = ownerTitle;
    }

    public String getOwnerTitle_id() {
        return ownerTitle_id;
    }

    public void setOwnerTitle_id(String ownerTitle_id) {
        this.ownerTitle_id = ownerTitle_id;
    }

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

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getMiddleName() {
        return middleName;
    }

    public void setMiddleName(String middleName) {
        this.middleName = middleName;
    }

    public String getSurname() {
        return surname;
    }

    public void setSurname(String surname) {
        this.surname = surname;
    }

    public Object getEmail() {
        return email;
    }

    public void setEmail(Object email) {
        this.email = email;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public String getStreetNumber() {
        return streetNumber;
    }

    public void setStreetNumber(String streetNumber) {
        this.streetNumber = streetNumber;
    }

    public String getStreetName() {
        return streetName;
    }

    public void setStreetName(String streetName) {
        this.streetName = streetName;
    }

    public Object getImage() {
        return image;
    }

    public void setImage(Object image) {
        this.image = image;
    }

    public Object getIdNumber() {
        return idNumber;
    }

    public void setIdNumber(Object idNumber) {
        this.idNumber = idNumber;
    }

    public Object getIdType() {
        return idType;
    }

    public void setIdType(Object idType) {
        this.idType = idType;
    }

    public Object getTin() {
        return tin;
    }

    public void setTin(Object tin) {
        this.tin = tin;
    }

    public String getWard() {
        return ward;
    }

    public void setWard(String ward) {
        this.ward = ward;
    }

    public String getConstituency() {
        return constituency;
    }

    public void setConstituency(String constituency) {
        this.constituency = constituency;
    }

    public String getSection() {
        return section;
    }

    public void setSection(String section) {
        this.section = section;
    }

    public String getChiefdom() {
        return chiefdom;
    }

    public void setChiefdom(String chiefdom) {
        this.chiefdom = chiefdom;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public String getPostcode() {
        return postcode;
    }

    public void setPostcode(String postcode) {
        this.postcode = postcode;
    }

    public String getMobile1() {
        return mobile1;
    }

    public void setMobile1(String mobile1) {
        this.mobile1 = mobile1;
    }

    public String getMobile2() {
        return mobile2;
    }

    public void setMobile2(String mobile2) {
        this.mobile2 = mobile2;
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

    public Object getOriginal() {
        return original;
    }

    public void setOriginal(Object original) {
        this.original = original;
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

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }


    public String getStreet_numbernew() {
        return street_numbernew;
    }

    public void setStreet_numbernew(String street_numbernew) {
        this.street_numbernew = street_numbernew;
    }
}
