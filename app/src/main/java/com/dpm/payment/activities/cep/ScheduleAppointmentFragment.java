package com.dpm.payment.activities.cep;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
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
import com.dpm.payment.models.cep.TimeModel;
import com.dpm.payment.R;
import java.util.ArrayList;

public class ScheduleAppointmentFragment extends Fragment {
    private AppCompatSpinner appointmentSpinner;
    private final String[] apppointmentWith = { "Chairman", "Chief Administrator", "Valuator", "Finance", "Legal"};
    private Context mContext;
    private ArrayList<TimeModel> mTimeList;
    private RecyclerView rvTime;
    public static ScheduleAppointmentFragment newInstance(){
        return new ScheduleAppointmentFragment();
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext=context;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_schedule_appiontment,container,false);
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
        tvTitle.setText(R.string.schedule_appointment);
        ivHome.setOnClickListener(v -> {
            getParentFragmentManager().popBackStack();
        });
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
        appointmentSpinner = view.findViewById(R.id.appointmentSpinner);
        rvTime = view.findViewById(R.id.rvTime);
        setSpinnerAdapter();
        setTimeAdapter();
    }

    private void setSpinnerAdapter(){
        ArrayAdapter aa = new ArrayAdapter(mContext,R.layout.adapter_text,apppointmentWith);
        aa.setDropDownViewResource(R.layout.adapter_text);
        appointmentSpinner.setAdapter(aa);
    }

    private void setTimeAdapter(){
        mTimeList = new ArrayList<>();
        mTimeList.add(new TimeModel("8am-9am",true));
        mTimeList.add(new TimeModel("9am-10am",false));
        TimeAdapter mTimeAdapter =new TimeAdapter(mContext,mTimeList, (OnItemClickListener) (view, position) -> {

        });
        LinearLayoutManager layoutManager=new LinearLayoutManager(requireActivity());
        rvTime.setLayoutManager(layoutManager);
        rvTime.setAdapter(mTimeAdapter);
    }
}
