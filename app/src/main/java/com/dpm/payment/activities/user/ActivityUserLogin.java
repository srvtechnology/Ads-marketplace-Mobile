package com.dpm.payment.activities.user;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatSpinner;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.core.app.ActivityCompat;

import com.dpm.payment.activities.cashier.ActivityCashierLogin;
import com.dpm.payment.activities.cep.ActivityCep;
import com.dpm.payment.activities.cep.AreaResponse;
import com.dpm.payment.activities.cep.NotificationFragment;
import com.dpm.payment.activities.cep.ProfileFragment;
import com.dpm.payment.activities.login.ActivityLogin;
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
import com.hbb20.CountryCodePicker;
import com.dpm.payment.R;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.dpm.payment.utils.CommonUtils.getHeader;
import static com.dpm.payment.utils.ConstantData.DISTRICT_NAME;
import static com.dpm.payment.utils.ConstantData.TAG_REQUEST_DISTRICT_NAME;
import static com.dpm.payment.utils.ConstantData.TAG_REQUEST_LOGIN;


public class ActivityUserLogin extends AppCompatActivity implements View.OnClickListener {

    private Context mContext;


    private EditText etPhone;
    private CountryCodePicker etISDPhone;
    private AppCompatTextView btSendOTP;
    private TextView tvCashier;
    private AppCompatTextView btCheckIn;
    private Dialog dialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        mContext = this;
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_login);


        check_permissions();
        initToolbar();
        initializeViews();
        initializeListener();

    }

    @Override
    public void onBackPressed() {
        CommonUtils.showLogoutDialog(this);
    }

    @SuppressLint("SetTextI18n")
    private void initToolbar(){
        TextView tvTitle = findViewById(R.id.toolbar_tv_header);
        ImageView ivHome =findViewById(R.id.toolbar_iv_home);
        tvTitle.setText(getString(R.string.landlord_property_owner_sign_in));
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

    public boolean check_permissions() {

        String[] PERMISSIONS = {
                Manifest.permission.RECEIVE_SMS,
                Manifest.permission.READ_SMS
        };

        if (!hasPermissions(getApplicationContext(), PERMISSIONS)) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                requestPermissions(PERMISSIONS, 2);
            }
        }else {

            return true;
        }

        return false;
    }

    private void initializeListener() {
        btSendOTP.setOnClickListener(this);
        tvCashier.setOnClickListener(this);
        btCheckIn.setOnClickListener(this);
    }


    private void initializeViews() {


        tvCashier = findViewById(R.id.tvCashier);
        etPhone = findViewById(R.id.etPhone);
        btSendOTP = findViewById(R.id.btSendOTP);



        etISDPhone = findViewById(R.id.ccp);
        btCheckIn = findViewById(R.id.btCheckIn);
        etPhone.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }
            @Override
            public void afterTextChanged(Editable s) {
                if (s.toString().length() == 1 && (s.toString().startsWith("0") || s.toString().startsWith(" "))) {
                    s.clear();
                }
            }
        });
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.toolbar_iv_home:
                onBackPressed();
                break;

            case R.id.btSendOTP:

             // startActivity(new Intent(this,ActivityUserOTP.class));
               try {

                    //PrefUtil.mClearALLData(mContext);

                    if (checkLogInValidation()) {

                        if (DataUtils.isInternetConnectAvailable(mContext)) {
                            reqNormalLogin();
                        } else {
                            AlertDialogUtils.showInternetConnNotAvailableDialog(ActivityUserLogin.this);
                        }
                    }
                }catch (Exception ex)
                {
                    ex.printStackTrace();
                }


                break;
            case R.id.activityOtp_btVerify:
               // content_otp.setVisibility(View.VISIBLE);
                break;
            case R.id.tvCashier:
                Intent intent2 = new Intent(mContext, ActivityCashierLogin.class);
                startActivity(intent2);
                finish();
                break;
            case R.id.btCheckIn:
                reqArea();
                break;
        }
    }

    ProgressDialog progressDialog;
    public void reqNormalLogin() {

        progressDialog = new ProgressDialog(mContext);

        HashMap<String, String> headers = new HashMap<>();
        headers.put("Accept", "application/json");

        Map<String, String> req_params = new HashMap<>();

        req_params.put("mobile_number", "+"+etISDPhone.getSelectedCountryCode().trim()+""+etPhone.getText().toString().trim());


        new RestApiRequestListener(this, TAG_REQUEST_LOGIN, RestApiUrl.URL_LANDLORD_LOGIN, headers, req_params, new RestApiRequestListener.setOnRequestListener() {


            @Override
            public void onPreExecute() {
                progressDialog.setMessage("Signing In ...");
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

                        Toast.makeText(mContext, profileJsn.optString("code"), Toast.LENGTH_LONG).show();


                        PrefUtil.saveLandlordProfile(mContext, response);

                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }

                   startActivity(new Intent(ActivityUserLogin.this,ActivityUserOTP.class).putExtra("data",response));

            } else {
                Toast.makeText(mContext, jsonObject.optString("message"), Toast.LENGTH_SHORT).show();
            }


        } catch (Exception e) {
            e.printStackTrace();
            Toast.makeText(mContext, ""+ActivityUserLogin.this.getResources().getString(R.string.error_occur), Toast.LENGTH_SHORT).show();
        }


    }


    private boolean checkLogInValidation() {

        boolean b;
        ArrayList<String> errorList = new ArrayList<>();

        if (etPhone.getText().toString().trim().length() == 0) {
            errorList.add("Enter registered number.");
        }
        if (errorList.size() > 0) {
            Toast.makeText(mContext, errorList.get(0), Toast.LENGTH_SHORT).show();
            b = false;
        } else {
            b = true;
        }

        return b;
    }

    public static boolean hasPermissions(Context context, String... permissions) {
        if (context != null && permissions != null) {
            for (String permission : permissions) {
                if (ActivityCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                    return false;
                }
            }
        }
        return true;
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
