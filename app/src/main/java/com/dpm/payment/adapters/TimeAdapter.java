package com.dpm.payment.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatRadioButton;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.interfaces.OnItemClickListener;
import com.dpm.payment.models.cep.CepModel;
import com.dpm.payment.models.cep.TimeModel;
import com.dpm.payment.R;

import java.util.List;

public class TimeAdapter extends RecyclerView.Adapter<TimeAdapter.ViewHolder> {


    private Context mContext;
    private List<TimeModel> list;
    private OnItemClickListener mOnItemClickListener;

    public TimeAdapter(Context mContext, List<TimeModel> list, OnItemClickListener mOnItemClickListener) {
        this.mContext = mContext;
        this.list = list;
        this.mOnItemClickListener = mOnItemClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(mContext).inflate(R.layout.adapter_time, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        TimeModel item = list.get(position);
        holder.tvTime.setText(item.getTimeRange());
        holder.rbTime.setChecked(item.getSelected());
    }



    @Override
    public int getItemCount() {
        return list != null ? list.size() : 0;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        AppCompatTextView tvTime;
        AppCompatRadioButton rbTime;
        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvTime = itemView.findViewById(R.id.tvTime);
            rbTime = itemView.findViewById(R.id.rbTime);
        }
    }
}
