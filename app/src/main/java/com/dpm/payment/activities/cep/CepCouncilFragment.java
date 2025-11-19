package com.dpm.payment.activities.cep;

import static com.dpm.payment.utils.ConstantData.DISTRICT_NAME;
import static com.dpm.payment.utils.StringUtils.capitalizeEachWord;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.text.InputType;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.fragment.app.Fragment;
import com.dpm.payment.models.cep.DistrictItem;
import com.google.android.material.textview.MaterialTextView;

import com.dpm.payment.R;
import com.squareup.picasso.Picasso;


public class CepCouncilFragment extends Fragment{
    private MaterialTextView tvContinue,tvWelcomeText,tvAddress,tvPhone,tvEmail,tvDistrict,
            tvWard,tvConstituencies,tvProvince;
    private AppCompatImageView ivCouncilImage;
    private Context mContext;
    private DistrictItem mDistrictItem ;
    public static CepCouncilFragment newInstance( DistrictItem districtName){
        CepCouncilFragment mCepCouncilFragment= new CepCouncilFragment();
        Bundle bundle  =  new Bundle();
        bundle.putSerializable(DISTRICT_NAME,districtName);
        mCepCouncilFragment.setArguments(bundle);
        return mCepCouncilFragment;
    }
    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext = context;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_cep_council, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initToolbar(view);
        initView(view);
    }

    @SuppressLint("SetTextI18n")
    private void initToolbar(View view){
         mDistrictItem  = (DistrictItem)getArguments().getSerializable(DISTRICT_NAME);
        AppCompatTextView tvTitle = view.findViewById(R.id.toolbar_tv_header);
        ImageView ivHome = view.findViewById(R.id.toolbar_iv_home);
        try {
            if(mDistrictItem!=null && mDistrictItem.getCouncilName()!=null) {
                tvTitle.setText(capitalizeEachWord(mDistrictItem.getCouncilName()));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        AppCompatImageView ivProfile = view.findViewById(R.id.ivProfile);
        AppCompatImageView ivNotification = view.findViewById(R.id.ivNotification);
        ivHome.setOnClickListener(v -> {
            ((ActivityCep)requireActivity()).onBackPressed();
        });
        ivNotification.setOnClickListener(v -> {
            ((ActivityCep)requireActivity()).startFragment(NotificationFragment.newInstance());
        });
        ivProfile.setOnClickListener(v -> {
            ((ActivityCep)requireActivity()).startFragment(MyProfileFragment.newInstance());
        });
    }

    @SuppressLint("SetTextI18n")
    private void initView(View view){
        tvContinue = view.findViewById(R.id.tvContinue);
        tvWelcomeText = view.findViewById(R.id.tvWelcomeText);
        tvAddress = view.findViewById(R.id.tvAddress);
        tvPhone = view.findViewById(R.id.tvPhone);
        tvEmail = view.findViewById(R.id.tvEmail);
        tvDistrict = view.findViewById(R.id.tvDistrict);
        ivCouncilImage = view.findViewById(R.id.ivCouncilImage);
        tvWard= view.findViewById(R.id.tvWard);
        tvConstituencies= view.findViewById(R.id.tvConstituencies);
        tvProvince= view.findViewById(R.id.tvProvince);
        tvDistrict.setText(mDistrictItem.getDistrict());
        tvWelcomeText.setText("Welcome to the "+capitalizeEachWord(mDistrictItem.getCouncilName()));
        tvAddress.setText(mDistrictItem.getCouncilAddress());
        tvPhone.setText("Telephone - "+mDistrictItem.getEnquiriesPhone());
        tvEmail.setText("Email - "+mDistrictItem.getEnquiriesEmail());
        tvWard.setText(mDistrictItem.getWards());
        tvConstituencies.setText(mDistrictItem.getConstituencies());
        tvProvince.setText(mDistrictItem.getProvince());
        if(!TextUtils.isEmpty(mDistrictItem.getPrimaryLogo()))
         Picasso.get().load(mDistrictItem.getPrimaryLogo()).into(ivCouncilImage);
        tvContinue.setOnClickListener(v -> ((ActivityCep)requireActivity()).startFragment(CEPMenuFragment.newInstance()));
    }





}
