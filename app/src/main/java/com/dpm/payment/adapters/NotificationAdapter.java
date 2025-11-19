package com.dpm.payment.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.LinearLayoutCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.interfaces.OnItemClickListener;
import com.dpm.payment.R;

import java.util.List;

public class NotificationAdapter extends RecyclerView.Adapter<NotificationAdapter.ViewHolder> {


    private Context mContext;
    private OnItemClickListener mOnItemClickListener;

    public NotificationAdapter(Context mContext, OnItemClickListener mOnItemClickListener) {
        this.mContext = mContext;
        this.mOnItemClickListener = mOnItemClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(mContext).inflate(R.layout.adapter_notification, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.llNotification.setOnClickListener(v -> {
            mOnItemClickListener.onItemClick(v,position);
        });

    }



    @Override
    public int getItemCount() {
        return 10;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        LinearLayoutCompat llNotification;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            llNotification = itemView.findViewById(R.id.llNotification);

        }
    }
}
