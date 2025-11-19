package com.dpm.payment.activities.cep.garbageCollection.model.getDateResponse

import com.google.gson.annotations.SerializedName

data class SlotItem(

	@field:SerializedName("slots")
	val slots: String? = null,

	@field:SerializedName("garbage_date_id")
	val garbageDateId: Int? = null,

	@field:SerializedName("id")
	val id: Int? = null
)