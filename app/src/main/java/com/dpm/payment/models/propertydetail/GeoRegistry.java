package com.dpm.payment.models.propertydetail;

import com.google.gson.annotations.SerializedName;

public class GeoRegistry{

	@SerializedName("point8")
	private Object point8;

	@SerializedName("point4")
	private Object point4;

	@SerializedName("point5")
	private Object point5;

	@SerializedName("created_at")
	private String createdAt;

	@SerializedName("point6")
	private Object point6;

	@SerializedName("small_preview")
	private Object smallPreview;

	@SerializedName("point7")
	private Object point7;

	@SerializedName("meter_number")
	private Object meterNumber;

	@SerializedName("point1")
	private String point1;

	@SerializedName("property_id")
	private int propertyId;

	@SerializedName("point2")
	private String point2;

	@SerializedName("point3")
	private String point3;

	@SerializedName("digital_address")
	private String digitalAddress;

	@SerializedName("old_digital_address")
	private Object oldDigitalAddress;

	@SerializedName("open_location_code")
	private String openLocationCode;

	@SerializedName("updated_at")
	private String updatedAt;

	@SerializedName("dor_lat_long")
	private String dorLatLong;

	@SerializedName("large_preview")
	private Object largePreview;

	@SerializedName("id")
	private int id;

	@SerializedName("meter_images")
	private Object meterImages;

	public void setPoint8(Object point8){
		this.point8 = point8;
	}

	public Object getPoint8(){
		return point8;
	}

	public void setPoint4(Object point4){
		this.point4 = point4;
	}

	public Object getPoint4(){
		return point4;
	}

	public void setPoint5(Object point5){
		this.point5 = point5;
	}

	public Object getPoint5(){
		return point5;
	}

	public void setCreatedAt(String createdAt){
		this.createdAt = createdAt;
	}

	public String getCreatedAt(){
		return createdAt;
	}

	public void setPoint6(Object point6){
		this.point6 = point6;
	}

	public Object getPoint6(){
		return point6;
	}

	public void setSmallPreview(Object smallPreview){
		this.smallPreview = smallPreview;
	}

	public Object getSmallPreview(){
		return smallPreview;
	}

	public void setPoint7(Object point7){
		this.point7 = point7;
	}

	public Object getPoint7(){
		return point7;
	}

	public void setMeterNumber(Object meterNumber){
		this.meterNumber = meterNumber;
	}

	public Object getMeterNumber(){
		return meterNumber;
	}

	public void setPoint1(String point1){
		this.point1 = point1;
	}

	public String getPoint1(){
		return point1;
	}

	public void setPropertyId(int propertyId){
		this.propertyId = propertyId;
	}

	public int getPropertyId(){
		return propertyId;
	}

	public void setPoint2(String point2){
		this.point2 = point2;
	}

	public String getPoint2(){
		return point2;
	}

	public void setPoint3(String point3){
		this.point3 = point3;
	}

	public String getPoint3(){
		return point3;
	}

	public void setDigitalAddress(String digitalAddress){
		this.digitalAddress = digitalAddress;
	}

	public String getDigitalAddress(){
		return digitalAddress;
	}

	public void setOldDigitalAddress(Object oldDigitalAddress){
		this.oldDigitalAddress = oldDigitalAddress;
	}

	public Object getOldDigitalAddress(){
		return oldDigitalAddress;
	}

	public void setOpenLocationCode(String openLocationCode){
		this.openLocationCode = openLocationCode;
	}

	public String getOpenLocationCode(){
		return openLocationCode;
	}

	public void setUpdatedAt(String updatedAt){
		this.updatedAt = updatedAt;
	}

	public String getUpdatedAt(){
		return updatedAt;
	}

	public void setDorLatLong(String dorLatLong){
		this.dorLatLong = dorLatLong;
	}

	public String getDorLatLong(){
		return dorLatLong;
	}

	public void setLargePreview(Object largePreview){
		this.largePreview = largePreview;
	}

	public Object getLargePreview(){
		return largePreview;
	}

	public void setId(int id){
		this.id = id;
	}

	public int getId(){
		return id;
	}

	public void setMeterImages(Object meterImages){
		this.meterImages = meterImages;
	}

	public Object getMeterImages(){
		return meterImages;
	}

	@Override
 	public String toString(){
		return 
			"GeoRegistry{" + 
			"point8 = '" + point8 + '\'' + 
			",point4 = '" + point4 + '\'' + 
			",point5 = '" + point5 + '\'' + 
			",created_at = '" + createdAt + '\'' + 
			",point6 = '" + point6 + '\'' + 
			",small_preview = '" + smallPreview + '\'' + 
			",point7 = '" + point7 + '\'' + 
			",meter_number = '" + meterNumber + '\'' + 
			",point1 = '" + point1 + '\'' + 
			",property_id = '" + propertyId + '\'' + 
			",point2 = '" + point2 + '\'' + 
			",point3 = '" + point3 + '\'' + 
			",digital_address = '" + digitalAddress + '\'' + 
			",old_digital_address = '" + oldDigitalAddress + '\'' + 
			",open_location_code = '" + openLocationCode + '\'' + 
			",updated_at = '" + updatedAt + '\'' + 
			",dor_lat_long = '" + dorLatLong + '\'' + 
			",large_preview = '" + largePreview + '\'' + 
			",id = '" + id + '\'' + 
			",meter_images = '" + meterImages + '\'' + 
			"}";
		}
}