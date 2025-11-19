package com.dpm.payment.activities.user;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatImageView;

import com.dpm.payment.activities.cep.ActivityCep;
import com.dpm.payment.utils.PrefUtil;
import com.dpm.payment.R;

public class PaymentOptionUserActivity extends AppCompatActivity {

    ImageView ivPayPal, ivBank, ivMobileMoney;
    Context mContext;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_payment_option_user);
        mContext = this;
        setUI();
        setOnclick();
        initToolbar();
    }

    private void initToolbar(){
        TextView tvHeader = findViewById(R.id.toolbar_tv_header);
        tvHeader.setText(R.string.payment_option_list);
        ImageView ivHome =findViewById(R.id.toolbar_iv_home);
        AppCompatImageView ivProfile = findViewById(R.id.ivProfile);
        AppCompatImageView ivNotification = findViewById(R.id.ivNotification);
        ivHome.setOnClickListener(v -> {
            onBackPressed();
        });
        ivProfile.setOnClickListener(v -> {
            showProfileOrNotification("profile");
        });
        ivNotification.setOnClickListener(v -> {
            showProfileOrNotification("notification");
        });
    }

    private void setOnclick() {
        ivPayPal.setOnClickListener(view -> CallWebView());
        ivBank.setOnClickListener(view -> startActivity(new Intent(PaymentOptionUserActivity.this, BankListActivity.class)));
        ivMobileMoney.setOnClickListener(view -> startActivity(new Intent(PaymentOptionUserActivity.this, MobileWalletActivity.class)));
    }

    private void CallWebView() {
        try {
                   /* String url = RestApiUrl.URL_LANDLORD_PAYMENT + "property_id=" + searchResponseModel.getId() + "&amount=" + activityUserSearchResult_tvtext_total_amount.getText().toString().trim().split(" ")[0] + "&mobile_number=" + URLEncoder.encode(mLandlordUserModel.getUser().getMobile(), "UTF-8")+"&payee_name="+activityUserSearchResult_et_payee1.getText().toString().trim();
                    Intent mIntent = new Intent(mContext, WebViewPaymentActivity.class);
                    mIntent.putExtra(WebViewPaymentActivity.KEY_PAYMENT_URL, url);
                    startActivity(mIntent);*/

            String url = PrefUtil.getPaymentUrl(mContext);

            Intent mIntent = new Intent(mContext, WebViewPaymentActivity.class);
            mIntent.putExtra(WebViewPaymentActivity.KEY_PAYMENT_URL, url);
            startActivity(mIntent);


        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private void setUI() {
        ivPayPal = findViewById(R.id.ivPayPal);
        ivBank = findViewById(R.id.ivBank);
        ivMobileMoney = findViewById(R.id.ivMobileMoney);
    }

    private void showProfileOrNotification(String type){
        Intent mIntent = new Intent(mContext, ActivityCep.class);
        mIntent.putExtra("type",type);
        startActivity(mIntent);
    }

}
