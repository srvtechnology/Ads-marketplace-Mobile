package com.dpm.payment.activities.cep;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.dpm.payment.adapters.MyProfileAdapter;
import com.dpm.payment.models.cep.CepModel;
import com.dpm.payment.utils.CommonUtils;
import com.dpm.payment.R;

import java.util.ArrayList;


public class MyProfileFragment extends Fragment{

    private RecyclerView rvCep;
    private ArrayList<CepModel> cepList;
    private Context mContext;
    public static MyProfileFragment newInstance(){
        return new MyProfileFragment();
    }
    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext = context;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_cep_menu_new, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initToolbar(view);
        initView(view);

    }

    @SuppressLint("SetTextI18n")
    private void initToolbar(View view){
        AppCompatTextView tvTitle = view.findViewById(R.id.toolbar_tv_header);
        ImageView ivHome = view.findViewById(R.id.toolbar_iv_home);
        tvTitle.setText(getString(R.string.my_account));

        AppCompatImageView ivProfile = view.findViewById(R.id.ivProfile);
        AppCompatImageView ivNotification = view.findViewById(R.id.ivNotification);
        ivProfile.setVisibility(View.GONE);
        ivHome.setOnClickListener(v -> {
            ((ActivityCep)requireActivity()).onBackPressed();
        });
        ivNotification.setOnClickListener(v -> {
            ((ActivityCep)requireActivity()).startFragment(NotificationFragment.newInstance());
        });
    }
    private void initView(View view) {
        rvCep = view.findViewById(R.id.rvCep);
        setData();
    }

    private void setData() {
        cepList = new ArrayList<>();
        cepList.add(new CepModel("Personal Info", R.drawable.ic_name));
        cepList.add(new CepModel("User settings", R.drawable.ic_name));
        cepList.add(new CepModel("Legal terms", R.drawable.ic_demand_note));
        cepList.add(new CepModel("logout", R.drawable.ic_profile_logout));
        setAdapter();
    }

    private void setAdapter() {
        MyProfileAdapter adapter = new MyProfileAdapter(mContext, cepList, (view, position) -> {
            switch (position) {
                case 0:
                    ((ActivityCep) requireActivity()).startFragment(ProfileFragment.newInstance());
                    break;
                case 1:
                    ((ActivityCep) requireActivity()).startFragment(UserSettingsFragment.newInstance());
                    break;
                case 2:
                    ((ActivityCep) requireActivity()).startFragment(LegalTermsFragment.newInstance());
                    break;
                case 3:
                    CommonUtils.showLogoutDialog((ActivityCep)requireActivity());
                    break;

            }
        });
        LinearLayoutManager layoutManager = new LinearLayoutManager(mContext);
        rvCep.setLayoutManager(layoutManager);
        rvCep.setAdapter(adapter);
    }


}
