package com.dpm.payment.activities.cep.complaints.doComplain

import android.annotation.SuppressLint
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.dpm.payment.databinding.AdapterRadioButtonBinding

class ReasonAdapter : RecyclerView.Adapter<ReasonAdapter.MyViewHolder>() {

    private var reasons: List<String> = listOf()
     var selectedPos = -1

    @SuppressLint("NotifyDataSetChanged")
    fun submitList(list: List<String>) {
        this.reasons = list
        notifyDataSetChanged()
    }


    inner class MyViewHolder(val binding: AdapterRadioButtonBinding) :
        RecyclerView.ViewHolder(binding.root) {
        @SuppressLint("NotifyDataSetChanged")
        fun bind(reason: String) {
            binding.apply {
                radioButton.isChecked= selectedPos==absoluteAdapterPosition
                tvText.text = reason
                radioButton.setOnClickListener {
                    selectedPos=absoluteAdapterPosition
                    notifyDataSetChanged()
                }
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        return MyViewHolder(
            AdapterRadioButtonBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        )
    }

    override fun getItemCount(): Int {
        return reasons.size
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        holder.bind(reasons[position])

    }
}