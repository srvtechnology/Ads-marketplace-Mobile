package com.dpm.payment.activities.cep.information_tips

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.dpm.payment.databinding.SampleViewBinding

class InformationTipsAdapter :
    ListAdapter<String, InformationTipsAdapter.ViewHolder>(DiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding =
            SampleViewBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val currentItem = getItem(position)
        holder.setData(currentItem)
    }

    inner class ViewHolder(private val binding: SampleViewBinding) :
        RecyclerView.ViewHolder(binding.root) {
            fun setData(data :String){
                binding.tvTitle.text=data
            }
        }

    class DiffCallback : DiffUtil.ItemCallback<String>() {
        override fun areItemsTheSame(oldItem: String, newItem: String) =
            oldItem.hashCode() == newItem.hashCode()

        override fun areContentsTheSame(oldItem: String, newItem: String) =
            oldItem == newItem
    }
}