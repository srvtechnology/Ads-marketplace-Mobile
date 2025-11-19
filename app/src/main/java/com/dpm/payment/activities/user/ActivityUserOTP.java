package com.dpm.payment.activities.user;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatImageView;

import com.dpm.payment.activities.cep.ActivityCep;
import com.dpm.payment.utils.AlertDialogUtils;
import com.dpm.payment.utils.Constant;
import com.dpm.payment.utils.DataUtils;
import com.dpm.payment.utils.LogUtils;
import com.dpm.payment.utils.PrefUtil;
import com.dpm.payment.utils.RestApiRequestListener;
import com.dpm.payment.utils.RestApiUrl;
import com.google.gson.JsonObject;
import com.dpm.payment.R;
import com.stfalcon.smsverifycatcher.OnSmsCatchListener;
import com.stfalcon.smsverifycatcher.SmsVerifyCatcher;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static com.dpm.payment.utils.ConstantData.TAG_PHONE_NUMBER_VERIFY;
import static com.dpm.payment.utils.ConstantData.TAG_REQUEST_LOGIN;
import static com.dpm.payment.utils.PrefUtil.getLandlordProfileString;
import static com.dpm.payment.utils.RestApiUrl.URL_LANDLORD_OTP_VERIFY;

public class ActivityUserOTP extends AppCompatActivity {

    final int OTPSendTime = 120;
    Button btVerify;
    Context mContext;
    EditText et1Box;
    EditText et2Box;
    EditText et3Box;
    EditText et4Box;
    LandlordResponseModel mLandlordUserModel;
    ProgressDialog progressDialog;
    TextView tvTimer;
    TextView tvResend;
    boolean mTimerState = false;
    ProgressDialog progressDialog1;
    private SmsVerifyCatcher smsVerifyCatcher;
    TextView tvReadMessage;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_otp);
        mContext = this;
        setInit();
        setUI();
        onClick();
        reverseTimer(OTPSendTime);
        initToolbar();

        //  String dataSMS = "Your otp for the login is 7832. This code will expire at 12:43:09PM";
        // String OTP= parseCode(dataSMS);
        // Toast.makeText(ActivityUserOTP.this,"OTP "+OTP,Toast.LENGTH_LONG).show();

        SMSRead();
    }
    private void initToolbar(){
        TextView tvTitle = findViewById(R.id.toolbar_tv_header);
        ImageView ivHome =findViewById(R.id.toolbar_iv_home);
        tvTitle.setText(getString(R.string.one_time_password));
        ivHome.setOnClickListener(v->{
            onBackPressed();
        });
        AppCompatImageView ivProfile = findViewById(R.id.ivProfile);
        AppCompatImageView ivNotification = findViewById(R.id.ivNotification);
        ivProfile.setOnClickListener(v -> {
            showProfileOrNotification("profile");
        });
        ivNotification.setOnClickListener(v -> {
            showProfileOrNotification("notification");
        });
    }

    private void SMSRead() {
        smsVerifyCatcher = new SmsVerifyCatcher(this, new OnSmsCatchListener<String>() {
            @Override
            public void onSmsCatch(String message) {
                String code = parseCode(message);//Parse verification code
                //etCode.setText(code);//set code in edit text
                //then you can send verification code to server
                LogUtils.showErrorLog("SMS READ message ", "SMS Read message : " + message);
                LogUtils.showErrorLog("SMS READ code ", "SMS Read code : " + code);
                //  Toast.makeText(mContext,"status  SMS code "+code,Toast.LENGTH_LONG).show();
                //  tvReadMessage.setText("Code : "+code+ "   message : "+message);
                setParseOTPandSet(code);
                mVerifyCode();
            }
        });
        //  smsVerifyCatcher.setPhoneNumberFilter("777");
        //smsVerifyCatcher.setFilter("<regexp>");
    }

    private String parseCode(String message) {
        // int number_digit=6;

        Pattern p = Pattern.compile("(\\d{4})");
        Matcher m = p.matcher(message);
        String code = "";
        while (m.find()) {
            code = m.group(0);
        }
        return code;
    }

    @Override
    protected void onStart() {
        super.onStart();
        smsVerifyCatcher.onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();
        smsVerifyCatcher.onStop();
    }

    private void setInit() {
        mLandlordUserModel = PrefUtil.getLandlordProfile(mContext);

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        smsVerifyCatcher.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    private void setParseOTPandSet(String mCodeStr) {
        try {
            //  mLandlordUserModel = PrefUtil.getLandlordProfile(mContext);
            //String mCodeStr = mLandlordUserModel.getUser().getCode();
            String st1, st2, st3, st4;

            if (mCodeStr.length() == 4) {

                st1 = "" + mCodeStr.substring(0);
                st2 = mCodeStr.substring(1);
                st3 = mCodeStr.substring(2);
                st4 = mCodeStr.substring(3);
                LogUtils.showErrorLog("st1 ", "st1 " + st1);
                LogUtils.showErrorLog("st2 ", "st2 " + st2);
                LogUtils.showErrorLog("st3 ", "st3 " + st3);
                LogUtils.showErrorLog("st4 ", "st4 " + st4);
                et1Box.setText("" + st1);
                et2Box.setText("" + st2);
                et3Box.setText("" + st3);
                et4Box.setText("" + st4);

            } else {
                LogUtils.showErrorLog("mCodeStr code length ", " code length " + mCodeStr);
            }


        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private void setOTPFromPref() {
        try {
            mLandlordUserModel = PrefUtil.getLandlordProfile(mContext);
            String mCodeStr = mLandlordUserModel.getUser().getCode();
            String st1, st2, st3, st4;

            if (mCodeStr.length() == 4) {

                st1 = "" + mCodeStr.substring(0);
                st2 = mCodeStr.substring(1);
                st3 = mCodeStr.substring(2);
                st4 = mCodeStr.substring(3);
                LogUtils.showErrorLog("st1 ", "st1 " + st1);
                LogUtils.showErrorLog("st2 ", "st2 " + st2);
                LogUtils.showErrorLog("st3 ", "st3 " + st3);
                LogUtils.showErrorLog("st4 ", "st4 " + st4);
                et1Box.setText("" + st1);
                et2Box.setText("" + st2);
                et3Box.setText("" + st3);
                et4Box.setText("" + st4);

            } else {
                LogUtils.showErrorLog("mCodeStr code length ", " code length " + mCodeStr);
            }


        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private void setUI() {
        btVerify = findViewById(R.id.btVerify);
        et1Box = findViewById(R.id.et1Box);
        et2Box = findViewById(R.id.et2Box);
        et3Box = findViewById(R.id.et3Box);
        et4Box = findViewById(R.id.et4Box);
        tvTimer = findViewById(R.id.tvTimer);
        tvResend = findViewById(R.id.tvResend);
        tvReadMessage = findViewById(R.id.tvReadMessage);
    }

    private void onClick() {
        btVerify.setOnClickListener(view -> {
            mVerifyCode();

        });
        tvResend.setOnClickListener(view -> {
            ResendOTPByMobileNumber();
        });

        et1Box.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
            }

            @Override
            public void afterTextChanged(Editable editable) {
                if (editable.length() == 1) {
                    et2Box.requestFocus();
                }
            }
        });

        et2Box.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
            }

            @Override
            public void afterTextChanged(Editable editable) {
                if (editable.length() == 1) {
                    et3Box.requestFocus();
                }
            }
        });
        et3Box.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                if (editable.length() == 1) {
                    et4Box.requestFocus();
                }
            }
        });


    }

    private void mVerifyCode() {
        try {
            if (checkValidation()) {
                LogUtils.showErrorLog("Line1", "Line1");
                if (DataUtils.isInternetConnectAvailable(mContext)) {
                    reqVerifyMobileNumber();
                    LogUtils.showErrorLog("Line2", "Line2");
                } else {
                    AlertDialogUtils.showInternetConnNotAvailableDialog(mContext);
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private void ResendOTPByMobileNumber() {
        try {
            LogUtils.showErrorLog("ResendOTPByMobileNumber ", " ResendOTPByMobileNumber 0");
            if (DataUtils.isInternetConnectAvailable(mContext)) {
                LogUtils.showErrorLog("ResendOTPByMobileNumber ", " ResendOTPByMobileNumber 1");
                String mLoginDetails = getLandlordProfileString(mContext);
                JSONObject mProfile = new JSONObject(mLoginDetails);
                reqResendOTP(mProfile.getJSONObject("user").optString("mobile"));
            } else {
                AlertDialogUtils.showInternetConnNotAvailableDialog(mContext);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void reqResendOTP(String mMobileNumber) {

        progressDialog1 = new ProgressDialog(mContext);
        LogUtils.showErrorLog("ResendOTPByMobileNumber ", " ResendOTPByMobileNumber 2");
        LogUtils.showErrorLog("ResendOTPByMobileNumber ", " mMobileNumber " + mMobileNumber);

        HashMap<String, String> headers = new HashMap<>();
        headers.put("Accept", "application/json");
        Map<String, String> req_params = new HashMap<>();
        req_params.put("mobile_number", mMobileNumber);
        LogUtils.showErrorLog("ResendOTPByMobileNumber ", " ResendOTPByMobileNumber req_params " + req_params);

        new RestApiRequestListener(this, TAG_REQUEST_LOGIN, RestApiUrl.URL_LANDLORD_LOGIN, headers, req_params, new RestApiRequestListener.setOnRequestListener() {


            @Override
            public void onPreExecute() {
                progressDialog1.setMessage("Resend OTP...");
                progressDialog1.setCancelable(false);
                progressDialog1.show();
            }

            @Override
            public void onSuccessListener(String response) {

                if (progressDialog1 != null) {
                    if (progressDialog1.isShowing()) {
                        progressDialog1.dismiss();
                    }
                }

                parseLogInResponse(response);
            }

            @Override
            public void onErrorListener(String errorMessage) {
                try {
                    if (progressDialog1 != null) {
                        if (progressDialog1.isShowing()) {
                            progressDialog1.dismiss();
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

            LogUtils.showErrorLog("Response ", "Response " + jsonObject.toString());

            if (jsonObject.optBoolean("success")) {

                Toast.makeText(mContext, "OTP send successfully.", Toast.LENGTH_SHORT).show();
                //Profile object save===========
                try {
                    JSONObject profileJsn = jsonObject.optJSONObject("user");

                    if (profileJsn != null) {

                        PrefUtil.saveLandlordProfile(mContext, response);

                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                reverseTimer(OTPSendTime);


            } else {
                Toast.makeText(mContext, jsonObject.optString("message"), Toast.LENGTH_SHORT).show();
            }


        } catch (Exception e) {
            e.printStackTrace();
            Toast.makeText(mContext, "" + mContext.getResources().getString(R.string.error_occur), Toast.LENGTH_SHORT).show();
        }


    }

    private boolean checkValidation() {

        boolean b;
        ArrayList<String> errorList = new ArrayList<>();

        if (et1Box.getText().toString().trim().length() == 0 &&
                et2Box.getText().toString().trim().length() == 0 &&
                et3Box.getText().toString().trim().length() == 0 &&
                et4Box.getText().toString().trim().length() == 0) {
            errorList.add("" + getString(R.string.enter_your_otp));
        }


        if (errorList.size() > 0) {
            Toast.makeText(mContext, errorList.get(0), Toast.LENGTH_SHORT).show();
            b = false;
        } else {
            b = true;
        }

        return b;
    }

    private void reqVerifyMobileNumber() {

        progressDialog = new ProgressDialog(mContext);

        HashMap<String, String> headers = new HashMap<>();
        headers.put("Accept", "application/json");
        headers.put("Authorization", mLandlordUserModel.getAuth_type() + " " + mLandlordUserModel.getToken());

        Map<String, String> req_params = new HashMap<>();

        String str1 = et1Box.getText().toString().trim();
        String str2 = et2Box.getText().toString().trim();
        String str3 = et3Box.getText().toString().trim();
        String str4 = et4Box.getText().toString().trim();

        req_params.put("code", str1 + str2 + str3 + str4);

        LogUtils.showErrorLog("header", headers.toString());
        LogUtils.showErrorLog("header", req_params.toString());

        new RestApiRequestListener(this, TAG_PHONE_NUMBER_VERIFY, URL_LANDLORD_OTP_VERIFY, headers, req_params, new RestApiRequestListener.setOnRequestListener() {


            @Override
            public void onPreExecute() {
                progressDialog.setMessage("Verifying...");
                progressDialog.setCancelable(false);
                progressDialog.show();
            }

            @Override
            public void onSuccessListener(String response) {

                if (progressDialog != null) {
                    if (progressDialog.isShowing()) {
                        progressDialog.dismiss();

                        try {

                            JSONObject mJsonResponse = new JSONObject(response);
                            if (mJsonResponse.optBoolean("success")) {

                                JSONObject data_previous_activity = new JSONObject(getIntent().getStringExtra("data"));

                                Constant.TOKEN = "Bearer " + data_previous_activity.getString("token");


                                Toast.makeText(mContext, "" + mJsonResponse.optString("message"), Toast.LENGTH_LONG).show();
                                Intent mIntent = new Intent(ActivityUserOTP.this, ListPropertyUserActivity.class);
                                mIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                                startActivity(mIntent);
                                finish();

                            } else {

                                Toast.makeText(mContext, "" + mJsonResponse.optString("message"), Toast.LENGTH_LONG).show();
                            }


                        } catch (Exception ex) {
                            ex.printStackTrace();
                            Toast.makeText(mContext, "Property not found.", Toast.LENGTH_LONG).show();
                        }
                    }
                }

            }


            @Override
            public void onErrorListener(String errorMessage) {
                try {
                    if (progressDialog != null) {
                        if (progressDialog.isShowing()) {
                            progressDialog.dismiss();
                        }
                    }

                    LogUtils.showErrorLog("reqNormalLogin", errorMessage);
                } catch (Exception e) {
                    e.printStackTrace();
                }


            }
        }).request();

    }

    public void reverseTimer(int Seconds) {

        new CountDownTimer(Seconds * 1000 + 1000, 1000) {

            public void onTick(long millisUntilFinished) {
                int seconds = (int) (millisUntilFinished / 1000);

                int hours = seconds / (60 * 60);
                int tempMint = (seconds - (hours * 60 * 60));
                int minutes = tempMint / 60;
                seconds = tempMint - (minutes * 60);

                tvTimer.setText(String.format("%02d", minutes) + ":" + String.format("%02d", seconds));
                mTimerState = true;


            }

            public void onFinish() {

                tvTimer.setText("0:00");
                mTimerState = false;

            }
        }.start();
    }
    private void showProfileOrNotification(String type){
        Intent mIntent = new Intent(mContext, ActivityCep.class);
        mIntent.putExtra("type",type);
        startActivity(mIntent);
    }

}
