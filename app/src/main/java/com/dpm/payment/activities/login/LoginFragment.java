package com.dpm.payment.activities.login;

import static com.dpm.payment.utils.ConstantData.GUEST_USER_NAME;
import static com.dpm.payment.utils.ConstantData.GUEST_USER_PASSWORD;
import static com.dpm.payment.utils.ConstantData.REQUEST_KEY_PASSWORD;
import static com.dpm.payment.utils.ConstantData.REQUEST_KEY_USERNAME;
import static com.dpm.payment.utils.ConstantData.TAG_REQUEST_LOGIN;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.method.HideReturnsTransformationMethod;
import android.text.method.PasswordTransformationMethod;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.fragment.app.Fragment;
import com.dpm.payment.activities.user.ActivityUserLogin;
import com.dpm.payment.models.cep.GuestUserResponse;
import com.dpm.payment.utils.CommonUtils;
import com.dpm.payment.utils.LogUtils;
import com.dpm.payment.utils.PrefUtil;
import com.dpm.payment.utils.RestApiRequestListener;
import com.dpm.payment.utils.RestApiUrl;
import com.google.gson.Gson;
import com.dpm.payment.R;

import java.util.HashMap;
import java.util.Map;

public class LoginFragment extends Fragment implements View.OnClickListener {
    private TextView btLogin,tvLogin,tvForgotPassword;
    private EditText etUserName,etPassword;
    private AppCompatImageView ivPassword;
    private CheckBox chkboxRememberMe;
    private Context mContext;
    public static LoginFragment newInstance(){
        return new LoginFragment();
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext=context;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_login,container,false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView(view);
    }



    private void initView(View view) {
        btLogin = view.findViewById(R.id.btLogin);
        tvLogin = view.findViewById(R.id.tvLogin);
        etUserName = view.findViewById(R.id.etUserName);
        etPassword = view.findViewById(R.id.etPassword);
        ivPassword = view.findViewById(R.id.ivPassword);
        ivPassword.setImageResource(R.drawable.icon_hide_password);
        tvForgotPassword = view.findViewById(R.id.tvForgotPassword);
        chkboxRememberMe  = view.findViewById(R.id.chkboxRememberMe);
        btLogin.setOnClickListener(this);
        tvLogin.setOnClickListener(this);
        tvForgotPassword.setOnClickListener(this);
        ivPassword.setOnClickListener(this);
        chkboxRememberMe.setOnClickListener(this);
        String userName = PrefUtil.getValueFromKey(requireActivity(),GUEST_USER_NAME);
        String password = PrefUtil.getValueFromKey(requireActivity(),GUEST_USER_PASSWORD);
        if(!TextUtils.isEmpty(userName)){
            etUserName.setText(userName);
        }
        if(!TextUtils.isEmpty(password)){
            etPassword.setText(password);
        }
        if(!TextUtils.isEmpty(userName) && !TextUtils.isEmpty(password)){
            chkboxRememberMe.setChecked(true);
        }
    }

    private String showhide="Show";
    @Override
    public void onClick(View v) {
        switch (v.getId()){
           case R.id.btLogin:
               validate();
               break;
            case R.id.tvLogin:
                ((ActivityLogin) requireActivity()).startFragment(RegisterFragment.newInstance());
                break;
            case R.id.tvForgotPassword:
                ((ActivityLogin) requireActivity()).startFragment(ForgotPasswordFragment.newInstance());
                break;
            case R.id.ivPassword:
                if(showhide.equals("Hide"))
                {
                    showhide="Show";
                    etPassword.setTransformationMethod(PasswordTransformationMethod.getInstance());
                    ivPassword.setImageResource(R.drawable.icon_hide_password);
                }
                else if(showhide.equalsIgnoreCase("Show"))
                {
                    showhide="Hide";
                    etPassword.setTransformationMethod(HideReturnsTransformationMethod.getInstance());
                    ivPassword.setImageResource(R.drawable.icon_show_password);
                }
                break;
        }
    }

    private void startUserLogin(){
        Intent mIntent = new Intent(mContext, ActivityUserLogin.class);
        startActivity(mIntent);
        ((ActivityLogin) requireActivity()).finish();
    }

    private void validate(){
        String userName = etUserName.getText().toString().trim();
        String password = etPassword.getText().toString().trim();
        if(TextUtils.isEmpty(userName)){
            Toast.makeText(mContext,"Please enter username",Toast.LENGTH_LONG).show();
            return;
        }
        if(TextUtils.isEmpty(password)){
            Toast.makeText(mContext,"Please enter password",Toast.LENGTH_LONG).show();
            return;
        }
        if(chkboxRememberMe.isChecked()){
            saveUserNamePasswd(userName,password);
        }else{
            saveUserNamePasswd("","");
        }
        reqLogin();
    }
    private String getUserName() {
        return etUserName.getText().toString().trim();
    }

    private String getPassword() {
        return etPassword.getText().toString().trim();
    }

    public void reqLogin() {
        Map<String, String> req_params = new HashMap<>();
        req_params.put(REQUEST_KEY_USERNAME, getUserName());
        req_params.put(REQUEST_KEY_PASSWORD, getPassword());

        new RestApiRequestListener(requireActivity(), TAG_REQUEST_LOGIN, RestApiUrl.URL_GUEST_USER_LOGIN, CommonUtils.getHeader(), req_params, new RestApiRequestListener.setOnRequestListener() {
            @Override
            public void onPreExecute() {
                ((ActivityLogin) requireActivity()).showLoading(getString(R.string.logging_in_please_wait));
            }
            @Override
            public void onSuccessListener(String response) {
                ((ActivityLogin) requireActivity()).hideLoading();
                if(!TextUtils.isEmpty(response)) {
                    parseLogInResponse(response);
                }
            }
            @Override
            public void onErrorListener(String errorMessage) {
                ((ActivityLogin) requireActivity()).hideLoading();
            }
        }).request();
    }

    private void parseLogInResponse(String response) {
        GuestUserResponse mGuestUserResponse = new Gson().fromJson(response,GuestUserResponse.class);
      if(mGuestUserResponse!=null && mGuestUserResponse.getToken()!=null){
          PrefUtil.saveGuestUser(requireActivity(), mGuestUserResponse);
          startUserLogin();
      }else {
          Toast.makeText(mContext,"Please enter valid username and password",Toast.LENGTH_LONG).show();
      }
    }

    private void saveUserNamePasswd(String userName,String passwd){
        PrefUtil.setValueForKey(requireActivity(),GUEST_USER_NAME,userName);
        PrefUtil.setValueForKey(requireActivity(),GUEST_USER_PASSWORD,passwd);
    }
}
