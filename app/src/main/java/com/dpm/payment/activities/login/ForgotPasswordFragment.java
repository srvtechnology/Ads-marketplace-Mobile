package com.dpm.payment.activities.login;

import android.content.Context;
import android.content.Intent;
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

import com.dpm.payment.activities.user.ActivityUserLogin;
import com.dpm.payment.R;

public class ForgotPasswordFragment extends Fragment implements View.OnClickListener {
    private AppCompatTextView tvSend;
    private Context mContext;
    public static ForgotPasswordFragment newInstance(){
        return new ForgotPasswordFragment();
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext=context;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_forgot_password,container,false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initToolbar(view);
        initView(view);
    }


    private void initView(View view) {
        tvSend = view.findViewById(R.id.tvSend);
        tvSend.setOnClickListener(this);
    }

    private void initToolbar(View view) {
        AppCompatTextView tvTitle = view.findViewById(R.id.toolbar_tv_header);
        ImageView ivHome = view.findViewById(R.id.toolbar_iv_home);
        tvTitle.setText("Forgot Password");
        AppCompatImageView ivProfile = view.findViewById(R.id.ivProfile);
        AppCompatImageView ivNotification = view.findViewById(R.id.ivNotification);
        ivHome.setOnClickListener(v -> {
            ((ActivityLogin) requireActivity()).onBackPressed();
        });
        ivProfile.setVisibility(View.GONE);
        ivNotification.setVisibility(View.GONE);
    }
    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.tvSend:
                ((ActivityLogin) requireActivity()).onBackPressed();
                break;
        }
    }

    private void startUserLogin(){
        Intent mIntent = new Intent(mContext, ActivityUserLogin.class);
        startActivity(mIntent);
        ((ActivityLogin) requireActivity()).finish();
    }
}
