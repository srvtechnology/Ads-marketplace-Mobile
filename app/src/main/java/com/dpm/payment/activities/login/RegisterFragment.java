package com.dpm.payment.activities.login;

import static com.dpm.payment.utils.CommonUtils.getHeader;
import static com.dpm.payment.utils.CommonUtils.isValidEmail;
import static com.dpm.payment.utils.ConstantData.REQUEST_KEY_EMAIL;
import static com.dpm.payment.utils.ConstantData.REQUEST_KEY_NAME;
import static com.dpm.payment.utils.ConstantData.REQUEST_KEY_PASSWORD;
import static com.dpm.payment.utils.ConstantData.REQUEST_KEY_PHONE;
import static com.dpm.payment.utils.ConstantData.REQUEST_KEY_USERNAME;
import static com.dpm.payment.utils.ConstantData.TAG_REQUEST_LOGIN;
import static com.dpm.payment.utils.ConstantData.TAG_REQUEST_REGISTER;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.method.HideReturnsTransformationMethod;
import android.text.method.PasswordTransformationMethod;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatSpinner;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.adapters.TimeAdapter;
import com.dpm.payment.interfaces.OnItemClickListener;
import com.dpm.payment.models.cep.GuestUserResponse;
import com.dpm.payment.models.cep.RegisterErrorResponse;
import com.dpm.payment.models.cep.RegisterResponse;
import com.dpm.payment.models.cep.TimeModel;
import com.dpm.payment.utils.PrefUtil;
import com.dpm.payment.utils.RestApiRequestListener;
import com.dpm.payment.utils.RestApiUrl;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.hbb20.CountryCodePicker;
import com.dpm.payment.R;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class RegisterFragment extends Fragment implements View.OnClickListener {
    private AppCompatTextView tvRegister,tvLogin;
    private CountryCodePicker ccp;
    private Context mContext;
    private AppCompatImageView ivPassword;
    private EditText etName,etPhone,etUserName,etEmail,etPassword;
    public static RegisterFragment newInstance(){
        return new RegisterFragment();
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext=context;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_registration,container,false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView(view);
    }


    private void initView(View view) {
        tvRegister = view.findViewById(R.id.btRegister);
        tvLogin = view.findViewById(R.id.tvLogin);
        ivPassword = view.findViewById(R.id.ivPassword);
        ccp = view.findViewById(R.id.ccp);
        etName= view.findViewById(R.id.etName);
        etPhone= view.findViewById(R.id.etPhone);
        etUserName= view.findViewById(R.id.etUserName);
        etEmail= view.findViewById(R.id.etEmail);
        etPassword= view.findViewById(R.id.etPassword);
        ivPassword.setImageResource(R.drawable.icon_hide_password);
        tvRegister.setOnClickListener(this);
        tvLogin.setOnClickListener(this);
        ivPassword.setOnClickListener(this);
    }

    private String showhide="Show";
    @Override
    public void onClick(View v) {
        switch (v.getId()){
           case R.id.btRegister:
               validate();
               break;
            case R.id.tvLogin:
                ((ActivityLogin) requireActivity()).onBackPressed();
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

    private void validate(){
        String name = etName.getText().toString().trim();
        String phone = etPhone.getText().toString().trim();
        String userName = etUserName.getText().toString().trim();
        String email = etEmail.getText().toString().trim();
        String password = etPassword.getText().toString().trim();
        if(TextUtils.isEmpty(name)){
            Toast.makeText(mContext,"Please enter name",Toast.LENGTH_LONG).show();
            return;
        }
        if(TextUtils.isEmpty(phone)){
            Toast.makeText(mContext,"Please enter phone number",Toast.LENGTH_LONG).show();
            return;
        }
        if(TextUtils.isEmpty(userName)){
            Toast.makeText(mContext,"Please enter username",Toast.LENGTH_LONG).show();
            return;
        }
        if(TextUtils.isEmpty(email)){
            Toast.makeText(mContext,"Please enter email",Toast.LENGTH_LONG).show();
            return;
        }
        if(!isValidEmail(email)){
            Toast.makeText(mContext,"Please enter a valid email",Toast.LENGTH_LONG).show();
            return;
        }
        if(TextUtils.isEmpty(password)){
            Toast.makeText(mContext,"Please enter password",Toast.LENGTH_LONG).show();
            return;
        }
        reqRegister();
    }

    private String getName() {
        return etName.getText().toString().trim();
    }
    private String getPhone() {
        return ccp.getSelectedCountryCode()+etPhone.getText().toString().trim();
    }
    private String getUserName() {
        return etUserName.getText().toString().trim();
    }
    private String getEmail() {
        return etEmail.getText().toString().trim();
    }
    private String getPassword() {
        return etPassword.getText().toString().trim();
    }

    public void reqRegister() {
        Map<String, String> req_params = new HashMap<>();
        req_params.put(REQUEST_KEY_EMAIL,getEmail());
        req_params.put(REQUEST_KEY_NAME,getName());
        req_params.put(REQUEST_KEY_USERNAME, getUserName());
        req_params.put(REQUEST_KEY_PHONE, getPhone());
        req_params.put(REQUEST_KEY_PASSWORD, getPassword());

        new RestApiRequestListener(requireActivity(), TAG_REQUEST_REGISTER, RestApiUrl.URL_GUEST_USER_REGISTER, getHeader(), req_params, new RestApiRequestListener.setOnRequestListener() {
            @Override
            public void onPreExecute() {
                ((ActivityLogin) requireActivity()).showLoading(getString(R.string.registering_please_wait));
            }

            @Override
            public void onSuccessListener(String response) {
                ((ActivityLogin) requireActivity()).hideLoading();
                if(!TextUtils.isEmpty(response)) {
                    parseRegisterResponse(response);
                }

            }

            @Override
            public void onErrorListener(String errorMessage) {
                ((ActivityLogin) requireActivity()).hideLoading();

            }
        }).request();
    }

    private void parseRegisterResponse(String response) {
        try {
            RegisterResponse mRegisterResponse = new Gson().fromJson(response, RegisterResponse.class);
            if(mRegisterResponse!=null && mRegisterResponse.getSuccess()!=null){
                ((ActivityLogin) requireActivity()).onBackPressed();
            }else{
                Toast.makeText(mContext, "Username or Email Already Taken", Toast.LENGTH_LONG).show();
            }
        } catch (JsonSyntaxException e) {
            RegisterErrorResponse mRegisterErrorResponse = new Gson().fromJson(response, RegisterErrorResponse.class);
            if(mRegisterErrorResponse!=null && !mRegisterErrorResponse.getSuccess() &&
                    !TextUtils.isEmpty(mRegisterErrorResponse.getMessage())){
                Toast.makeText(mContext,mRegisterErrorResponse.getMessage(),Toast.LENGTH_LONG).show();
            }else {
                Toast.makeText(mContext, "Username or Email Already Taken", Toast.LENGTH_LONG).show();
            }
        }
    }
}
