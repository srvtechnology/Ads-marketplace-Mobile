package com.dpm.payment.activities.cep.garbageCollection.model.getDateResponse

import com.google.gson.annotations.SerializedName

data class GetDateResponse(

	@field:SerializedName("GetDateResponse")
	val getDateResponse: List<DateItem>? = null
)