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

public class PropertyImageAdapter extends RecyclerView.Adapter<PropertyImageAdapter.MyViewHolder> {


    Activity activity;
    List<String> list;
    String type;

    public PropertyImageAdapter(Activity activity, List<String> list, String type) {
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

        String item = list.get(position);

        if (item!= null && !item.equalsIgnoreCase("")) {
            Picasso.get().load(item)
                    .placeholder(R.drawable.place_holder)
                    .error(R.drawable.place_holder)
                    // .resize(150, 150)
                    .into(holder.img_physical_receipt_image);
        }
        else holder.itemView.setVisibility(View.GONE);




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
