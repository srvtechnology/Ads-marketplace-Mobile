package com.dpm.payment.activities.cep;

import static com.dpm.payment.utils.CommonUtils.getHeader;
import static com.dpm.payment.utils.ConstantData.TAG_REQUEST_DISTRICT_NAME;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CalendarView;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatSpinner;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.fragment.app.Fragment;

import com.dpm.payment.models.cep.CepDistrictNameResponse;
import com.dpm.payment.models.cep.GuestUserResponse;
import com.dpm.payment.utils.PrefUtil;
import com.dpm.payment.utils.RestApiRequestListener;
import com.dpm.payment.utils.RestApiUrl;
import com.dpm.payment.utils.StringUtils;
import com.google.android.material.textview.MaterialTextView;
import com.google.gson.Gson;
import com.dpm.payment.R;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class ProfileFragment extends Fragment {
    private Context mContext;
    private AppCompatSpinner spnrDistrict;
    private MaterialTextView tvUserName,tvEmail;

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext = context;
    }

    public static ProfileFragment newInstance(){
        return new ProfileFragment();
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_profile,container,false);
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
        ivProfile.setVisibility(View.GONE);
        tvTitle.setText(getString(R.string.personal_info));
        ivHome.setOnClickListener(v -> {
            ((ActivityCep)requireActivity()).onBackPressed();
        });
        ivNotification.setOnClickListener(v -> {
            ((ActivityCep)requireActivity()).startFragment(NotificationFragment.newInstance());
        });
    }
    private void initView(View view) {
        tvUserName = view.findViewById(R.id.tvUserName);
        tvEmail = view.findViewById(R.id.tvEmail);
        spnrDistrict = view.findViewById(R.id.spnrDistrict);
        GuestUserResponse mGuestUserResponse = PrefUtil.getGuestUser(requireActivity());
        if(mGuestUserResponse!=null){
            if(!TextUtils.isEmpty(mGuestUserResponse.getUser().getName())){
                tvUserName.setText(mGuestUserResponse.getUser().getName());
            }
            if(!TextUtils.isEmpty(mGuestUserResponse.getUser().getEmail())){
                tvEmail.setText(mGuestUserResponse.getUser().getEmail());
            }
        }
        reqDistrict();
    }

    private void setSpinnerAdapter(List<String> mList){
        ArrayAdapter aa = new ArrayAdapter(mContext,R.layout.adapter_profile_spinner,R.id.text,mList);
        aa.setDropDownViewResource(R.layout.adapter_profile_spinner);
        spnrDistrict.setAdapter(aa);
        String councilName = PrefUtil.getCouncilName(requireActivity());
        if(!TextUtils.isEmpty(councilName)){
            for(int i=0;i<mList.size();i++){
               if(councilName.equalsIgnoreCase(mList.get(i))) {
                   spnrDistrict.setSelection(i);
                   break;
               }
            }
        }
    }
    private CepDistrictNameResponse mCepDistrictNameResponse;
    public void reqDistrict() {
        new RestApiRequestListener(requireActivity(), TAG_REQUEST_DISTRICT_NAME, RestApiUrl.URL_CEP_DISTRICT_DETAILS, getHeader(), null, new RestApiRequestListener.setOnRequestListener() {
            @Override
            public void onPreExecute() {
                ((ActivityCep)requireActivity()).showLoading(getString(R.string.loading_please_wait));
            }
            @Override
            public void onSuccessListener(String response) {
                ((ActivityCep)requireActivity()).hideLoading();
                parseResponse(response);
            }
            @Override
            public void onErrorListener(String errorMessage) {
                ((ActivityCep)requireActivity()).hideLoading();
            }
        }).getRequest();
    }

    private void parseResponse(String response) {
        mCepDistrictNameResponse = new Gson().fromJson(response,CepDistrictNameResponse.class);
        if(mCepDistrictNameResponse.isSuccess() && mCepDistrictNameResponse.getCode()==200){
            if(mCepDistrictNameResponse.getResult().size()>0){
                List<String> mList = new ArrayList<>();
                mList.add("Select Council");
                for(int i=0; i<mCepDistrictNameResponse.getResult().size();i++){
                    mList.add(StringUtils.capitalizeEachWord(mCepDistrictNameResponse.getResult().get(i).getCouncilName()));
                }
                setSpinnerAdapter(mList);
            }
        }
    }

}
