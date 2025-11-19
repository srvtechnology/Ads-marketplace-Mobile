package com.dpm.payment.adapters;

import android.annotation.SuppressLint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.utils.StringUtils;
import com.dpm.payment.R;


import java.util.List;


public class PropertyAdapter extends RecyclerView.Adapter<PropertyAdapter.MyViewHolder> {

    private List<PropertyListItem> listOfNav;
    private OnAdapterActionListener mOnItemClickListener;


    public PropertyAdapter(List<PropertyListItem> listOfNav, OnAdapterActionListener _mOnItemClickListener) {
        this.listOfNav = listOfNav;
        this.mOnItemClickListener = _mOnItemClickListener;

    }

    @Override
    public int getItemViewType(int position) {

        return position;
    }

    @NonNull
    @Override
    public MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.adapter_propertylist_item, parent, false);
        return new MyViewHolder(itemView);
    }

    @SuppressLint("DefaultLocale")
    @Override
    public void onBindViewHolder(@NonNull final MyViewHolder holder, int position) {
        final PropertyListItem object = listOfNav.get(position);

        try {



            //tvProperty Name======
            holder.tvProperty.setText("Property Id : "+object.getPropertyName());
            //tvAssessment Name======
            try {
                holder.tvAssessment.setText("Assessment Due : Le " + StringUtils.AmountWithComma(StringUtils.roundStringValue(object.getAssessment())));

            }catch (Exception ex)
            {
                ex.printStackTrace();
            }



            holder.btViewDetails.setOnClickListener(view -> mOnItemClickListener.onItemClickListener(position));



        } catch (Exception e) {
            e.printStackTrace();
        }


    }

    @Override
    public int getItemCount() {


        return listOfNav == null ? 0 : listOfNav.size();
    }

    public interface OnAdapterActionListener {


        void onItemClickListener(int position);

    }

    class MyViewHolder extends RecyclerView.ViewHolder {

        TextView tvProperty,tvAssessment;

Button btViewDetails;


        // view create //
        MyViewHolder(View view) {
            super(view);
            tvProperty= view.findViewById(R.id.tvProperty);
            tvAssessment= view.findViewById(R.id.tvAssessment);
            btViewDetails=view.findViewById(R.id.btViewDetails);

        }
    }
}