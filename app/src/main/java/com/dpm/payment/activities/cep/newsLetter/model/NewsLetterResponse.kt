package com.dpm.payment.activities.cep.newsLetter.model

import com.google.gson.annotations.SerializedName

data class NewsLetterResponse(

    @field:SerializedName("data")
	val data: List<NewsDataItem?>? = null,

    @field:SerializedName("message")
	val message: String? = null,

    @field:SerializedName("status")
	val status: String? = null
)