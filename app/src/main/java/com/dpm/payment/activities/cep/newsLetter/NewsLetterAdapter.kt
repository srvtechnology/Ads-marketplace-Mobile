package com.dpm.payment.activities.cep.newsLetter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.CircularProgressDrawable
import com.dpm.payment.R
import com.dpm.payment.activities.cep.newsLetter.model.NewsDataItem
import com.dpm.payment.databinding.AdapterNewsLetterBinding
import com.dpm.payment.utils.circularProgressIndicator
import com.squareup.picasso.Picasso

class NewsLetterAdapter : ListAdapter<NewsDataItem, NewsLetterAdapter.ViewHolder>(DiffCallback()) {

    var onItemClick: ((String?) -> Unit?)? = null

   inline fun setOnItemClickListener(noinline listener: (String?) -> Unit) {
        onItemClick = listener
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding =
            AdapterNewsLetterBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val currentItem = getItem(position)
        holder.bindData(currentItem)
    }

    inner class ViewHolder(private val binding: AdapterNewsLetterBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bindData(data: NewsDataItem) {
            binding.apply {
                tvTitle.text = data.headline
                Picasso.get().load(data.headlineImg()).placeholder(binding.root.context.circularProgressIndicator())
                    .error(R.drawable.image_loading_failed).into(ivNews)
                root.setOnClickListener {
                    onItemClick?.invoke(data.news_detail)
                }
            }
        }
    }

    class DiffCallback : DiffUtil.ItemCallback<NewsDataItem>() {
        override fun areItemsTheSame(oldItem: NewsDataItem, newItem: NewsDataItem) =
            oldItem.id == newItem.id

        override fun areContentsTheSame(oldItem: NewsDataItem, newItem: NewsDataItem) =
            oldItem == newItem
    }
}