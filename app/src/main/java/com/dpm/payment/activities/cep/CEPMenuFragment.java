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
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.dpm.payment.activities.cep.complaints.ComplaintsFragment;
import com.dpm.payment.activities.cep.emergencyservice.EmergencyServicesFragment;
import com.dpm.payment.activities.cep.formsResources.FormsResourcesFragment;
import com.dpm.payment.activities.cep.garbageCollection.GarbageCollectionFragment;
import com.dpm.payment.activities.cep.information_tips.InformationTipsFragment;
import com.dpm.payment.activities.cep.newsLetter.NewsLetterFragment;
import com.dpm.payment.adapters.CEPAdapter;
import com.dpm.payment.models.cep.CepModel;
import com.dpm.payment.R;

import java.util.ArrayList;

public class CEPMenuFragment extends Fragment {
    private RecyclerView rvCep;
    private ArrayList<CepModel> cepList;
    private Context mContext;

    public static CEPMenuFragment newInstance() {
        return new CEPMenuFragment();
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
        initView(view);
        initToolbar(view);

    }
    @SuppressLint("SetTextI18n")
    private void initToolbar(View view){
        AppCompatTextView tvTitle = view.findViewById(R.id.toolbar_tv_header);
        ImageView ivHome = view.findViewById(R.id.toolbar_iv_home);
        tvTitle.setText(getString(R.string.community_engagement_platform_1));
        ivHome.setVisibility(View.GONE);
        AppCompatImageView ivProfile = view.findViewById(R.id.ivProfile);
        AppCompatImageView ivNotification = view.findViewById(R.id.ivNotification);
        ivProfile.setOnClickListener(v -> {
            ((ActivityCep)requireActivity()).startFragment(MyProfileFragment.newInstance());
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
        cepList.add(new CepModel("Complaints & Reporting", R.drawable.ic_complaints));
        cepList.add(new CepModel("Forms & Resources", R.drawable.ic_forms_resources));
        cepList.add(new CepModel("Schedule Appointment", R.drawable.ic_schedule_appointment));
        cepList.add(new CepModel("Information & Tips", R.drawable.ic_information));
        cepList.add(new CepModel("Garbage Collection", R.drawable.ic_garbage_collection));
        cepList.add(new CepModel("Places", R.drawable.ic_places));
        cepList.add(new CepModel("Disaster Management", R.drawable.ic_disaster_management));
        cepList.add(new CepModel("Newsletter", R.drawable.ic_newsletter));
        cepList.add(new CepModel("Community Blog", R.drawable.ic_blog));
        cepList.add(new CepModel("Emergency Services", R.drawable.ic_emergency_services));
        setAdapter();
    }

    private void setAdapter() {
        CEPAdapter adapter = new CEPAdapter(mContext, cepList, (view, position) -> {
            switch (position) {
                case 0:
                    ((ActivityCep) requireActivity()).startFragment(ComplaintsFragment.newInstance());
                    break;
                case 1:
                    ((ActivityCep) requireActivity()).startFragment(FormsResourcesFragment.newInstance());
                    break;
                case 2:
                    ((ActivityCep) requireActivity()).startFragment(ScheduleAppointmentFragment.newInstance());
                    break;
                case 3:
                    ((ActivityCep) requireActivity()).startFragment(new InformationTipsFragment());
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
        GridLayoutManager layoutManager = new GridLayoutManager(mContext, 2);
        rvCep.setLayoutManager(layoutManager);
        rvCep.setAdapter(adapter);
    }
}
