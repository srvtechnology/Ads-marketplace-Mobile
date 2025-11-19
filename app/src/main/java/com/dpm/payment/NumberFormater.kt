package com.dpm.payment

import android.annotation.SuppressLint
import java.text.DecimalFormat
import java.text.NumberFormat
import java.util.Locale

class NumberFormater {
    companion object {
        @SuppressLint("DefaultLocale")
        fun formatToTwoDecimalPlaces(number: Double): String {
            return String.format("%.2f", number)
        }

        fun formatAmount(value: Double): String {
            val formatter = NumberFormat.getNumberInstance(Locale.US).apply {
                minimumFractionDigits = 2
                maximumFractionDigits = 2
            }
            return formatter.format(value)
        }


        fun parseDouble(value: String?): Double {
            if (value == null) return 0.00
            return try {
                value.toDouble()
            } catch (e: NumberFormatException) {
                try {
                    value.replace(",", "").toDouble()
                } catch (e: NumberFormatException) {
                    0.00
                }
            }
        }



        fun formatAmount(value : String): String {
            val valueWithTwoDecimalPlaces = NumberFormater.formatToTwoDecimalPlaces(NumberFormater.parseDouble(value)).toDouble()
            return NumberFormater.formatAmount(valueWithTwoDecimalPlaces)
        }
    }
}

