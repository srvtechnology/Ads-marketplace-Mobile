package com.dpm.payment.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.interfaces.OnItemClickListener;
import com.dpm.payment.models.cep.ComplaintsModel;
import com.dpm.payment.R;

import java.util.List;

public class EmergencyServiceAdapter extends RecyclerView.Adapter<EmergencyServiceAdapter.ViewHolder> {
    private Context mContext;
    private List<ComplaintsModel> list;
    private OnItemClickListener mOnItemClickListener;

    public EmergencyServiceAdapter(Context mContext, List<ComplaintsModel> list, OnItemClickListener mOnItemClickListener) {
        this.mContext = mContext;
        this.list = list;
        this.mOnItemClickListener = mOnItemClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(mContext).inflate(R.layout.adapter_emegency_service, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ComplaintsModel item = list.get(position);
        holder.ivEmergencyService.setImageResource(item.getComplaintsIcon());
        holder.ivEmergencyService.setOnClickListener(v -> {
            mOnItemClickListener.onItemClick(v,position);
        });
    }

    @Override
    public int getItemCount() {
        return list != null ? list.size() : 0;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivEmergencyService;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivEmergencyService = itemView.findViewById(R.id.ivEmergencyService);

        }
    }
}
