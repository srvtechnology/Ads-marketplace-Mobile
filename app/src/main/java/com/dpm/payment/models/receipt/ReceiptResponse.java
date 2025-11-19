package com.dpm.payment.models.receipt;

import java.util.List;
import com.google.gson.annotations.SerializedName;

public class ReceiptResponse{

	@SerializedName("code")
	private int code;

	@SerializedName("success")
	private boolean success;

	@SerializedName("datas")
	private List<DatasItem> datas;

	public void setCode(int code){
		this.code = code;
	}

	public int getCode(){
		return code;
	}

	public void setSuccess(boolean success){
		this.success = success;
	}

	public boolean isSuccess(){
		return success;
	}

	public void setDatas(List<DatasItem> datas){
		this.datas = datas;
	}

	public List<DatasItem> getDatas(){
		return datas;
	}

	@Override
 	public String toString(){
		return 
			"ReceiptResponse{" + 
			"code = '" + code + '\'' + 
			",success = '" + success + '\'' + 
			",datas = '" + datas + '\'' + 
			"}";
		}
}