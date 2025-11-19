package com.dpm.payment.activities.cep.newsLetter.model

import com.google.gson.annotations.SerializedName

data class HeadingImagesItem(

	@field:SerializedName("images")
	val images: String? = null,

	@field:SerializedName("updated_at")
	val updatedAt: String? = null,

	@field:SerializedName("headline_id")
	val headlineId: Int? = null,

	@field:SerializedName("created_at")
	val createdAt: String? = null,

	@field:SerializedName("id")
	val id: Int? = null
)