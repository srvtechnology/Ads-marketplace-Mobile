package com.dpm.payment.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.interfaces.OnItemClickListener;
import com.dpm.payment.R;

public class NewsLetterAdapter extends RecyclerView.Adapter<NewsLetterAdapter.ViewHolder> {


    private Context mContext;
    private OnItemClickListener mOnItemClickListener;
    public NewsLetterAdapter(Context mContext, OnItemClickListener mOnItemClickListener) {
        this.mContext = mContext;
        this.mOnItemClickListener = mOnItemClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(mContext).inflate(R.layout.adapter_news_letter, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {

        holder.rlNewsLetter.setOnClickListener(v -> {
            mOnItemClickListener.onItemClick(v,position);
        });

    }



    @Override
    public int getItemCount() {
        return /*list != null ? list.size() : 0*/5;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        AppCompatImageView ivNews;
        AppCompatTextView tvTitle;
        RelativeLayout rlNewsLetter;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivNews = itemView.findViewById(R.id.ivNews);
            tvTitle = itemView.findViewById(R.id.tvTitle);
            rlNewsLetter = itemView.findViewById(R.id.rlNewsLetter);
        }
    }
}
