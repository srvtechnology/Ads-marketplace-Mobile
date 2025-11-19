package com.dpm.payment.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.models.MeterDetailsModel;
import com.dpm.payment.utils.LogUtils;
import com.dpm.payment.R;
import com.squareup.picasso.Picasso;

import java.util.List;

//TODO Create by Debabrata.
public class ImageTextAdapter extends RecyclerView.Adapter<ImageTextAdapter.MyViewHolder> {

    private List<MeterDetailsModel> listOfNav;


    public ImageTextAdapter(List<MeterDetailsModel> listOfNav) {
        this.listOfNav = listOfNav;

    }

    @Override
    public int getItemViewType(int position) {

        return position;
    }

    @NonNull
    @Override
    public MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.rowview_meter_img, parent, false);
        return new MyViewHolder(itemView);
    }


    @Override
    public void onBindViewHolder(@NonNull final MyViewHolder holder, int position) {

        MeterDetailsModel mMeterDetailsModel = listOfNav.get(position);


        try {
            if (mMeterDetailsModel.getSmall_preview() != null) {

                Picasso.get().load(mMeterDetailsModel.getSmall_preview())
                        .placeholder(R.drawable.place_holder)
                        .error(R.drawable.place_holder)
                        .into(holder.imageView);

            }
        }catch (Exception ex)
        {
            ex.printStackTrace();
        }

        try{
            holder.tvImageTitle.setText("Meter Image "+(position+1));
        }catch (Exception ex)
        {
            ex.printStackTrace();
        }

        try{
            String mMeterNumber = ((mMeterDetailsModel.getNumber() == null) ? "" : "" + mMeterDetailsModel.getNumber());
            holder.tvMeterImageNumber.setText(mMeterNumber);

        }catch (Exception ex)
        {
            ex.printStackTrace();
        }

    }

    @Override
    public int getItemCount() {

        return listOfNav == null ? 0 : listOfNav.size();
    }


    class MyViewHolder extends RecyclerView.ViewHolder {

        ImageView imageView;
        TextView tvImageTitle;
        TextView tvMeterImageNumber;

        // view create //
        MyViewHolder(View view) {
            super(view);
            imageView = view.findViewById(R.id.imageView);
            tvImageTitle=view.findViewById(R.id.tvImageTitle);
            tvMeterImageNumber=view.findViewById(R.id.tvMeterImageNumber);

        }
    }
}