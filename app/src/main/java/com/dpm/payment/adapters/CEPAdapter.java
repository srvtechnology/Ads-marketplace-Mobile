package com.dpm.payment.adapters;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.fragment.app.FragmentActivity;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.interfaces.OnItemClickListener;
import com.dpm.payment.models.TransactionModel;
import com.dpm.payment.models.cep.CepModel;
import com.dpm.payment.R;
import com.squareup.picasso.Picasso;

import java.util.List;

public class CEPAdapter extends RecyclerView.Adapter<CEPAdapter.ViewHolder> {


    private Context mContext;
    private List<CepModel> list;
    private OnItemClickListener mOnItemClickListener;

    public CEPAdapter(Context mContext, List<CepModel> list, OnItemClickListener mOnItemClickListener) {
        this.mContext = mContext;
        this.list = list;
        this.mOnItemClickListener = mOnItemClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(mContext).inflate(R.layout.adapter_cep, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        CepModel item = list.get(position);
        holder.ivCep.setImageResource(item.getCepIcon());
        holder.tvTitle.setText(item.getCepTitle());
        holder.frmlytCepMenu.setOnClickListener(v -> {
            mOnItemClickListener.onItemClick(v,position);
        });

    }



    @Override
    public int getItemCount() {
        return list != null ? list.size() : 0;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivCep;
        AppCompatTextView tvTitle;
        FrameLayout frmlytCepMenu;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivCep = itemView.findViewById(R.id.ivCep);
            tvTitle = itemView.findViewById(R.id.tvTitle);
            frmlytCepMenu = itemView.findViewById(R.id.frmlytCepMenu);
        }
    }
}
