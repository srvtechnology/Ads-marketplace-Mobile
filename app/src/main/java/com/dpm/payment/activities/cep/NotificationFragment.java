package com.dpm.payment.activities.cep;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.adapters.NotificationAdapter;
import com.dpm.payment.R;

public class NotificationFragment extends Fragment {
    private RecyclerView rvCep;
    private Context mContext;

    public static NotificationFragment newInstance() {
        return new NotificationFragment();
    }
    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext = context;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_emergency_service, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView(view);
        initToolbar(view);

    }

    @SuppressLint("SetTextI18n")
    private void initToolbar(View view){
        AppCompatTextView tvTitle = view.findViewById(R.id.toolbar_tv_header);
        ImageView ivHome = view.findViewById(R.id.toolbar_iv_home);
        AppCompatImageView ivProfile = view.findViewById(R.id.ivProfile);
        AppCompatImageView ivNotification = view.findViewById(R.id.ivNotification);
        ivNotification.setVisibility(View.GONE);
        ivProfile.setVisibility(View.GONE);
        tvTitle.setText("Notifications");
        ivHome.setOnClickListener(v -> {
           ((ActivityCep)requireActivity()).onBackPressed();
        });
    }


    private void initView(View view) {
        rvCep = view.findViewById(R.id.rvCep);
        setData();
    }

    private void setData() {
        setAdapter();
    }

    private void setAdapter(){
        NotificationAdapter adapter = new NotificationAdapter(mContext,  (view, position) -> {

        });
        LinearLayoutManager layoutManager=new LinearLayoutManager(requireActivity());
        rvCep.setLayoutManager(layoutManager);
        rvCep.setAdapter(adapter);
    }

}
