package com.dpm.payment.utils

import android.app.Activity
import android.app.TimePickerDialog
import android.widget.TimePicker
import java.util.Calendar

fun Activity.pickTime(
    initialHour: Int = Calendar.getInstance().get(Calendar.HOUR_OF_DAY),
    initialMinute: Int = Calendar.getInstance().get(Calendar.MINUTE),
    is24HourView: Boolean = false,
    onTimePicked: (hourOfDay: Int, minute: Int) -> Unit
) {
    TimePickerDialog(
        this,
        { _: TimePicker, hourOfDay: Int, minute: Int ->
            onTimePicked(hourOfDay, minute)
        },
        initialHour,
        initialMinute,
        is24HourView
    ).show()
}
