package com.dpm.payment.activities.cep.garbageCollection

import android.app.Activity
import android.content.res.ColorStateList
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.dpm.payment.R
import com.dpm.payment.activities.cep.garbageCollection.model.CalendarDay
import com.dpm.payment.activities.cep.garbageCollection.model.getDateResponse.SlotItem
import com.dpm.payment.retrofit.Utills.ToastUtils
import java.util.Calendar

class CalendarAdapter(
    private val days: List<CalendarDay>
) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private var onDateClick: ((calender: CalendarDay) -> Unit)? = null

    public fun onDateClickListener(listener: (calender: CalendarDay) -> Unit) {
        this.onDateClick = listener
    }

    private val VIEW_TYPE_HEADER = 0
    private val VIEW_TYPE_DAY = 1
    private val headers = listOf("S", "M", "T", "W", "T", "F", "S")

    var selectedDay = -1

    override fun getItemViewType(position: Int): Int {
        return if (position < 7) VIEW_TYPE_HEADER else VIEW_TYPE_DAY
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == VIEW_TYPE_HEADER) {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.calendar_day_header_item, parent, false)
            HeaderViewHolder(view)
        } else {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.calendar_day_item, parent, false)
            DayViewHolder(view)
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder.itemViewType == VIEW_TYPE_HEADER) {
            (holder as HeaderViewHolder).headerText.text = headers[position]
        } else {
            val day = days[position - 7] // Adjust for header
            (holder as DayViewHolder).dayText.text = if (day.date > 0) day.date.toString() else ""

            if (selectedDay == position) {
                holder.dayText.setBackgroundResource(R.color.colorBlue)
                holder.dayText.setTextColor(
                    ColorStateList.valueOf(
                        ContextCompat.getColor(
                            holder.itemView.context,
                            R.color.white_text_color
                        )
                    )
                )
            } else if (day.isAvailable) {
                holder.dayText.setBackgroundResource(R.drawable.bg_calender)
                holder.dayText.setTextColor(
                    ColorStateList.valueOf(
                        ContextCompat.getColor(
                            holder.itemView.context,
                            R.color.black_text_color
                        )
                    )
                )

            } else {
                holder.dayText.setBackgroundResource(android.R.color.transparent)
                holder.dayText.setTextColor(
                    ColorStateList.valueOf(
                        ContextCompat.getColor(
                            holder.itemView.context,
                            R.color.black_text_color
                        )
                    )
                )

            }



            holder.dayText.setOnClickListener {
                val selectedCalender = Calendar.getInstance()
                selectedCalender.set(Calendar.DATE, day.date)
                selectedCalender.set(Calendar.MONTH, day.calender.get(Calendar.MONTH))
                selectedCalender.set(Calendar.YEAR, day.calender.get(Calendar.YEAR))

                if (selectedCalender.timeInMillis >= Calendar.getInstance().timeInMillis && day.isAvailable) {
                    /* ToastUtils.showShort(
                         holder.itemView.context as Activity,
                         "You can book the slot"
                     )*/
                    onDateClick?.invoke(day)

                    selectedDay = position
                    notifyDataSetChanged()

                } else {
                    ToastUtils.showShort(
                        holder.itemView.context as Activity,
                        "You can't book the slot"
                    )
                }


            }


        }
    }

    override fun getItemCount(): Int = days.size + 7

    class DayViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val dayText: TextView = itemView.findViewById(R.id.dayText)
    }

    class HeaderViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val headerText: TextView = itemView.findViewById(R.id.headerText)
    }
}
