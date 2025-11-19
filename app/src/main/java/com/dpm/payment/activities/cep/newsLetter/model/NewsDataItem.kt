package com.dpm.payment.activities.cep.newsLetter.model

import com.google.gson.annotations.SerializedName
import java.text.SimpleDateFormat
import java.time.Duration
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

data class NewsDataItem(

    @field:SerializedName("editor")
    val editor: String? = null,

    @field:SerializedName("updated_at")
    val updatedAt: String? = null,

    @field:SerializedName("user_id")
    val userId: Int? = null,

    @field:SerializedName("created_at")
    val createdAt: String? = null,

    @field:SerializedName("id")
    val id: Int? = null,

    @field:SerializedName("headline_image_path")
    private val headlineImg: String? = null,

    @field:SerializedName("headline")
    val headline: String? = null,

    @field:SerializedName("heading_images")
    val headingImages: List<HeadingImagesItem?>? = null,

    @field:SerializedName("status")
    val status: Int? = null,

    @field:SerializedName("headline_description")
    val headline_description: String? = null,
    @field:SerializedName("news_detail")
    val news_detail: String? = null,

    @field:SerializedName("story")
    val story: String? = null
) {
    fun headlineImg() = headlineImg

    fun getCreatedDate(): String {
        val date = SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(createdAt.toString())
        return SimpleDateFormat("dd MMMM yyyy").format(date)
    }

    fun timeAgo(): String {
        val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
        val dateTime = LocalDateTime.parse(createdAt, formatter)
        val now = LocalDateTime.now()

        val duration = Duration.between(dateTime, now)
        return when {
            duration.toMinutes() < 1 -> "Just now"
            duration.toHours() < 1 -> "${duration.toMinutes()} minutes ago"
            duration.toDays() < 1 -> "${duration.toHours()} hours ago"
            duration.toDays() < 30 -> "${duration.toDays()} days ago"
            duration.toDays() < 365 -> "${duration.toDays() / 30} months ago"
            else -> "${duration.toDays() / 365} years ago"
        }
    }
}