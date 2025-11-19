package com.dpm.payment.adapters;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.interfaces.OnItemClickListener;
import com.dpm.payment.models.cep.CepModel;
import com.dpm.payment.models.cep.ComplaintsModel;
import com.dpm.payment.R;

import java.util.List;

public class ComplaintsAdapter extends RecyclerView.Adapter<ComplaintsAdapter.ViewHolder> {


    private Activity activity;
    private List<ComplaintsModel> list;
    private OnItemClickListener mOnItemClickListener;

    public ComplaintsAdapter(Activity activity, List<ComplaintsModel> list, OnItemClickListener mOnItemClickListener) {
        this.activity = activity;
        this.list = list;
        this.mOnItemClickListener = mOnItemClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(activity).inflate(R.layout.adapter_complaints, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ComplaintsModel item = list.get(position);
        holder.ivComplaints.setImageResource(item.getComplaintsIcon());
        holder.tvTitle.setText(item.getComplaintsTitle());
        holder.rlComplaints.setOnClickListener(v -> {
            mOnItemClickListener.onItemClick(v,position);
        });
    }



    @Override
    public int getItemCount() {
        return list != null ? list.size() : 0;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivComplaints;
        AppCompatTextView tvTitle;
        RelativeLayout rlComplaints;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivComplaints = itemView.findViewById(R.id.ivComplaints);
            tvTitle = itemView.findViewById(R.id.tvTitle);
            rlComplaints = itemView.findViewById(R.id.rlComplaints);
        }
    }
}
