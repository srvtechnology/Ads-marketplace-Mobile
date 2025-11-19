package com.dpm.payment.activities.cep;

import static com.dpm.payment.utils.ConstantData.DISTRICT_NAME;

import android.app.ProgressDialog;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.dpm.payment.models.cep.DistrictItem;
import com.dpm.payment.R;

import java.util.ArrayList;

public class ActivityCep extends AppCompatActivity {

    private ProgressDialog progressDialog;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_cep);
        initView();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        doBack();
    }

    private void initView(){
        progressDialog = new ProgressDialog(this);
        String type = getIntent().getStringExtra("type");
        if (type.equalsIgnoreCase("notification")) {
            startFragment(NotificationFragment.newInstance());
        } else if (type.equalsIgnoreCase("profile")) {
            startFragment(MyProfileFragment.newInstance());
        } else {
            DistrictItem districtName = (DistrictItem)getIntent().getSerializableExtra(DISTRICT_NAME);
            startFragment(CepCouncilFragment.newInstance(districtName));
        }
    }

    public  void startFragment(Fragment fragment, Boolean clearBackStack ) {
        doStartFragment( fragment, clearBackStack);
    }

   public void startFragment( Fragment fragment) {
        doStartFragment( fragment, false);
    }

    private void doStartFragment(Fragment fragment, Boolean clearBackStack
    ) {
        if (clearBackStack) {
            clearBackStack();
            //showHideBack(false)
        }

        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();

        fragmentTransaction.setCustomAnimations(
                android.R.anim.slide_in_left,
                android.R.anim.slide_out_right,
                android.R.anim.slide_in_left,
                android.R.anim.slide_out_right
        );

        fragmentTransaction.replace(R.id.frmlayout, fragment);
        fragmentTransaction.addToBackStack(fragment.getClass().getName());

        fragmentTransaction.commit();
    }

    private void clearBackStack() {
        FragmentManager manager = getSupportFragmentManager();
        int count = manager.getBackStackEntryCount();
        if (count > 1) {
            for (int i=0;i<count;i++) {
                manager.popBackStack();
            }
        }

    }
    private int TIME_INTERVAL =
            2000; // # milliseconds, desired time passed between two back presses.
    private Long mBackPressed = 0L;
    private void doBack(){
        FragmentManager fragmentManager = getSupportFragmentManager();
        int count = fragmentManager.getBackStackEntryCount();
        if (count == 0) {
            finish();
        } else {
            getFragmentManager().popBackStack();
        }
    }

    void showLoading(String message){
        progressDialog.setMessage(message);
        progressDialog.setCancelable(false);
        progressDialog.show();
    }

    void hideLoading(){
        if (progressDialog != null) {
            if (progressDialog.isShowing()) {
                progressDialog.dismiss();
            }
        }
    }


}
