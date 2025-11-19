package com.dpm.payment.adapters;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.models.TransactionModel;
import com.dpm.payment.R;
import com.squareup.picasso.Picasso;

import java.util.List;

public class CashierImageAdapter extends RecyclerView.Adapter<CashierImageAdapter.MyViewHolder> {


    Activity activity;
    List<TransactionModel> list;
    String type;

    public CashierImageAdapter(Activity activity, List<TransactionModel> list, String type) {
        this.activity = activity;
        this.list = list;
        this.type = type;
    }

    @NonNull
    @Override
    public MyViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new MyViewHolder(LayoutInflater.from(activity).inflate(R.layout.item_cashier_image, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull MyViewHolder holder, int position) {

        TransactionModel item = list.get(position);

        if (type.equalsIgnoreCase("C")) {
            if (item.getPhysical_receipt_image_path() != null && !item.getPhysical_receipt_image_path().equalsIgnoreCase("")) {
                Picasso.get().load(item.getPhysical_receipt_image_path())
                        .placeholder(R.drawable.place_holder)
                        .error(R.drawable.place_holder)
                        // .resize(150, 150)
                        .into(holder.img_physical_receipt_image);
            }
          else holder.itemView.setVisibility(View.GONE);
          //visibility visible
        }

        if (type.equalsIgnoreCase("P")) {
            if (item.getPensioner_discount_image_path() != null && !item.getPensioner_discount_image_path().equalsIgnoreCase("")) {
                if (item.getPensioner_discount_approve().equalsIgnoreCase("1")) {
                    Picasso.get().load(item.getPensioner_discount_image_path())
                            .placeholder(R.drawable.place_holder)
                            .error(R.drawable.place_holder)
                            // .resize(150, 150)
                            .into(holder.img_physical_receipt_image);
                } else holder.itemView.setVisibility(View.GONE);
            } else holder.itemView.setVisibility(View.GONE);
        }

        if (type.equalsIgnoreCase("D")) {
            if (item.getDisability_discount_image_path() != null && !item.getDisability_discount_image_path().equalsIgnoreCase("")) {
               if (item.getDisability_discount_approve().equalsIgnoreCase("1")) {
                    Picasso.get().load(item.getDisability_discount_image_path())
                            .placeholder(R.drawable.place_holder)
                            .error(R.drawable.place_holder)
                            // .resize(150, 150)
                            .into(holder.img_physical_receipt_image);
                } else holder.itemView.setVisibility(View.GONE);
            } else holder.itemView.setVisibility(View.GONE);

        }


    }



    @Override
    public int getItemCount() {
        return list != null ? list.size() : 0;
    }

    public class MyViewHolder extends RecyclerView.ViewHolder {
        ImageView img_physical_receipt_image;
        LinearLayout lyt_physical_receipt_image;

        public MyViewHolder(@NonNull View itemView) {
            super(itemView);
            img_physical_receipt_image = itemView.findViewById(R.id.img_physical_receipt_image);
           /* img_pensioner_discount_image = itemView.findViewById(R.id.img_pensioner_discount_image);
            img_disability_discount_image = itemView.findViewById(R.id.img_disability_discount_image);*/


            lyt_physical_receipt_image = itemView.findViewById(R.id.lyt_physical_receipt_image);
           /* lyt_pensioner_discount_image = itemView.findViewById(R.id.lyt_pensioner_discount_image);
            lyt_disability_discount_image = itemView.findViewById(R.id.lyt_disability_discount_image);*/
        }
    }
}
