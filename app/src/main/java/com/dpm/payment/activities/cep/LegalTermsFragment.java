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

import com.dpm.payment.activities.cep.emergencyservice.EmergencyServicesFragment;
import com.dpm.payment.activities.cep.formsResources.FormsResourcesFragment;
import com.dpm.payment.activities.cep.garbageCollection.GarbageCollectionFragment;
import com.dpm.payment.activities.cep.newsLetter.NewsLetterFragment;
import com.dpm.payment.adapters.MyProfileAdapter;
import com.dpm.payment.models.cep.CepModel;
import com.dpm.payment.R;

import java.util.ArrayList;


public class LegalTermsFragment extends Fragment{

    private RecyclerView rvCep;
    private ArrayList<CepModel> cepList;
    private Context mContext;
    public static LegalTermsFragment newInstance(){
        return new LegalTermsFragment();
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
        tvTitle.setText(getString(R.string.legal_terms));

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
        cepList.add(new CepModel("Terms of use", R.drawable.ic_demand_note));
        cepList.add(new CepModel("Privacy Policy", R.drawable.ic_demand_note));
        cepList.add(new CepModel("Intellectual Property", R.drawable.ic_demand_note));
        setAdapter();
    }

    private void setAdapter() {
        MyProfileAdapter adapter = new MyProfileAdapter(mContext, cepList, (view, position) -> {
            switch (position) {
                case 0:
                    ((ActivityCep) requireActivity()).startFragment(ProfileFragment.newInstance());
                    break;
                case 1:
                    ((ActivityCep) requireActivity()).startFragment(FormsResourcesFragment.newInstance());
                    break;
                case 2:
                    ((ActivityCep) requireActivity()).startFragment(ScheduleAppointmentFragment.newInstance());
                    break;
                case 4:
                    ((ActivityCep) requireActivity()).startFragment(GarbageCollectionFragment.newInstance());
                    break;
                case 7: ((ActivityCep) requireActivity()).startFragment(new NewsLetterFragment());
                    break;
                case 9: ((ActivityCep) requireActivity()).startFragment(EmergencyServicesFragment.newInstance());
                    break;

            }
        });
        LinearLayoutManager layoutManager = new LinearLayoutManager(mContext);
        rvCep.setLayoutManager(layoutManager);
        rvCep.setAdapter(adapter);
    }


}
