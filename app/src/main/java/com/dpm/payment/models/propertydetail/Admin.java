package com.dpm.payment.models.propertydetail;

import com.google.gson.annotations.SerializedName;

public class Admin{

	@SerializedName("image")
	private String image;

	@SerializedName("is_active")
	private int isActive;

	@SerializedName("gender")
	private String gender;

	@SerializedName("last_name")
	private String lastName;

	@SerializedName("created_at")
	private String createdAt;

	@SerializedName("section")
	private String section;

	@SerializedName("ward")
	private String ward;

	@SerializedName("street_name")
	private Object streetName;

	@SerializedName("assign_district")
	private String assignDistrict;

	@SerializedName("constituency")
	private String constituency;

	@SerializedName("province")
	private String province;

	@SerializedName("updated_at")
	private String updatedAt;

	@SerializedName("chiefdom")
	private String chiefdom;

	@SerializedName("district")
	private String district;

	@SerializedName("street_number")
	private Object streetNumber;

	@SerializedName("id")
	private int id;

	@SerializedName("assign_district_id")
	private int assignDistrictId;

	@SerializedName("first_name")
	private String firstName;

	@SerializedName("email")
	private String email;

	@SerializedName("username")
	private String username;

	public void setImage(String image){
		this.image = image;
	}

	public String getImage(){
		return image;
	}

	public void setIsActive(int isActive){
		this.isActive = isActive;
	}

	public int getIsActive(){
		return isActive;
	}

	public void setGender(String gender){
		this.gender = gender;
	}

	public String getGender(){
		return gender;
	}

	public void setLastName(String lastName){
		this.lastName = lastName;
	}

	public String getLastName(){
		return lastName;
	}

	public void setCreatedAt(String createdAt){
		this.createdAt = createdAt;
	}

	public String getCreatedAt(){
		return createdAt;
	}

	public void setSection(String section){
		this.section = section;
	}

	public String getSection(){
		return section;
	}

	public void setWard(String ward){
		this.ward = ward;
	}

	public String getWard(){
		return ward;
	}

	public void setStreetName(Object streetName){
		this.streetName = streetName;
	}

	public Object getStreetName(){
		return streetName;
	}

	public void setAssignDistrict(String assignDistrict){
		this.assignDistrict = assignDistrict;
	}

	public String getAssignDistrict(){
		return assignDistrict;
	}

	public void setConstituency(String constituency){
		this.constituency = constituency;
	}

	public String getConstituency(){
		return constituency;
	}

	public void setProvince(String province){
		this.province = province;
	}

	public String getProvince(){
		return province;
	}

	public void setUpdatedAt(String updatedAt){
		this.updatedAt = updatedAt;
	}

	public String getUpdatedAt(){
		return updatedAt;
	}

	public void setChiefdom(String chiefdom){
		this.chiefdom = chiefdom;
	}

	public String getChiefdom(){
		return chiefdom;
	}

	public void setDistrict(String district){
		this.district = district;
	}

	public String getDistrict(){
		return district;
	}

	public void setStreetNumber(Object streetNumber){
		this.streetNumber = streetNumber;
	}

	public Object getStreetNumber(){
		return streetNumber;
	}

	public void setId(int id){
		this.id = id;
	}

	public int getId(){
		return id;
	}

	public void setAssignDistrictId(int assignDistrictId){
		this.assignDistrictId = assignDistrictId;
	}

	public int getAssignDistrictId(){
		return assignDistrictId;
	}

	public void setFirstName(String firstName){
		this.firstName = firstName;
	}

	public String getFirstName(){
		return firstName;
	}

	public void setEmail(String email){
		this.email = email;
	}

	public String getEmail(){
		return email;
	}

	public void setUsername(String username){
		this.username = username;
	}

	public String getUsername(){
		return username;
	}

	@Override
 	public String toString(){
		return 
			"Admin{" + 
			"image = '" + image + '\'' + 
			",is_active = '" + isActive + '\'' + 
			",gender = '" + gender + '\'' + 
			",last_name = '" + lastName + '\'' + 
			",created_at = '" + createdAt + '\'' + 
			",section = '" + section + '\'' + 
			",ward = '" + ward + '\'' + 
			",street_name = '" + streetName + '\'' + 
			",assign_district = '" + assignDistrict + '\'' + 
			",constituency = '" + constituency + '\'' + 
			",province = '" + province + '\'' + 
			",updated_at = '" + updatedAt + '\'' + 
			",chiefdom = '" + chiefdom + '\'' + 
			",district = '" + district + '\'' + 
			",street_number = '" + streetNumber + '\'' + 
			",id = '" + id + '\'' + 
			",assign_district_id = '" + assignDistrictId + '\'' + 
			",first_name = '" + firstName + '\'' + 
			",email = '" + email + '\'' + 
			",username = '" + username + '\'' + 
			"}";
		}
}