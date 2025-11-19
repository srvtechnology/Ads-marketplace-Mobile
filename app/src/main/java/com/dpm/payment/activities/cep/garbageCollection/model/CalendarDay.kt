package com.dpm.payment.activities.cep.garbageCollection.model

import com.dpm.payment.activities.cep.garbageCollection.model.getDateResponse.SlotItem
import java.util.Calendar

data class CalendarDay(
    val date: Int,
    val isAvailable: Boolean,
    val calender: Calendar,
    val slot: List<SlotItem>? = null
)
