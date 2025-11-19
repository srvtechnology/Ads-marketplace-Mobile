package com.dpm.payment.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.interfaces.OnItemClickListener;
import com.dpm.payment.models.cep.CepModel;
import com.dpm.payment.R;

import java.util.List;

public class FormsResourceAdapter extends RecyclerView.Adapter<FormsResourceAdapter.ViewHolder> {


    private Context mContext;
    private List<String> list;
    private OnItemClickListener mOnItemClickListener;

    public FormsResourceAdapter(Context mContext, List<String> list, OnItemClickListener mOnItemClickListener) {
        this.mContext = mContext;
        this.list = list;
        this.mOnItemClickListener = mOnItemClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(mContext).inflate(R.layout.adapter_forms_resources, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        String item = list.get(position);
        holder.tvTitle.setText(item);
        holder.frmlytFormsResources.setOnClickListener(v -> {
            mOnItemClickListener.onItemClick(v,position);
        });

    }



    @Override
    public int getItemCount() {
        return list != null ? list.size() : 0;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        AppCompatTextView tvTitle;
        FrameLayout frmlytFormsResources;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvTitle = itemView.findViewById(R.id.tvTitle);
            frmlytFormsResources = itemView.findViewById(R.id.frmlytFormsResources);
        }
    }
}
