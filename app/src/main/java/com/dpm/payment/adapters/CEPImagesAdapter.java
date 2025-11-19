package com.dpm.payment.adapters;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.appcompat.widget.LinearLayoutCompat;
import androidx.recyclerview.widget.RecyclerView;
import com.dpm.payment.interfaces.OnItemClickListener;
import com.dpm.payment.R;

public class CEPImagesAdapter extends RecyclerView.Adapter<CEPImagesAdapter.ViewHolder> {


    private Activity activity;
    private OnItemClickListener mOnItemClickListener;
    public CEPImagesAdapter(Activity activity, OnItemClickListener mOnItemClickListener) {
        this.activity = activity;
        this.mOnItemClickListener = mOnItemClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(activity).inflate(R.layout.adapter_cep_images, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {

        holder.llImages.setOnClickListener(v -> {
            mOnItemClickListener.onItemClick(v,position);
        });

    }



    @Override
    public int getItemCount() {
        return /*list != null ? list.size() : 0*/2;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivCepImage;
        AppCompatTextView tvTitle;
        LinearLayoutCompat llImages;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivCepImage = itemView.findViewById(R.id.ivCepImage);
            tvTitle = itemView.findViewById(R.id.tvTitle);
            llImages = itemView.findViewById(R.id.llImages);
        }
    }
}
