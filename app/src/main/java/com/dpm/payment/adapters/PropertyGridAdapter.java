package com.dpm.payment.adapters;

import android.annotation.SuppressLint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.dpm.payment.utils.LogUtils;
import com.dpm.payment.utils.StringUtils;
import com.dpm.payment.R;
import com.squareup.picasso.Picasso;

import java.util.List;

import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.RecyclerView;


public class PropertyGridAdapter extends RecyclerView.Adapter<PropertyGridAdapter.MyViewHolder> {

    private List<PropertyListItem> listOfNav;
    private OnAdapterActionListener mOnItemClickListener;


    public PropertyGridAdapter(List<PropertyListItem> listOfNav, OnAdapterActionListener _mOnItemClickListener) {
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

        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.adapter_propertygrid_item, parent, false);
        return new MyViewHolder(itemView);
    }

    @SuppressLint("DefaultLocale")
    @Override
    public void onBindViewHolder(@NonNull final MyViewHolder holder, int position) {
        final PropertyListItem object = listOfNav.get(position);

        try {



            //tvProperty Name======
            holder.tvProperty.setText(object.getPropertyName());
            //tvAssessment Name======
            try {
                holder.tvAssessment.setText("Le " + StringUtils.AmountWithComma(StringUtils.roundStringValue(object.getBalance())));

            }catch (Exception ex)
            {
                ex.printStackTrace();
            }


            holder.llCellView.setOnClickListener(view -> mOnItemClickListener.onItemClickListener(position));

            try{


                Picasso.get().load(object.getPropertyImg())
                        .placeholder(R.drawable.place_holder)
                        .error(R.drawable.place_holder)
                        .into(holder.ivPropertyImg);

                LogUtils.showErrorLog("TAG Image","TAG PATH "+object.getPropertyImg());
            }catch (Exception ex)
            {
                ex.printStackTrace();
            }


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
          ImageView ivPropertyImg;
        CardView llCellView;


        // view create //
        MyViewHolder(View view) {
            super(view);
            tvProperty= view.findViewById(R.id.tvProperty);
            tvAssessment= view.findViewById(R.id.tvAssessment);
            btViewDetails=view.findViewById(R.id.btViewDetails);
            ivPropertyImg=view.findViewById(R.id.ivPropertyImg);
            llCellView=view.findViewById(R.id.llCellView);

        }
    }
}