package com.dpm.payment;

import static com.dpm.payment.utils.RestApiUrl.URL_CASHIER_LANDLORD_EDIT_PROFILE;
import static com.dpm.payment.utils.RestApiUrl.URL_EDIT_OCCUPANCY;
import static com.dpm.payment.utils.StringUtils.getAppendListDataWithSpacialCharacter;

import android.app.Activity;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;

import com.dpm.payment.activities.cashier.ActivityMainDetails;
import com.dpm.payment.adapters.DataViewAdapter;
import com.dpm.payment.models.DataModel;
import com.dpm.payment.models.OccupancyModel.TitlesItem;
import com.dpm.payment.models.SearchLandlordModel;
import com.dpm.payment.models.SearchOccupancyModel;
import com.dpm.payment.models.SearchPropertyModel;
import com.dpm.payment.models.propertydetail.Assessment;
import com.dpm.payment.models.propertydetail.PropertyItem;
import com.dpm.payment.retrofit.Utills.ApiRequest;
import com.dpm.payment.retrofit.Utills.PART;
import com.dpm.payment.utils.CommonUtils;
import com.dpm.payment.utils.LogUtils;
import com.dpm.payment.utils.PrefUtil;
import com.dpm.payment.utils.StringUtils;
import com.dpm.payment.R;

import org.json.JSONObject;
import org.w3c.dom.Text;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class TabDataInitializer {
    public static void setLandloardData(JSONObject landloadObject, JSONObject mMainObject, List<DataModel> listLandload, DataViewAdapter adapter) {

        try {
            if (landloadObject != null) {

                SearchLandlordModel landlordModel = (SearchLandlordModel) CommonUtils.getObjectFromJson(landloadObject.toString().trim(), SearchLandlordModel.class);


             /*   try {
                    if (landlordModel.getImage() != null) {
                        Picasso.get()
                                .load("" + landlordModel.getSmallPreview())
                                .placeholder(R.drawable.ic_my_profile)
                                .error(R.drawable.ic_my_profile)
                                .into(ivProfilePicLandload);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }*/

              /*  try {

                    DataModel model0 = new DataModel();
                    model0.setKey("Property ID");
                    model0.setValue("" + landlordModel.getPropertyId());
                    listLandload.add(model0);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }*/


                if (mMainObject.optBoolean("is_organization")) {

                    try {

                        String organization_name = ((mMainObject.optString("organization_name") == null) ? "" : "" + mMainObject.optString("organization_name"));

                        DataModel model18 = new DataModel();
                        model18.setKey("Organization Name");
                        model18.setValue("" + organization_name);
                        listLandload.add(model18);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                    try {

                        String OrganizationType = ((mMainObject.optString("organization_type") == null) ? "" : "" + mMainObject.optString("organization_type"));

                        DataModel model19 = new DataModel();
                        model19.setKey("Organization Type");
                        model19.setValue("" + OrganizationType);
                        listLandload.add(model19);

                        try {

                            String tin = ((mMainObject.getJSONObject("landlord").getJSONObject("property").optString("organization_tin") == null) ? "" : "" + mMainObject.getJSONObject("landlord").getJSONObject("property").optString("organization_tin"));

                            DataModel modeltin = new DataModel();
                            modeltin.setKey("TIN");
                            modeltin.setValue("" + tin);
                            listLandload.add(modeltin);


                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }


                        if (OrganizationType.equalsIgnoreCase("School")) {
                            listLandload.add(new DataModel("School Type", mMainObject.optString("organization_school_type")));

                        }

                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }



                  /*  try {

                        String OrganizationType = ((mMainObject.optString("organization_addresss") == null) ? "" : "" + mMainObject.optString("organization_addresss"));

                        DataModel model110 = new DataModel();
                        model110.setKey("Organization Address");
                        model110.setValue("" + OrganizationType);
                        listLandload.add(model110);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }*/


                } else {

                    try {

                        DataModel model0 = new DataModel();
                        model0.setKey("Title");
                        model0.setValue("" + landlordModel.getTitles().getLabel());
                        listLandload.add(model0);
                    } catch (Exception ex) {
                        DataModel model0 = new DataModel();
                        model0.setKey("Title");
                        model0.setValue("");
                        ex.printStackTrace();
                    }


                    try {
                        DataModel model1 = new DataModel();
                        model1.setKey("First Name");
                        model1.setValue(landlordModel.getFirstName());
                        listLandload.add(model1);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }


                    try {
                        DataModel model2 = new DataModel();
                        model2.setKey("Middle Name");
                        if (landlordModel.getMiddleName() == null || landlordModel.getMiddleName().trim().equals("")) {
                            model2.setValue("--");
                        } else model2.setValue(landlordModel.getMiddleName());
                        listLandload.add(model2);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }


                    try {
                        DataModel model3 = new DataModel();
                        model3.setKey("Surname");
                        model3.setValue(landlordModel.getSurname());
                        listLandload.add(model3);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }


                    try {
                        DataModel model4 = new DataModel();
                        model4.setKey("Gender");
                        model4.setValue(landlordModel.getSex().toUpperCase());
                        listLandload.add(model4);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }

                    try {

                        String OrganizationType = ((mMainObject.getJSONObject("landlord").optString("nin_number") == null) ? "" : "" + mMainObject.getJSONObject("landlord").optString("nin_number"));

                        DataModel model19 = new DataModel();
                        model19.setKey("NIN");
                        model19.setValue("" + OrganizationType);
                        listLandload.add(model19);


                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }

                }

               /* try {
                    DataModel model5 = new DataModel();
                    model5.setKey("Old Street Number");
                    model5.setValue(landlordModel.getStreetNumber());
                    listLandload.add(model5);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }*/


                try {
                    DataModel model5 = new DataModel();
                    model5.setKey("Street Number");
                    model5.setValue(landlordModel.getStreetNumber());
                    listLandload.add(model5);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                try {
                    DataModel model6 = new DataModel();
                    model6.setKey("Street Name");
                    model6.setValue(landlordModel.getStreetName());
                    listLandload.add(model6);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }


                try {
                    DataModel model3 = new DataModel();
                    model3.setKey("Additional Address");
                    model3.setValue(mMainObject.getJSONObject("landlord").optString("additional_address_id"));
                    listLandload.add(model3);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
                try {
                    DataModel model3 = new DataModel();
                    model3.setKey("Area");
                    model3.setValue(mMainObject.getJSONObject("landlord").optString("property_area"));
                    listLandload.add(model3);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }


                DataModel model12 = new DataModel();
                model12.setKey("Section");
                model12.setValue(landlordModel.getSection());
                listLandload.add(model12);


                DataModel model10 = new DataModel();
                model10.setKey("Ward");
                model10.setValue(landlordModel.getWard());
                listLandload.add(model10);


                DataModel model11 = new DataModel();
                model11.setKey("Constituency");
                model11.setValue(landlordModel.getConstituency());
                listLandload.add(model11);


                DataModel model13 = new DataModel();
                model13.setKey("Chiefdom");
                model13.setValue(landlordModel.getChiefdom());
                listLandload.add(model13);

                DataModel model14 = new DataModel();
                model14.setKey("District");
                model14.setValue(landlordModel.getDistrict());
                listLandload.add(model14);

                DataModel model15 = new DataModel();
                model15.setKey("Province");
                model15.setValue(landlordModel.getProvince());
                listLandload.add(model15);


                String mPostcode = ((landlordModel.getPostcode() == null) ? "" : "" + landlordModel.getPostcode());
                DataModel model19 = new DataModel();
                model19.setKey("Postcode");
                model19.setValue("" + mPostcode);
                listLandload.add(model19);

                DataModel model16 = new DataModel();
                model16.setKey("Mobile Number 1");
                model16.setValue(landlordModel.getMobile1());
                listLandload.add(model16);

                DataModel model17 = new DataModel();
                model17.setKey("Mobile Number 2");
                model17.setValue(landlordModel.getMobile2());
                listLandload.add(model17);

                try {
                    String mEmail = ((landlordModel.getEmail() == null) ? "" : "" + landlordModel.getEmail());
                    DataModel model18 = new DataModel();
                    model18.setKey("Email Address");
                    model18.setValue("" + mEmail);
                    listLandload.add(model18);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

             /*   try {
                    String mEmail = ((landlordModel.getEmail() == null) ? "" : "" + landlordModel.getEmail());
                    DataModel model18 = new DataModel();
                    model18.setKey("Email");
                    model18.setValue("" + mEmail);
                    listLandload.add(model18);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }*/

                adapter.notifyDataSetChanged();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public static void setPropertyData(JSONObject propertyObject, List<DataModel> listProperty, DataViewAdapter adapter) {
        try {
            if (propertyObject != null) {

                SearchPropertyModel propertyModel = (SearchPropertyModel) CommonUtils.getObjectFromJson(propertyObject.toString().trim(), SearchPropertyModel.class);

                try {

                    DataModel model0 = new DataModel();
                    model0.setKey("Property ID");
                    model0.setValue("" + propertyModel.getId());
                    listProperty.add(model0);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }


                /*DataModel model22 = new DataModel();
                model22.setKey("New Street Number");
                model22.setValue(propertyModel.getStreet_numbernew());
                listProperty.add(model22);*/


                DataModel model1 = new DataModel();
                model1.setKey("Street Number");
                model1.setValue(propertyModel.getStreetNumber());
                listProperty.add(model1);


                DataModel model2 = new DataModel();
                model2.setKey("Street Name");
                model2.setValue(propertyModel.getStreetName());
                listProperty.add(model2);

                try {
                    DataModel model3 = new DataModel();
                    model3.setKey("Additional Address");
                    model3.setValue(propertyObject.getJSONObject("landlord").optString("additional_address_id"));
                    listProperty.add(model3);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
                try {
                    DataModel model3 = new DataModel();
                    model3.setKey("Area");
                    model3.setValue(propertyObject.getJSONObject("landlord").optString("property_area"));
                    listProperty.add(model3);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }


                DataModel model4 = new DataModel();
                model4.setKey("Section");
                model4.setValue(propertyModel.getSection());
                listProperty.add(model4);


                DataModel model3 = new DataModel();
                model3.setKey("Ward");
                model3.setValue(String.valueOf(propertyModel.getWard()));
                listProperty.add(model3);


                String Constituency = ((propertyModel.getConstituency() == null) ? "" : propertyModel.getConstituency());


                DataModel model12 = new DataModel();
                model12.setKey("Constituency");
                model12.setValue(Constituency);
                listProperty.add(model12);


                DataModel model5 = new DataModel();
                model5.setKey("Chiefdom");
                model5.setValue(propertyModel.getChiefdom());
                listProperty.add(model5);

                DataModel model6 = new DataModel();
                model6.setKey("District");
                model6.setValue(propertyModel.getDistrict());
                listProperty.add(model6);


                DataModel model7 = new DataModel();
                model7.setKey("Province");
                model7.setValue(propertyModel.getProvince());
                listProperty.add(model7);

                DataModel model8 = new DataModel();
                model8.setKey("Post Code");
                model8.setValue(propertyModel.getPostcode());
                listProperty.add(model8);


                adapter.notifyDataSetChanged();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String setOccupancyData(JSONObject occupancyObject, JSONObject JSONMainObj, List<DataModel> listOccupancy, DataViewAdapter adapter) {
        String OccupancyType = "";
        try {
            if (occupancyObject != null) {

                SearchOccupancyModel occupancyModel = (SearchOccupancyModel) CommonUtils.getObjectFromJson(occupancyObject.toString().trim(), SearchOccupancyModel.class);


                try {

                    ArrayList<String> mList = new ArrayList<>();

                    String stOccupancies = "";
                    for (int i = 0; i < JSONMainObj.getJSONArray("occupancies").length(); i++) {
                        try {
                            mList.add(JSONMainObj.getJSONArray("occupancies").getJSONObject(i).optString("occupancy_type"));
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }

                    String mFinalStr = getAppendListDataWithSpacialCharacter(mList, ",");

                    OccupancyType = mFinalStr;
                    DataModel model1 = new DataModel();
                    model1.setKey("Occupancy Type");
                    model1.setValue(mFinalStr);
                    listOccupancy.add(model1);
                    LogUtils.showErrorLog("Occupancy Type", "" + occupancyObject.optString("type"));

                    /*TODO adding school type*/
                    // listOccupancy.add(new DataModel("School Type",occupancyObject.isNull("organizational_school_type") ? "": occupancyObject.optString("organizational_school_type")));


                } catch (Exception ex) {
                    ex.printStackTrace();
                }


                if (JSONMainObj.optBoolean("is_organization")) {

                    try {

                        String organization_name = ((JSONMainObj.optString("organization_name") == null) ? "" : "" + JSONMainObj.optString("organization_name"));

                        DataModel model18 = new DataModel();
                        model18.setKey("Organization Name");
                        model18.setValue("" + organization_name);
                        listOccupancy.add(model18);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                    try {

                        String OrganizationType = ((JSONMainObj.optString("organization_type") == null) ? "" : "" + JSONMainObj.optString("organization_type"));

                        DataModel model19 = new DataModel();
                        model19.setKey("Organization Type");
                        model19.setValue("" + OrganizationType);
                        listOccupancy.add(model19);


                        if (OrganizationType.equalsIgnoreCase("School")) {
                            listOccupancy.add(new DataModel("School Type", JSONMainObj.optString("organization_school_type")));

                        }

                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }

                  /*  try {

                        String OrganizationType = ((mMainObject.optString("organization_addresss") == null) ? "" : "" + mMainObject.optString("organization_addresss"));

                        DataModel model110 = new DataModel();
                        model110.setKey("Organization Address");
                        model110.setValue("" + OrganizationType);
                        listLandload.add(model110);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }*/


                } else {

                    DataModel model22 = new DataModel();
                    model22.setKey("Tenant Title");
                    //   model22.setValue(landlordModel.getTitles().getLabel());
                    model22.setValue(occupancyModel.getTitles().getLabel());

                    listOccupancy.add(model22);


                    DataModel model2 = new DataModel();
                    model2.setKey("Tenant First Name");
                    model2.setValue(occupancyModel.getTenantFirstName());
                    listOccupancy.add(model2);


                    DataModel model3 = new DataModel();
                    model3.setKey("Middle Name");
                    if (occupancyModel.getMiddleName() == null || occupancyModel.getMiddleName().trim().equals("")) {
                        model3.setValue("--");
                    } else model3.setValue(occupancyModel.getMiddleName());
                    listOccupancy.add(model3);


                    DataModel model4 = new DataModel();
                    model4.setKey("Surname");
                    model4.setValue(occupancyModel.getSurname());
                    listOccupancy.add(model4);

                }


                DataModel model5 = new DataModel();
                model5.setKey("Mobile Number 1");
                model5.setValue(occupancyModel.getMobile1());
                listOccupancy.add(model5);

                DataModel model6 = new DataModel();
                model6.setKey("Mobile Number 2");
                model6.setValue(occupancyModel.getMobile2());
                listOccupancy.add(model6);

                adapter.notifyDataSetChanged();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return OccupancyType;
    }

    public static void initOccupancyDialog(Activity activity, JSONObject mainJsonObject, List<TitlesItem> list_occupancy_title, String OccupancyType,
                                           List<String> list_occupancy_type, SearchOccupancyModel occupancyModel, ApiRequest apiRequest) {
        LayoutInflater factory = LayoutInflater.from(activity);
        final View deleteDialogView = factory.inflate(R.layout.dialog_edit_occupency_details, null);
        AlertDialog dialogOccupancy = new AlertDialog.Builder(activity).create();
        dialogOccupancy.setView(deleteDialogView);

        WindowManager.LayoutParams params = dialogOccupancy.getWindow().getAttributes();
        params.width = WindowManager.LayoutParams.MATCH_PARENT;
        params.height = WindowManager.LayoutParams.MATCH_PARENT;
        params.gravity = Gravity.CENTER;
        dialogOccupancy.getWindow().setAttributes(params);
        dialogOccupancy.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);

        //root layout
        LinearLayout layoutOrganizationName = deleteDialogView.findViewById(R.id.layoutOrganizationName);
        LinearLayout layoutOrganizationType = deleteDialogView.findViewById(R.id.layoutOrganizationType);
        LinearLayout layoutSchoolType = deleteDialogView.findViewById(R.id.layoutSchoolType);
        LinearLayout layoutTeanantTitle = deleteDialogView.findViewById(R.id.layoutTeanantTitle);
        LinearLayout layoutTeanantFirstName = deleteDialogView.findViewById(R.id.layoutTeanantFirstName);
        LinearLayout layoutTeanantMiddleName = deleteDialogView.findViewById(R.id.layoutTeanantMiddleName);
        LinearLayout layoutTeanantSurname = deleteDialogView.findViewById(R.id.layoutTeanantSurname);

        layoutOrganizationName.setVisibility(View.GONE);
        layoutOrganizationType.setVisibility(View.GONE);
        layoutSchoolType.setVisibility(View.GONE);
        layoutTeanantTitle.setVisibility(View.GONE);
        layoutTeanantFirstName.setVisibility(View.GONE);
        layoutTeanantMiddleName.setVisibility(View.GONE);
        layoutTeanantSurname.setVisibility(View.GONE);


        EditText edt_organization_name = deleteDialogView.findViewById(R.id.edt_organization_name);
        EditText edt_organization_type = deleteDialogView.findViewById(R.id.edt_organization_type);
        EditText edt_first_name = deleteDialogView.findViewById(R.id.edt_first_name);
        EditText edt_middle_name = deleteDialogView.findViewById(R.id.edt_middle_name);
        EditText edt_sur_name = deleteDialogView.findViewById(R.id.edt_sur_name);
        EditText edt_landlord_mobile_1 = deleteDialogView.findViewById(R.id.edt_landlord_mobile_1);
        EditText edt_landlord_mobile_2 = deleteDialogView.findViewById(R.id.edt_landlord_mobile_2);
        EditText edt_school_type = deleteDialogView.findViewById(R.id.edt_school_type);
        Spinner spinner_occupancy_type = deleteDialogView.findViewById(R.id.spinner_occupancy_type);
        Spinner spinner_tenant_title = deleteDialogView.findViewById(R.id.spinner_tenant_title);
        Button btn_save_ = deleteDialogView.findViewById(R.id.btn_save_);

        List<String> title = new ArrayList<>();

        for (TitlesItem item : list_occupancy_title) {
            title.add(item.getLabel());
        }

        ArrayAdapter<String> adapter_type = new ArrayAdapter<String>(activity, android.R.layout.simple_spinner_item, list_occupancy_type);
        adapter_type.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner_occupancy_type.setAdapter(adapter_type);

        ArrayAdapter<String> adapter_title = new ArrayAdapter<String>(activity, android.R.layout.simple_spinner_item, title);
        adapter_title.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner_tenant_title.setAdapter(adapter_title);







        /*setting data with visibility */
        if (mainJsonObject.optBoolean("is_organization")) {

            String organization_name = ((mainJsonObject.optString("organization_name") == null) ? "" : "" + mainJsonObject.optString("organization_name"));
            String OrganizationType = ((mainJsonObject.optString("organization_type") == null) ? "" : "" + mainJsonObject.optString("organization_type"));


            layoutOrganizationName.setVisibility(View.VISIBLE);
            layoutOrganizationType.setVisibility(View.VISIBLE);

            edt_organization_name.setText(organization_name);
            edt_organization_type.setText(OrganizationType);

            if (OrganizationType.equalsIgnoreCase("School")) {
                layoutSchoolType.setVisibility(View.VISIBLE);
                edt_school_type.setText(mainJsonObject.optString("organization_school_type"));

            }


        } else {
            layoutTeanantTitle.setVisibility(View.VISIBLE);
            layoutTeanantFirstName.setVisibility(View.VISIBLE);
            layoutTeanantMiddleName.setVisibility(View.VISIBLE);
            layoutTeanantSurname.setVisibility(View.VISIBLE);

            if (!OccupancyType.isEmpty())
                spinner_occupancy_type.setSelection(list_occupancy_type.indexOf(OccupancyType));


            spinner_tenant_title.setSelection(title.indexOf(occupancyModel.getTitles().getLabel()));

            edt_first_name.setText(occupancyModel.getTenantFirstName());
            edt_middle_name.setText(occupancyModel.getMiddleName());
            edt_sur_name.setText(occupancyModel.getSurname());


        }

        edt_landlord_mobile_1.setText(occupancyModel.getMobile1());
        edt_landlord_mobile_2.setText(occupancyModel.getMobile2());


        dialogOccupancy.show();


        btn_save_.setOnClickListener(v -> {
            HashMap<String, String> req_params = new HashMap<>();

            // FIXME: 20-09-2021
            req_params.put("property_id", "" + occupancyModel.getPropertyId());
            req_params.put("tenant_first_name", "" + edt_first_name.getText().toString());
            req_params.put("middle_name", "" + edt_middle_name.getText().toString());
            req_params.put("surname", "" + edt_sur_name.getText().toString());
            req_params.put("mobile_1", "" + edt_landlord_mobile_1.getText().toString());
            req_params.put("mobile_2", "" + edt_landlord_mobile_2.getText().toString());
            req_params.put("ownerTenantTitle", "" + spinner_tenant_title.getSelectedItem().toString());
            req_params.put("occupancy_type", "" + spinner_occupancy_type.getSelectedItem().toString());
            req_params.put("organizational_school_type", "" + edt_school_type.getText().toString());

            // req_params.put("requested_by", Constant.USERNAME);


            String finalURL = URL_EDIT_OCCUPANCY; // + dataItem.getAssessment().getPropertyId();

            Log.d("request", req_params.toString());
            Log.d("request_url", finalURL);

            apiRequest.callPostFormData(
                    finalURL,
                    req_params,
                    "",
                    "upload_data_occupancy"
            );


        });

    }

    public static List<DataModel> initCouncillorData(Assessment dataItem) {
        List<DataModel> councillor_list = new ArrayList<>();
         councillor_list.add(new DataModel("No Water Supply (Section)", dataItem.getWaterPercentage() + "%"));
         councillor_list.add(new DataModel("No Electricity (Section)", dataItem.getElectricityPercentage() + "%"));
        councillor_list.add(new DataModel("No Waste Management/Services/Points (Ward)", dataItem.getWasteManagementPercentage() + "%"));
        councillor_list.add(new DataModel("No Market (Ward)", dataItem.getMarketPercentage() + "%"));
        councillor_list.add(new DataModel("Hazardous Location/Environment ", dataItem.getHazardousPrecentage() + "%"));
        councillor_list.add(new DataModel("No Drainage", dataItem.getDrainagePercentage() + "%"));
        councillor_list.add(new DataModel("informal_settlement", dataItem.getInformalSettlementPercentage() + "%"));
        councillor_list.add(new DataModel("Difficult Street Access", dataItem.getEasyStreetAccessPercentage() + "%"));
        councillor_list.add(new DataModel("Unpaved/Untarred Street/Road", dataItem.getPavedTarredStreetPercentage() + "%"));
        return councillor_list;
    }


    public static void initAssessmentHistory(Activity activity, SearchPropertyModel mSearchPropertyModel) {
        LinearLayout rootLayoutAssessmentHistory = activity.findViewById(R.id.rootLayoutAssessmentHistory);
        LayoutInflater inflater = LayoutInflater.from(activity);

        String ratePayable = mSearchPropertyModel.getAssessment().getRate_payable()==null ? "0.00" : mSearchPropertyModel.getAssessment().getRate_payable();
        String discountedRatePayable = mSearchPropertyModel.getAssessment().getDiscounted_value()==null ? "0.00" : mSearchPropertyModel.getAssessment().getDiscounted_value();

        List<DataModel> items = new ArrayList<>();


        if (mSearchPropertyModel.getAssessment().getPropertyRateWithoutGst() != null) {
            String value = mSearchPropertyModel.getAssessment().getPropertyRateWithoutGst();
            String valueWithComma = StringUtils.AmountWithComma(value.substring(0, value.indexOf(".")));
            String valueWithOutComma = value.substring(value.indexOf("."), value.length());
            items.add(new DataModel("Assessed Value " + mSearchPropertyModel.getAssessment().getAssessmentYear(), valueWithComma + valueWithOutComma));

        } else {
            items.add(new DataModel("Assessed Value " + mSearchPropertyModel.getAssessment().getAssessmentYear(), ""));
        }

        items.add(new DataModel("Council Adjustment", mSearchPropertyModel.getAssessment().getCouncil_adjustments_parameters()));
        items.add(new DataModel("Net Assessed Value", mSearchPropertyModel.getAssessment().getProperty_net_assessed_vaue()));
        items.add(new DataModel("Rate Payable", NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble(mSearchPropertyModel.getAssessment().getRate_payable()))));
        items.add(new DataModel("Discount(s) Applicable", mSearchPropertyModel.getAssessment().getDiscounted_value()==null ? "0.00" : mSearchPropertyModel.getAssessment().getDiscounted_value()));
        items.add(new DataModel("Discounted Rate Payable", NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble(NumberFormater.Companion.formatToTwoDecimalPlaces(NumberFormater.Companion.parseDouble(ratePayable) - NumberFormater.Companion.parseDouble(discountedRatePayable))))));
        items.add(new DataModel("Arrears Due", mSearchPropertyModel.getAssessment().getArrearDue()));
        items.add(new DataModel("Penalty", mSearchPropertyModel.getAssessment().getPenalty()));
        items.add(new DataModel("Amount Paid (" + mSearchPropertyModel.getAssessment().getAssessmentYear() + ")", mSearchPropertyModel.getAssessment().getAmountPaid()));

        if (activity.findViewById(R.id.tvDiscountedRatePayable1) instanceof  TextView){
            ((TextView) activity.findViewById(R.id.tvDiscountedRatePayable1)).setText(NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble(NumberFormater.Companion.formatToTwoDecimalPlaces(NumberFormater.Companion.parseDouble(ratePayable) - NumberFormater.Companion.parseDouble(discountedRatePayable)))));
        }

        String mBalance = "";

       /* if (mSearchPropertyModel.getAssessment().getBalance() != null && !mSearchPropertyModel.getAssessment().getBalance().isEmpty()) {
            mBalance = mSearchPropertyModel.getAssessment().getBalance();
        } else*/
        mBalance = mSearchPropertyModel.getAssessment().getBalanceDue()==null ? "0.00" : mSearchPropertyModel.getAssessment().getBalanceDue();

        items.add(new DataModel("Amount Due", NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble(mBalance))));

        for (DataModel item : items) {
            View inflatedLayout = inflater.inflate(R.layout.rowview_details, rootLayoutAssessmentHistory, false);
            TextView tvKey = inflatedLayout.findViewById(R.id.tvKey);
            TextView tvValue = inflatedLayout.findViewById(R.id.tvValue);
            tvKey.setText(item.getKey());
            tvValue.setText(item.getValue());
            rootLayoutAssessmentHistory.addView(inflatedLayout);

        }


    }
}
