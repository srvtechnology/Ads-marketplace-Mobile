package com.dpm.payment.models.cep.formResources

import com.google.gson.annotations.SerializedName

data class FormResourceResponse(

	@field:SerializedName("data")
	val data: List<FormResource?>? = null,

	@field:SerializedName("message")
	val message: String? = null,

	@field:SerializedName("status")
	val status: String? = null
)

data class FormResource(

	@field:SerializedName("form_image")
	val formImage: String? = null,

	@field:SerializedName("updated_at")
	val updatedAt: String? = null,

	@field:SerializedName("user_id")
	val userId: Int? = null,

	@field:SerializedName("created_at")
	val createdAt: String? = null,

	@field:SerializedName("id")
	val id: Int? = null,

	@field:SerializedName("form_name")
	val formName: String? = null,

	@field:SerializedName("status")
	val status: String? = null
)
