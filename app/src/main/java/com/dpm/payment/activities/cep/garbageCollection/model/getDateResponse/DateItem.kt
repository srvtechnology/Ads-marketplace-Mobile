package com.dpm.payment.activities.cep.garbageCollection.model.getDateResponse

import com.google.gson.annotations.SerializedName

data class DateItem(

    @field:SerializedName("date")
	val date: String? = null,

    @field:SerializedName("get_slot")
	val getSlot: List<SlotItem>? = null,

    @field:SerializedName("id")
	val id: Int? = null
)