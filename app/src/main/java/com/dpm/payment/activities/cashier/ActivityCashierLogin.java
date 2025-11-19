package com.dpm.payment.activities.cashier;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatSpinner;
import androidx.appcompat.widget.AppCompatTextView;

import com.dpm.payment.R;
import com.dpm.payment.activities.cep.ActivityCep;
import com.dpm.payment.activities.cep.AreaResponse;
import com.dpm.payment.activities.user.ActivityUserLogin;
import com.dpm.payment.activities.user.LandlordResponseModel;
import com.dpm.payment.activities.user.ListPropertyUserActivity;
import com.dpm.payment.models.cep.CepDistrictNameResponse;
import com.dpm.payment.models.cep.DistrictItem;
import com.dpm.payment.utils.AlertDialogUtils;
import com.dpm.payment.utils.CommonUtils;
import com.dpm.payment.utils.DataUtils;
import com.dpm.payment.utils.LogUtils;
import com.dpm.payment.utils.PrefUtil;
import com.dpm.payment.utils.RestApiRequestListener;
import com.dpm.payment.utils.RestApiUrl;
import com.dpm.payment.utils.StringUtils;
import com.google.android.material.textview.MaterialTextView;
import com.google.gson.Gson;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.dpm.payment.utils.CommonUtils.getHeader;
import static com.dpm.payment.utils.ConstantData.DISTRICT_NAME;
import static com.dpm.payment.utils.ConstantData.REQUEST_KEY_PASSWORD;
import static com.dpm.payment.utils.ConstantData.REQUEST_KEY_USERNAME;
import static com.dpm.payment.utils.ConstantData.TAG_REQUEST_DISTRICT_NAME;
import static com.dpm.payment.utils.ConstantData.TAG_REQUEST_LOGIN;


public class ActivityCashierLogin extends AppCompatActivity implements View.OnClickListener {

    private static final int LOCATION_REQ = 1010;
    String lat = "", lng = "";
    private Context mContext;
    ProgressDialog progressDialog;


    private EditText activityLogin_et_username;
    private EditText activityLogin_et_password;
    private Button activityLogin_bt_login;
    TextView tvCashier;
    Button btUserLogin;
    private AppCompatTextView btCheckIn;
    private Dialog dialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        mContext = ActivityCashierLogin.this;
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_cashier_login);
        initToolbar();
        initializeViews();
        initializeListener();

     /*   String ReciptUrl="https://dpm.sigmaventuressl.com/receipt/10171/3388";
        Intent mIntent = new Intent(mContext, WebViewPaymentRecipt.class);
        mIntent.putExtra(WebViewPaymentRecipt.KEY_PAYMENT_RECEIPT, ReciptUrl);
        startActivity(mIntent);*/

    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        CommonUtils.showLogoutDialog(this);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);


        if (requestCode == LOCATION_REQ) {

            if (resultCode == Activity.RESULT_OK) {
                assert data != null;
                String latLngJsonObj = data.getStringExtra("response");


                try {
                    if (latLngJsonObj != null) {
                        JSONObject jsonObject = new JSONObject(latLngJsonObj);

                        lat = jsonObject.optString("lat");
                        lng = jsonObject.optString("lng");

                        reqNormalLogin();
                    } else {
                        Toast.makeText(ActivityCashierLogin.this, "Location not found. Please Restart Your App.", Toast.LENGTH_SHORT).show();
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }

                // Toast.makeText(mContext, latLngJsonObj, Toast.LENGTH_SHORT).show();
                LogUtils.printf("I am in Line:" + latLngJsonObj);
            }


        }
    }
    private void initToolbar(){
        TextView tvTitle = findViewById(R.id.toolbar_tv_header);
        ImageView ivHome =findViewById(R.id.toolbar_iv_home);
        tvTitle.setText(getString(R.string.council_cashier_1));
        ivHome.setVisibility(View.GONE);
        AppCompatImageView ivProfile = findViewById(R.id.ivProfile);
        AppCompatImageView ivNotification = findViewById(R.id.ivNotification);
        ivProfile.setOnClickListener(v -> {
            showProfileOrNotification("profile",0);
        });
        ivNotification.setOnClickListener(v -> {
            showProfileOrNotification("notification",0);
        });
    }
    private void initializeViews() {
        activityLogin_et_username = findViewById(R.id.etEmail);
        activityLogin_et_password = findViewById(R.id.etPassword);
        activityLogin_bt_login = findViewById(R.id.btLogin);
        tvCashier =findViewById(R.id.tvCashier);
        btUserLogin=findViewById(R.id.btUserLogin);
        btCheckIn = findViewById(R.id.btCheckIn);

    }

    private void initializeListener() {
        activityLogin_bt_login.setOnClickListener(this);
        tvCashier.setOnClickListener(this);
        btUserLogin.setOnClickListener(this);
        btUserLogin.setVisibility(View.GONE);
        btCheckIn.setOnClickListener(this);
    }

    @SuppressLint("NonConstantResourceId")
    @Override
    public void onClick(View v) {
        Intent intent;
        switch (v.getId()) {
            case R.id.btUserLogin:

                try {
                    String response ="{\"success\":true,\"code\":200,\"token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImU0YjVmNmMyYzUwMTlhM2VjYjc5NGEwNjA0NmM1OTE4NmZkNDI1MTUzZWE0ODgyY2U4YTRjYWRkMjM2NjA5ZmMyYzQxZWZjZjY0MTRmNzdmIn0.eyJhdWQiOiIxIiwianRpIjoiZTRiNWY2YzJjNTAxOWEzZWNiNzk0YTA2MDQ2YzU5MTg2ZmQ0MjUxNTNlYTQ4ODJjZThhNGNhZGQyMzY2MDlmYzJjNDFlZmNmNjQxNGY3N2YiLCJpYXQiOjE1OTk1MDIzMDUsIm5iZiI6MTU5OTUwMjMwNSwiZXhwIjoxNTk5NTA1OTA1LCJzdWIiOiI0MCIsInNjb3BlcyI6W119.h3PtQ8V2jwPe02whRnjQyfl3x6svkqzcMISzN4v99PJGIm9rx6vwE-jXcov0WMDZsACGB8_3YPjairxfyKtMDYHaoInZPD1NLdxzuM-UvX9_6LucKPT1E4kj_7U0tzSUGkPWAiVvyQk2NshiQyPZZivT5FO0UXSNVYc3EMwd-PPV9aNS-0nK2BVXgrAQtuKzLaYMVZoFgH3eA6qbwEJkiHAYNi97Rd4hufLzvDdSy5M1RtHuW_ZMdvzt48hDaBb51cgWrR9-TaoDNG0NpqT1NFC008lnGbJqqFwnmvAcqUj9bT6dxMOuHB4prrVclucAkrfw15NzB_B_stj3Cj3vripPEY0_1xGd8FYqPnM53H-nmeoPFZsLilsdto3uPJKp1V3TPrOebMZT-andYYz0mKqEcfbfkm-sOraQkb_IIO9-XH4tKouSuHSeJKlEgy0p4WNVfbMbMNkqcBH-F7ktmS8HeLsrqvvotBp69vKIaVgPTsiCrf_Xi0bC1bY_bwHka1Z_5akpoETcQPbPwWf1_UkJDtELYI4zc3IK-GMIYUY20O8nJ7q2r4_QpwNZc6nyyBSiiNTDtOe0SfRh1bBlGtIZJaKKNU3O_WNNzu2_uiwtRZb7pVCUfVKCwtu3mAxFo8i8J7EHlYTGRlPfF_Rk8VBtOARyMaAYkaOyWfChKuc\",\"auth_type\":\"Bearer\",\"expire_at\":\"2020-09-07 19:11:45\",\"currency_rate\":{\"usd\":\"1\",\"le\":\"10000\"},\"currency_rate_pound\":{\"pound\":\"1\",\"le\":\"12000\"},\"online_charge\":\"5\",\"user\":{\"id\":40,\"mobile\":\"+919503595423\",\"code\":2592,\"is_active\":1,\"expired_at\":\"2020-09-07 18:26:45\",\"created_at\":\"2020-07-23 07:00:23\",\"updated_at\":\"2020-09-07 18:11:45\"}}";
                    parseUSERLogInResponse(response);

                }catch (Exception ex)
                {
                    ex.printStackTrace();
                }

                break;

            case R.id.tvCashier:
                // openHomePage();
                intent = new Intent(mContext, ActivityUserLogin.class);
                startActivity(intent);
               // finish();

                break;

            case R.id.btLogin:

                try {

                      //PrefUtil.mClearALLData(mContext);

                    if (checkLogInValidation()) {

                        if (DataUtils.isInternetConnectAvailable(mContext)) {
                            //     startActivityForResult(new Intent(ActivityLogin.this, PickUpLocationActivity.class), LOCATION_REQ);
                            reqNormalLogin();

                        } else {

                            AlertDialogUtils.showInternetConnNotAvailableDialog(ActivityCashierLogin.this);
                            // new CustomDialogWithOkayButton(mContext, mContext.getResources().getString(R.string.internet_connection_not_available), mContext.getResources().getString(R.string.OK), false).show();
                        }
                    }
                }catch (Exception ex)
                {
                    ex.printStackTrace();
                }
                break;
            case R.id.btCheckIn:
                reqArea();

                break;
        }
    }

    private void parseUSERLogInResponse(String response) {

        try {
            JSONObject jsonObject = new JSONObject(response);

            LogUtils.showErrorLog("Response ","Response "+jsonObject.toString());

            if (jsonObject.optBoolean("success")) {

                //Profile object save===========
                try {
                    JSONObject profileJsn = jsonObject.optJSONObject("user");

                     PrefUtil.saveLandlordProfile(mContext, response);
                    LandlordResponseModel mLandlordUserModel=PrefUtil.getLandlordProfile(mContext);
                    LogUtils.showErrorLog("Enter mLandlordUserModel  ", "Enter mLandlordUserModel  " + PrefUtil.getJsonFromObject(mLandlordUserModel, LandlordResponseModel.class));


                } catch (Exception e) {
                    e.printStackTrace();
                }

                startActivity(new Intent(this, ListPropertyUserActivity.class));

            } else {
                Toast.makeText(mContext, jsonObject.optString("message"), Toast.LENGTH_SHORT).show();
            }


        } catch (Exception e) {
            e.printStackTrace();
            Toast.makeText(mContext, ""+this.getResources().getString(R.string.error_occur), Toast.LENGTH_SHORT).show();
        }


    }


    private boolean checkLogInValidation() {

        boolean b;
        ArrayList<String> errorList = new ArrayList<>();

        if (getUserInputMail().length() == 0) {
            errorList.add("Enter your user name");
        }
       /* if (!AppData.isValidEmail(getUserInputMail())) {
            errorList.add("Enter an valid email id");
        }*/
        if (getUserInputPassword().length() == 0) {
            errorList.add("Enter your password");
        }
        if (getUserInputPassword().length() < 6) {
            errorList.add("Password at-least 6 characters needed");
        }

        if (errorList.size() > 0) {

            Toast.makeText(mContext, errorList.get(0), Toast.LENGTH_SHORT).show();
            b = false;
        } else {
            b = true;
        }

        return b;
    }

    private String getUserInputMail() {
        return activityLogin_et_username.getText().toString().trim();
    }

    private String getUserInputPassword() {
        return activityLogin_et_password.getText().toString().trim();
    }

    public void reqNormalLogin() {

        progressDialog = new ProgressDialog(mContext);

        HashMap<String, String> headers = new HashMap<>();
        headers.put("Accept", "application/json");

        Map<String, String> req_params = new HashMap<>();
        req_params.put(REQUEST_KEY_USERNAME, getUserInputMail());
        req_params.put(REQUEST_KEY_PASSWORD, getUserInputPassword());


        new RestApiRequestListener(this, TAG_REQUEST_LOGIN, RestApiUrl.URL_CASHIER_LOGIN, headers, req_params, new RestApiRequestListener.setOnRequestListener() {


            @Override
            public void onPreExecute() {
                progressDialog.setMessage(""+mContext.getResources().getString(R.string.signin));
                progressDialog.setCancelable(false);
                progressDialog.show();
            }

            @Override
            public void onSuccessListener(String response) {

                if (progressDialog != null) {
                    if (progressDialog.isShowing()) {
                        progressDialog.dismiss();
                    }
                }

                parseLogInResponse(response);

            }

            @Override
            public void onErrorListener(String errorMessage) {
                try {
                    if (progressDialog != null) {
                        if (progressDialog.isShowing()) {
                            progressDialog.dismiss();
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }

                LogUtils.showErrorLog("reqNormalLogin", errorMessage);

            }
        }).request();


    }

    private void parseLogInResponse(String response) {

        try {
            JSONObject jsonObject = new JSONObject(response);

            LogUtils.showErrorLog("Response ","Response "+jsonObject.toString());

            if (jsonObject.optBoolean("success")) {

                //Profile object save===========
                try {
                    JSONObject profileJsn = jsonObject.optJSONObject("user");

                    if (profileJsn != null) {

                        PrefUtil.saveProfile(mContext, response.trim());

                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }


                openHomePage();


            } else {
                Toast.makeText(mContext, jsonObject.optString("message"), Toast.LENGTH_SHORT).show();
            }


        } catch (Exception e) {
            e.printStackTrace();
            Toast.makeText(mContext, ""+ActivityCashierLogin.this.getResources().getString(R.string.error_occur), Toast.LENGTH_SHORT).show();
        }


    }

    private void openHomePage() {

        startActivity(new Intent(mContext, ActivityMainCashierProperty.class));


    }
    private void showCepInfoDialog(List<String> mList){
        dialog =  new Dialog(this);
        DisplayMetrics displayMetrics = new DisplayMetrics();
        dialog.getWindow().getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        int width = displayMetrics.widthPixels;
       // requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.dialog_cep_info);
        dialog.getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        dialog.getWindow().setLayout((int)(width/1.2), FrameLayout.LayoutParams.WRAP_CONTENT);
        dialog.setCancelable(false);

        MaterialTextView btnCancel = dialog.findViewById(R.id.btnCancel);
        MaterialTextView  btnContinue = dialog.findViewById(R.id.btnContinue);

        CheckBox chkboxSetDefault = dialog.findViewById(R.id.chkboxSetDefault);
        AutoCompleteTextView etSelectArea = dialog.findViewById(R.id.etSelectArea);
        AppCompatSpinner spnrDistrict = dialog.findViewById(R.id.spnrDistrict);
        ArrayAdapter<String> adapter = new ArrayAdapter<String>
                (this, R.layout.adapter_text_1, mList);
        etSelectArea.setThreshold(1);
        etSelectArea.setAdapter(adapter);
        etSelectArea.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if(s.toString().trim().isEmpty()){
                    if(mCepDistrictNameResponse.getResult()==null ||
                            mCepDistrictNameResponse.getResult().size()==0) {
                        reqDistrict();
                    }
                    return;
                }
                if(s.toString().length()>=3)
                runOnUiThread(() -> reqDistrictByArea(s.toString()));
            }
        });

        btnCancel.setOnClickListener(v -> dialog.dismiss());

        btnContinue.setOnClickListener(v -> {
            if(spnrDistrict.getSelectedItem().toString().equalsIgnoreCase("Select Council")){
                Toast.makeText(mContext, getString(R.string.please_select_council), Toast.LENGTH_SHORT).show();
                return;
            }
            if(chkboxSetDefault.isChecked()){
                PrefUtil.saveCouncilName(mContext,spnrDistrict.getSelectedItem().toString());
            }
            dialog.dismiss();
            int position = (spnrDistrict.getSelectedItemPosition()-1);
            showProfileOrNotification("cep",position);
        });

    }
    private void showProfileOrNotification(String type, int position){
        Intent mIntent = new Intent(mContext, ActivityCep.class);
        mIntent.putExtra("type",type);
        if(mCepDistrictNameResponse!=null) {
            DistrictItem mDistrictItem = mCepDistrictNameResponse.getResult().get(position);
            mIntent.putExtra(DISTRICT_NAME, mDistrictItem);
        }
        startActivity(mIntent);
    }

    public void reqDistrict() {
        new RestApiRequestListener(this, TAG_REQUEST_DISTRICT_NAME, RestApiUrl.URL_CEP_DISTRICT_DETAILS, getHeader(), null, new RestApiRequestListener.setOnRequestListener() {
            @Override
            public void onPreExecute() {
            }
            @Override
            public void onSuccessListener(String response) {
                parseResponse(response);
            }
            @Override
            public void onErrorListener(String errorMessage) {
            }
        }).getRequest();
    }
    private CepDistrictNameResponse mCepDistrictNameResponse;
    private void parseResponse(String response) {
         mCepDistrictNameResponse = new Gson().fromJson(response,CepDistrictNameResponse.class);
        List<String> mList = new ArrayList<>();
        mList.add("Select Council");
            if(mCepDistrictNameResponse.getResult().size()>0){
                for(int i=0; i<mCepDistrictNameResponse.getResult().size();i++){
                    mList.add(StringUtils.capitalizeEachWord(mCepDistrictNameResponse.getResult().get(i).getCouncilName()));
                }
                if(!dialog.isShowing()){
                    dialog.show();
                }
            }
        setSpinnerAdapter(mList);
    }

    private void setSpinnerAdapter(List<String> mList){
        AppCompatSpinner spnrDistrict = dialog.findViewById(R.id.spnrDistrict);
        ArrayAdapter aa = new ArrayAdapter(mContext,R.layout.adapter_text_1,mList);
        aa.setDropDownViewResource(R.layout.adapter_text_1);
        spnrDistrict.setAdapter(aa);
    }

    public void reqDistrictByArea(String searchStr) {
        Map<String, String> req_params = new HashMap<>();
        req_params.put("search", searchStr);
        progressDialog = new ProgressDialog(mContext);
        new RestApiRequestListener(this, TAG_REQUEST_DISTRICT_NAME,
                RestApiUrl.URL_CEP_SEARCH_DISTRICT, getHeader(),
                req_params, new RestApiRequestListener.setOnRequestListener() {
            @Override
            public void onPreExecute() {
            }
            @Override
            public void onSuccessListener(String response) {
                parseResponse(response);
            }
            @Override
            public void onErrorListener(String errorMessage) {

            }
        }).request();
    }

    public void reqArea() {
        new RestApiRequestListener(this, TAG_REQUEST_DISTRICT_NAME, RestApiUrl.URL_CEP_AREA, getHeader(), null, new RestApiRequestListener.setOnRequestListener() {
            @Override
            public void onPreExecute() {
            }
            @Override
            public void onSuccessListener(String response) {
                parseAreaResponse(response);
            }
            @Override
            public void onErrorListener(String errorMessage) {
            }
        }).getRequest();
    }
    private AreaResponse mAreaResponse;
    private void parseAreaResponse(String response) {
        mAreaResponse = new Gson().fromJson(response,AreaResponse.class);
        if(mAreaResponse.getResult()!=null && mAreaResponse.getResult().size()>0){
            showCepInfoDialog(mAreaResponse.getResult());
        }
        reqDistrict();
    }

}