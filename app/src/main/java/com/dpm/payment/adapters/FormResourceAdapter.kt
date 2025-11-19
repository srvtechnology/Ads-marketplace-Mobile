package com.dpm.payment.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.dpm.payment.databinding.AdapterFormsResourcesBinding
import com.dpm.payment.models.cep.formResources.FormResource

class FormResourceAdapter :
    ListAdapter<FormResource, FormResourceAdapter.ViewHolder>(DiffCallback()) {

   private var onItemClick : ((item : FormResource) -> Unit)? =null

    public fun setOnItemClickListener(listener :(item : FormResource) -> Unit ){
        this.onItemClick=listener
    }


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding =
            AdapterFormsResourcesBinding.inflate(
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

    inner class ViewHolder(private val binding:AdapterFormsResourcesBinding ) :
        RecyclerView.ViewHolder(binding.root) {

            fun setData(data : FormResource){
                binding.apply {
                    tvTitle.text = data.formName
                    root.setOnClickListener {
                        onItemClick?.invoke(data)
                    }
                }

            }


        }

    class DiffCallback : DiffUtil.ItemCallback<FormResource>() {
        override fun areItemsTheSame(oldItem: FormResource, newItem: FormResource) =
            oldItem.id == newItem.id

        override fun areContentsTheSame(oldItem: FormResource, newItem: FormResource) =
            oldItem == newItem
    }
}