package com.dpm.payment.activities.user;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.activities.cep.ActivityCep;
import com.dpm.payment.activities.landlord.LandlordPropertyDetailsActivity;
import com.dpm.payment.adapters.PropertyGridAdapter;
import com.dpm.payment.adapters.PropertyListItem;
import com.dpm.payment.models.LandloradPenDisImage.LandlordPenDIsImage;
import com.dpm.payment.models.propertydetail.PropertyModelResponse;
import com.dpm.payment.utils.AlertDialogUtils;
import com.dpm.payment.utils.DataUtils;
import com.dpm.payment.utils.LogUtils;
import com.dpm.payment.utils.PrefUtil;
import com.dpm.payment.utils.RestApiRequestListener;
import com.dpm.payment.utils.StringUtils;
import com.google.gson.Gson;
import com.dpm.payment.R;
import org.json.JSONArray;
import org.json.JSONObject;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import static com.dpm.payment.utils.ConstantData.TAG_REQUEST_LANDLORD_PROPERTY_LIST;
import static com.dpm.payment.utils.Helper.discounted_value_Hashmap;
import static com.dpm.payment.utils.Helper.taxable_value_Hashmap;
import static com.dpm.payment.utils.RestApiUrl.URL_LANDLORD_PROPERTY_LIST;

public class ListPropertyUserActivity extends AppCompatActivity implements PropertyGridAdapter.OnAdapterActionListener {

    private RecyclerView rvListOfProperty;
    private PropertyGridAdapter mPropertyAdapter;
    private Button getProperty;
    private LandlordResponseModel mLandlordUserModel;
    private Context mContext;
    private ProgressDialog progressDialog;
    private List<PropertyListItem> listPropertyList = new ArrayList<>();
    private List<String> listPropertyListItemFullObject = new ArrayList<>();
    public static String KEY_PROPERTY_DETAILS="property_details";
    private TextView tvNoResult;

    private PropertyModelResponse modelResponse;

    List<LandlordPenDIsImage> list_images=new ArrayList<>();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_property_user);
        mContext = this;

        setUI();
        onClick();
        setAdapter();
        mLandlordUserModel = PrefUtil.getLandlordProfile(mContext);
        initToolbar();
    }

    private void initToolbar(){
        TextView tvHeader = findViewById(R.id.toolbar_tv_header);
        tvHeader.setText(R.string.property);
        ImageView ivHome =findViewById(R.id.toolbar_iv_home);
        AppCompatImageView ivProfile = findViewById(R.id.ivProfile);
        AppCompatImageView ivNotification = findViewById(R.id.ivNotification);
        ivHome.setVisibility(View.GONE);
        ivProfile.setOnClickListener(v -> {
            showProfileOrNotification("profile");
        });
        ivNotification.setOnClickListener(v -> {
            showProfileOrNotification("notification");
        });
    }

    private void setUI() {
        getProperty = findViewById(R.id.getProperty);
        rvListOfProperty = findViewById(R.id.rvListOfProperty);
        rvListOfProperty.setVisibility(View.GONE);
        tvNoResult= findViewById(R.id.tvNoResult);
        tvNoResult.setVisibility(View.GONE);
    }

    private void onClick() {
        getProperty.setOnClickListener(view -> {
            rvListOfProperty.setVisibility(View.VISIBLE);
            getProperty.setVisibility(View.GONE);
            tvNoResult.setVisibility(View.GONE);


            try {

                if (DataUtils.isInternetConnectAvailable(mContext)) {
                    reqCallPropertyList();
                } else {
                    AlertDialogUtils.showInternetConnNotAvailableDialog(mContext);
                }

            } catch (Exception ex) {
                ex.printStackTrace();
            }


        });
    }

    private void setAdapter() {
        mPropertyAdapter = new PropertyGridAdapter(listPropertyList, ListPropertyUserActivity.this);
        GridLayoutManager mLinearLayoutManager = new GridLayoutManager(this,2);
        rvListOfProperty.setLayoutManager(mLinearLayoutManager);
        rvListOfProperty.setAdapter(mPropertyAdapter);
    }

    // --------------------------------------------- Call for Search ----------------------------------------------//


    String pensioner_image_path="";
    String disability_image_path="";

    @Override
    public void onItemClickListener(int position) {
        try {

            String mPropertyDetails = listPropertyListItemFullObject.get(position);

            JSONObject object = new JSONObject(mPropertyDetails);

            String id = object.getString("id");

            for (int i=0; i<list_images.size(); i++){

                if (list_images.get(i).id.equalsIgnoreCase(id)){
                    pensioner_image_path=list_images.get(i).getPensioner_discount_image_path();
                    disability_image_path=list_images.get(i).getDisability_discount_image_path();
                    break;
                }

            }





            Intent mIntent = new Intent(this, LandlordPropertyDetailsActivity.class);
            mIntent.putExtra(KEY_PROPERTY_DETAILS, mPropertyDetails);
            mIntent.putExtra(KEY_PROPERTY_DETAILS+"1", new Gson().toJson(modelResponse.getProperty().get(position)));
            mIntent.putExtra("pensioner_image_path",pensioner_image_path);
            mIntent.putExtra("disability_image_path",disability_image_path);
            startActivity(mIntent);
        }catch (Exception ex)
        {
            ex.printStackTrace();
        }

    }

    private void reqCallPropertyList() {

        progressDialog = new ProgressDialog(mContext);

        HashMap<String, String> headers = new HashMap<>();
        headers.put("Accept", "application/json");
        headers.put("Authorization", mLandlordUserModel.getAuth_type() + " " + mLandlordUserModel.getToken());


        Map<String, String> req_params = new HashMap<>();
        //  req_params.put(REQUEST_KEY_OPEN_LOCATION_CODE, getUserInputNoticeId());

        LogUtils.showErrorLog("header", headers.toString());
        LogUtils.showErrorLog("header", req_params.toString());

        Log.d("ApiCallResponse","url "+URL_LANDLORD_PROPERTY_LIST);
        Log.d("ApiCallResponse","headers "+headers);

        new RestApiRequestListener(this, TAG_REQUEST_LANDLORD_PROPERTY_LIST, URL_LANDLORD_PROPERTY_LIST, headers, null,
                new RestApiRequestListener.setOnRequestListener() {


            @Override
            public void onPreExecute() {
                try {
                    progressDialog.setMessage("" + mContext.getResources().getString(R.string.connecting_server));
                    progressDialog.setCancelable(false);
                    progressDialog.show();
                }catch (Exception ex)
                {
                    ex.printStackTrace();
                }
            }

            @Override
            public void onSuccessListener(String response) {

                if (progressDialog != null) {
                    if (progressDialog.isShowing()) {
                        progressDialog.dismiss();

                        try {




                            modelResponse=new Gson().fromJson(response.toString(),PropertyModelResponse.class);


                            JSONObject mJsonResponse = new JSONObject(response);
                            LogUtils.showErrorLog(" === Response === ", "=== Response === " + mJsonResponse);

                           JSONArray properties_discount_pensioner_images = mJsonResponse.getJSONArray("properties_discount_pensioner_images");
                            discounted_value_Hashmap.clear();
                            taxable_value_Hashmap.clear();
                           for (int i=0; i< properties_discount_pensioner_images.length(); i++){


                               JSONObject object = properties_discount_pensioner_images.getJSONObject(i);

                               discounted_value_Hashmap.put(object.getString("property_id"),object.optString("discounted_value"));
                               taxable_value_Hashmap.put(object.getString("property_id"),object.optString("property_taxable_value"));

                               String property_id = object.getString("property_id");

                               if (!object.isNull("pensioner_image_path")) {
                                    pensioner_image_path = object.optJSONObject("pensioner_image_path").getString("pensioner_discount_image_path");
                               }
                               if (!object.isNull("disability_image_path")) {

                                    disability_image_path = object.optJSONObject("disability_image_path").getString("disability_discount_image_path");
                               }

                               LandlordPenDIsImage landlordPenDIsImage
                                       =new LandlordPenDIsImage(property_id,pensioner_image_path,disability_image_path);


                               list_images.add(landlordPenDIsImage);

                           }



                            if (mJsonResponse.has("property") && mJsonResponse.getString("property") == null) {
                                Toast.makeText(mContext, "Property not found", Toast.LENGTH_LONG).show();
                            } else {

                                //TODO Edit by Debabrata: Save response to preference.

                                PrefUtil.saveLandlordPropertyList(mContext,response);
                               JSONArray mProperty= mJsonResponse.getJSONArray("property");


                               if(listPropertyList!=null)
                               {
                                   listPropertyList.clear();
                               }
                               if(listPropertyListItemFullObject!=null)
                               {
                                   listPropertyListItemFullObject.clear();
                               }

                               for(int i=0;i<mProperty.length();i++)
                               {

                                   try {
                                       String mPropertyId = mProperty.getJSONObject(i).optString("id");
                                       String mCurrentYearAssessmentAmount = mProperty.getJSONObject(i).getJSONObject("assessment").getString("current_year_assessment_amount");

                                       LogUtils.showErrorLog(" === mCurrentYearAssessmentAmount "," mCurrentYearAssessmentAmount "+mCurrentYearAssessmentAmount);
                                       LogUtils.showErrorLog(" === assessment list  "," assessment list "+mProperty.getJSONObject(i).getJSONObject("assessment"));

                                       String mPropertyImg = mProperty.getJSONObject(i).getJSONObject("assessment").optString("small_preview_one");

                                       String balanceAmountDue = mProperty.getJSONObject(i).getJSONObject("assessment").optString("balance");

                                       LogUtils.showErrorLog(" === Image link  "," Image Link : "+mPropertyImg);


                                       PropertyListItem mPropertyListItem1 = new PropertyListItem();
                                     //  mPropertyListItem1.setAssessment(mCurrentYearAssessmentAmount);

                                       if(mCurrentYearAssessmentAmount.contains("E")) {

                                           mPropertyListItem1.setAssessment(""+ StringUtils.AmountWithComma(""+new BigDecimal(mCurrentYearAssessmentAmount)));
                                       }else{
                                           mPropertyListItem1.setAssessment(""+mCurrentYearAssessmentAmount);
                                       }

                                       mPropertyListItem1.setPropertyName("" + mPropertyId);
                                       mPropertyListItem1.setPropertyImg(""+mPropertyImg);
                                       mPropertyListItem1.setBalance(balanceAmountDue);



                                       listPropertyList.add(i,mPropertyListItem1);
                                       listPropertyListItemFullObject.add(i,mProperty.getJSONObject(i).toString());

                                   }catch (Exception ex)
                                   {
                                       ex.printStackTrace();
                                   }
                               }

                               if(listPropertyListItemFullObject.size()>0)
                               {
                                   tvNoResult.setVisibility(View.GONE);
                               }else{
                                   tvNoResult.setVisibility(View.VISIBLE);
                               }
                              mPropertyAdapter.notifyDataSetChanged();
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

    @Override
    public void onBackPressed() {


        showLogoutDialog(mContext);

    }

    public  void showLogoutDialog(Context mCtx)
    {
        try {
            AlertDialog mAlertDialog;
            AlertDialog.Builder builder = new AlertDialog.Builder(mCtx, R.style.AlertDialogTheme);
            // Set a title for alert dialog
            builder.setTitle("Alert?");

            builder.setCancelable(false);

            // Ask the final question
            builder.setMessage("" + mCtx.getResources().getString(R.string.do_you_want_to_logout));

            // Set the alert dialog yes button click listener
            builder.setPositiveButton("OK", (dialog, which) -> {
                // Do something when user clicked the Yes button
                // Set the TextView visibility GONE
                dialog.dismiss();

                Intent i = new Intent(ListPropertyUserActivity.this, ActivityUserLogin.class);
                i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                startActivity(i);
                finish();

            });

            // Set the alert dialog no button click listener
            builder.setNegativeButton("Cancel", (dialog, which) -> {
                // Do something when No button clicked
                if (dialog != null) {
                    dialog.dismiss();
                }
            });

            mAlertDialog = builder.create();
            // Display the alert dialog on interface
            mAlertDialog.show();
        }catch (Exception ex)
        {
            ex.printStackTrace();
        }
    }
    private void showProfileOrNotification(String type){
        Intent mIntent = new Intent(mContext, ActivityCep.class);
        mIntent.putExtra("type",type);
        startActivity(mIntent);
    }
}
