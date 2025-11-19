package com.dpm.payment.models.OccupancyModel;

import java.util.List;
import com.google.gson.annotations.SerializedName;

public class Datas{

	@SerializedName("titles")
	private List<TitlesItem> titles;

	@SerializedName("occupancy_type")
	private List<String> occupancyType;

	public List<TitlesItem> getTitles(){
		return titles;
	}

	public List<String> getOccupancyType(){
		return occupancyType;
	}
}