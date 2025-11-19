package com.dpm.payment.activities.user;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RadioGroup;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatRadioButton;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.activities.cashier.ActivityCashierLogin;
import com.dpm.payment.activities.cep.ActivityCep;
import com.dpm.payment.activities.landlord.LandlordPropertyViewDetails;
import com.dpm.payment.R;

public class ActivityMainUser extends AppCompatActivity implements View.OnClickListener {

    Context mContext;
    AlertDialog dialog;
    View activityMain_view_search;
    Boolean isSearched = false;

    /*toolbar*/
    TextView toolbar_tv_header;
    /*toolbar*/

    EditText activityMain_et_propertyId, activityMain_et_noticeNo;
    Button activityMain_bt_search;


    TextView activityUserSearchResult_tv_name;
    Button activityUserSearchResult_bt_view_details;
    TextView  activityUserSearchResult_tv_assesment_year, activityUserSearchResult_tv_assesment_year_value,activityUserSearchResult_tv_rate_payable_value,activityUserSearchResult_tv_discount_applicable_value, activityUserSearchResult_tv_arrear, activityUserSearchResult_tv_arrear_value,
            activityUserSearchResult_tv_penalty, activityUserSearchResult_tv_penalty_value, activityUserSearchResult_tv_amount_paid, activityUserSearchResult_tv_amount_paid_value, activityUserSearchResult_tv_balance,
            activityUserSearchResult_tv_balance_value, activityUserSearchResult_tv_paying_amount, activityUserSearchResult_tv_paying_pre_calculate,activityUserSearchResult_tv_discount_rate_payable_value;
    EditText activityUserSearchResult_et_paying_amount;
    TextView activityUserSearchResult_tv_payment_type;
    RadioGroup activityUserSearchResult_rg_payment_type;
    AppCompatRadioButton activityUserSearchResult_rb_one, activityUserSearchResult_rb_two;

    TextView activityUserSearchResult_tv_total_amount, activityUserSearchResult_tv_total_pre_calculate;
    EditText activityUserSearchResult_et_total_amount;
    TextView activityUserSearchResult_tv_cheque_no;
    EditText activityUserSearchResult_et_cheque_no;
    TextView activityUserSearchResult_tv_payee_name;
    EditText activityUserSearchResult_et_payee_name;
    RecyclerView activityUserSearchResult_rv_dates;
    Button activityOrderDetails_bt_save;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        mContext = this;
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_cashier);

        initializeViews();
        initializeListeners();
        initToolbar();
        //    setDrawerProfile(PrefUtils.getProfile(mContext));
    }

   /* private void setDrawerProfile(UserProfileModel profile) {

        if (profile != null) {
            Picasso.get()
                    .load(profile.getUserProfileImagUrl())
                    .placeholder(R.drawable.ic_my_profile)
                    .error(R.drawable.ic_my_profile)
                    .into(menu_iv_profile);

        }

    }*/
   private void initToolbar(){
       ImageView ivHome =findViewById(R.id.toolbar_iv_home);
       ivHome.setVisibility(View.GONE);
       AppCompatImageView ivProfile = findViewById(R.id.ivProfile);
       AppCompatImageView ivNotification = findViewById(R.id.ivNotification);
       ivProfile.setOnClickListener(v -> {
           showProfileOrNotification("profile");
       });
       ivNotification.setOnClickListener(v -> {
           showProfileOrNotification("notification");
       });
   }

    private void initializeViews() {

        toolbar_tv_header = findViewById(R.id.toolbar_tv_header);
        toolbar_tv_header.setText(R.string.search_property);

        activityMain_et_propertyId = findViewById(R.id.activityMain_et_propertyId);
        activityMain_et_noticeNo = findViewById(R.id.activityMain_et_noticeNo);
        activityMain_bt_search = findViewById(R.id.activityMain_bt_search);

        activityMain_view_search = findViewById(R.id.activityMain_view_search);


        activityUserSearchResult_tv_discount_rate_payable_value = findViewById(R.id.activityUserSearchResult_tv_discount_rate_payable_value);
        activityUserSearchResult_tv_name = findViewById(R.id.activityUserSearchResult_tv_name);
        activityUserSearchResult_bt_view_details = findViewById(R.id.activityUserSearchResult_bt_view_details);
        activityUserSearchResult_tv_assesment_year = findViewById(R.id.activityUserSearchResult_tv_assesment_year);
        activityUserSearchResult_tv_assesment_year_value = findViewById(R.id.activityUserSearchResult_tv_assesment_year_value);
        activityUserSearchResult_tv_rate_payable_value = findViewById(R.id.activityUserSearchResult_tv_rate_payable_value);
        activityUserSearchResult_tv_discount_applicable_value = findViewById(R.id.activityUserSearchResult_tv_discount_applicable_value);

        activityUserSearchResult_tv_arrear = findViewById(R.id.activityUserSearchResult_tv_arrear);
        activityUserSearchResult_tv_arrear_value = findViewById(R.id.activityUserSearchResult_tv_arrear_value);
        activityUserSearchResult_tv_penalty = findViewById(R.id.activityUserSearchResult_tv_penalty);
        activityUserSearchResult_tv_penalty_value = findViewById(R.id.activityUserSearchResult_tv_penalty_value);
        activityUserSearchResult_tv_amount_paid = findViewById(R.id.activityUserSearchResult_tv_amount_paid);
        activityUserSearchResult_tv_amount_paid_value = findViewById(R.id.activityUserSearchResult_tv_amount_paid_value);
        activityUserSearchResult_tv_balance = findViewById(R.id.activityUserSearchResult_tv_balance);
        activityUserSearchResult_tv_balance_value = findViewById(R.id.activityUserSearchResult_tv_balance_value);
        activityUserSearchResult_tv_paying_amount = findViewById(R.id.activityUserSearchResult_tv_paying_amount);
        activityUserSearchResult_tv_paying_pre_calculate = findViewById(R.id.activityUserSearchResult_tv_paying_pre_calculate);
        activityUserSearchResult_et_paying_amount = findViewById(R.id.activityUserSearchResult_et_paying_amount);
        activityUserSearchResult_tv_payment_type = findViewById(R.id.activityUserSearchResult_tv_payment_type);
        activityUserSearchResult_rg_payment_type = findViewById(R.id.activityUserSearchResult_rg_payment_type);
        activityUserSearchResult_rb_one = findViewById(R.id.activityUserSearchResult_rb_one);
        activityUserSearchResult_rb_two = findViewById(R.id.activityUserSearchResult_rb_two);
        activityUserSearchResult_tv_total_amount = findViewById(R.id.activityUserSearchResult_tv_total_amount);
        activityUserSearchResult_tv_total_pre_calculate = findViewById(R.id.activityUserSearchResult_tv_total_pre_calculate);
        activityUserSearchResult_et_total_amount = findViewById(R.id.activityUserSearchResult_et_total_amount);
        activityUserSearchResult_tv_cheque_no = findViewById(R.id.activityUserSearchResult_tv_cheque_no);
        activityUserSearchResult_et_cheque_no = findViewById(R.id.activityUserSearchResult_et_cheque_no);
        activityUserSearchResult_tv_payee_name = findViewById(R.id.activityUserSearchResult_tv_payee_name);
        activityUserSearchResult_et_payee_name = findViewById(R.id.activityUserSearchResult_et_payee_name);
        activityUserSearchResult_rv_dates = findViewById(R.id.activityUserSearchResult_rv_dates);
        activityOrderDetails_bt_save = findViewById(R.id.activityOrderDetails_bt_save);
    }

    private void initializeListeners() {
        activityMain_bt_search.setOnClickListener(this);
        activityUserSearchResult_bt_view_details.setOnClickListener(this);
    }


    @Override
    public void onBackPressed() {

        super.onBackPressed();
    }


    private void showLogoutAlert() {
        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);

        // Set a title for alert dialog
        builder.setTitle("Logout?");

        // Ask the final question
        builder.setMessage("Are you sure you want to logout?");

        // Set the alert dialog yes button click listener
        builder.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                // Do something when user clicked the Yes button
                // Set the TextView visibility GONE
                Intent in = new Intent(mContext, ActivityCashierLogin.class);
                startActivity(in);
                finish();
            }
        });

        // Set the alert dialog no button click listener
        builder.setNegativeButton("No", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                // Do something when No button clicked
                if (dialog != null) {
                    dialog.dismiss();
                }
            }
        });

        dialog = builder.create();
        // Display the alert dialog on interface
        dialog.show();
    }

    @Override
    public void onClick(View v) {
        Intent intent = null;
        switch (v.getId()) {
            case R.id.activityMain_bt_search:
                if (!isSearched) {
                    activityMain_view_search.setVisibility(View.VISIBLE);
                } else {
                    //  isSearched
                }
                break;
            case R.id.activityUserSearchResult_bt_view_details:
                intent = new Intent(mContext, LandlordPropertyViewDetails.class);
                break;
        }
        if (intent != null) {
            startActivity(intent);
        }
    }
    private void showProfileOrNotification(String type){
        Intent mIntent = new Intent(mContext, ActivityCep.class);
        mIntent.putExtra("type",type);
        startActivity(mIntent);
    }
}
