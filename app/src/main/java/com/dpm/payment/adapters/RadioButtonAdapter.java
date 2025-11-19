package com.dpm.payment.adapters;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.appcompat.widget.LinearLayoutCompat;
import androidx.recyclerview.widget.RecyclerView;
import com.dpm.payment.interfaces.OnItemClickListener;
import com.dpm.payment.R;

import java.util.List;

public class RadioButtonAdapter extends RecyclerView.Adapter<RadioButtonAdapter.ViewHolder> {


    private Activity activity;
    private List<String> list;
    private OnItemClickListener mOnItemClickListener;

    public RadioButtonAdapter(Activity activity, List<String> list, OnItemClickListener mOnItemClickListener) {
        this.activity = activity;
        this.list = list;
        this.mOnItemClickListener = mOnItemClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(activity).inflate(R.layout.adapter_radio_button, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        String item = list.get(position);
        holder.tvText.setText(item);
        holder.llRadioButton.setOnClickListener(v -> {
            mOnItemClickListener.onItemClick(v,position);
        });

    }



    @Override
    public int getItemCount() {
        return list != null ? list.size() : 0;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        RadioButton radioButton;
        AppCompatTextView tvText;
        LinearLayoutCompat llRadioButton;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            radioButton = itemView.findViewById(R.id.radioButton);
            tvText = itemView.findViewById(R.id.tvText);
            llRadioButton = itemView.findViewById(R.id.llRadioButton);
        }
    }
}
