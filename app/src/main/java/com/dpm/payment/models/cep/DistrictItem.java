package com.dpm.payment.models.cep;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class DistrictItem implements Serializable {

	@SerializedName("enquiries_phone2")
	private String enquiriesPhone2;

	@SerializedName("enquiries_phone")
	private String enquiriesPhone;

	@SerializedName("council_address")
	private String councilAddress;

	@SerializedName("group_name")
	private String groupName;

	@SerializedName("council_short_name")
	private String councilShortName;

	@SerializedName("enquiries_email")
	private String enquiriesEmail;

	@SerializedName("name")
	private String name;

	@SerializedName("council_name")
	private String councilName;

	@SerializedName("primary_logo")
	private String primaryLogo;

	@SerializedName("id")
	private int id;

	@SerializedName("council_address_envp")
	private String councilAddressEnvp;

	@SerializedName("secondary_logo")
	private String secondaryLogo;

	@SerializedName("wards")
	private String wards;



	@SerializedName("constituencies")
	private String constituencies;
	@SerializedName("district")
	private String district;
	@SerializedName("province")
	private String province;


	public String getEnquiriesPhone2(){
		return enquiriesPhone2;
	}

	public String getEnquiriesPhone(){
		return enquiriesPhone;
	}

	public String getCouncilAddress(){
		return councilAddress;
	}

	public String getGroupName(){
		return groupName;
	}

	public String getCouncilShortName(){
		return councilShortName;
	}

	public String getEnquiriesEmail(){
		return enquiriesEmail;
	}

	public String getName(){
		return name;
	}

	public String getCouncilName(){
		return councilName;
	}

	public String getPrimaryLogo(){
		return primaryLogo;
	}

	public int getId(){
		return id;
	}

	public String getCouncilAddressEnvp(){
		return councilAddressEnvp;
	}

	public String getSecondaryLogo(){
		return secondaryLogo;
	}

	public String getWards() {
		return wards;
	}

	public String getConstituencies() {
		return constituencies;
	}

	public String getDistrict() {
		return district;
	}

	public String getProvince() {
		return province;
	}
}