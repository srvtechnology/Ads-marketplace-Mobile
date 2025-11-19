package com.dpm.payment.activities.user;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.ImageView;

import com.dpm.payment.R;

public class MobileWalletActivity extends AppCompatActivity {

    ImageView ivBack;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mobile_wallet);
        setUI();
        setOnClick();
    }

    private void setOnClick() {
        ivBack.setOnClickListener(view -> finish());
    }


    private void setUI() {
        ivBack=findViewById(R.id.ivBack);
    }
}
