package com.dpm.payment.models.receipt;

import com.google.gson.annotations.SerializedName;

public class DatasItem{

	@SerializedName("id")
	private String id;

	@SerializedName("url")
	private String url;

	@SerializedName("pdf_url")
	private String pdf_url;

	public String getPdf_url() {
		return pdf_url;
	}

	public void setId(String id){
		this.id = id;
	}

	public String getId(){
		return id;
	}

	public void setUrl(String url){
		this.url = url;
	}

	public String getUrl(){
		return url;
	}

	@Override
 	public String toString(){
		return 
			"DatasItem{" + 
			"id = '" + id + '\'' + 
			",url = '" + url + '\'' + 
			"}";
		}
}