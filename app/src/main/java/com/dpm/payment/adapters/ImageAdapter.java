package com.dpm.payment.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.dpm.payment.utils.LogUtils;
import com.dpm.payment.R;
import com.squareup.picasso.Picasso;

import java.util.List;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

//TODO Create by Debabrata.
public class ImageAdapter extends RecyclerView.Adapter<ImageAdapter.MyViewHolder> {

    private List<String> listOfNav;


    public ImageAdapter(List<String> listOfNav) {
        this.listOfNav = listOfNav;

    }

    @Override
    public int getItemViewType(int position) {

        return position;
    }

    @NonNull
    @Override
    public MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.rowview_assessment_img, parent, false);
        return new MyViewHolder(itemView);
    }


    @Override
    public void onBindViewHolder(@NonNull final MyViewHolder holder, int position) {


        String imgPath = listOfNav.get(position);

        if (imgPath != null) {
            if (!imgPath.startsWith("http")) {
                imgPath = "https://dpm.sigmaventuressl.com/" + imgPath;
            }

            LogUtils.printf("I am img Adp: " + imgPath);

            Picasso.get().load(imgPath)
                    .placeholder(R.drawable.place_holder)
                    .error(R.drawable.place_holder)
                    .resize(150, 150)
                    .into(holder.imageView);


        }

    }

    @Override
    public int getItemCount() {


        return listOfNav == null ? 0 : listOfNav.size();
    }


    class MyViewHolder extends RecyclerView.ViewHolder {

        ImageView imageView;


        // view create //
        MyViewHolder(View view) {
            super(view);
            imageView = view.findViewById(R.id.imageView);


        }
    }
}