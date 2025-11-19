package com.dpm.payment.models.cep;

import com.google.gson.annotations.SerializedName;

public class GuestUser{

	@SerializedName("image")
	private String image;

	@SerializedName("is_active")
	private int isActive;

	@SerializedName("gender")
	private String gender;

	@SerializedName("created_at")
	private String createdAt;

	@SerializedName("email_verified_at")
	private String emailVerifiedAt;

	@SerializedName("section")
	private String section;

	@SerializedName("small_preview")
	private String smallPreview;

	@SerializedName("ward")
	private String ward;

	@SerializedName("street_name")
	private String streetName;

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

	@SerializedName("large_preview")
	private String largePreview;

	@SerializedName("district")
	private String district;

	@SerializedName("name")
	private String name;

	@SerializedName("street_number")
	private String streetNumber;

	@SerializedName("id")
	private int id;

	@SerializedName("assign_district_id")
	private String assignDistrictId;

	@SerializedName("email")
	private String email;

	@SerializedName("username")
	private String username;

	public String getImage(){
		return image;
	}

	public int getIsActive(){
		return isActive;
	}

	public String getGender(){
		return gender;
	}

	public String getCreatedAt(){
		return createdAt;
	}

	public String getEmailVerifiedAt(){
		return emailVerifiedAt;
	}

	public String getSection(){
		return section;
	}

	public String getSmallPreview(){
		return smallPreview;
	}

	public String getWard(){
		return ward;
	}

	public String getStreetName(){
		return streetName;
	}

	public String getAssignDistrict(){
		return assignDistrict;
	}

	public String getConstituency(){
		return constituency;
	}

	public String getProvince(){
		return province;
	}

	public String getUpdatedAt(){
		return updatedAt;
	}

	public String getChiefdom(){
		return chiefdom;
	}

	public String getLargePreview(){
		return largePreview;
	}

	public String getDistrict(){
		return district;
	}

	public String getName(){
		return name;
	}

	public String getStreetNumber(){
		return streetNumber;
	}

	public int getId(){
		return id;
	}

	public String getAssignDistrictId(){
		return assignDistrictId;
	}

	public String getEmail(){
		return email;
	}

	public String getUsername(){
		return username;
	}
}