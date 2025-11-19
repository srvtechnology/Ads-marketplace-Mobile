package com.dpm.payment.activities.cashier;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioGroup;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatRadioButton;
import androidx.core.widget.NestedScrollView;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.NumberFormater;
import com.dpm.payment.R;
import com.dpm.payment.activities.cep.ActivityCep;
import com.dpm.payment.activities.user.ActivityUserLogin;
import com.dpm.payment.models.SearchAssessmentHistoryModel;
import com.dpm.payment.models.SearchResponseModel;
import com.dpm.payment.models.propertydetail.Assessment;
import com.dpm.payment.retrofit.Utills.ApiRequest;
import com.dpm.payment.retrofit.Utills.PART;
import com.dpm.payment.retrofit.Utills.ToastUtils;
import com.dpm.payment.retrofit.interfaces.OnCallBackListner;
import com.dpm.payment.utils.AlertDialogUtils;
import com.dpm.payment.utils.CommonUtils;
import com.dpm.payment.utils.DataUtils;
import com.dpm.payment.utils.Helper;
import com.dpm.payment.utils.LogUtils;
import com.dpm.payment.utils.PrefUtil;
import com.dpm.payment.utils.RestApiRequestListener;
import com.dpm.payment.utils.StringUtils;

import com.dpm.payment.utils.imagePicker.FilePickerListener;
import com.dpm.payment.utils.imagePicker.ImagePicker;
import com.google.gson.Gson;

import org.json.JSONObject;

import java.io.File;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import com.dpm.payment.R;


import static com.dpm.payment.activities.landlord.LandlordPropertyDetailsActivity.KEY_PROPERTY_DETAILS;
import static com.dpm.payment.utils.ConstantData.REQUEST_KEY_PROPERTY_ID;
import static com.dpm.payment.utils.ConstantData.TAG_REQUEST_SEARCH_PROPERTY;
import static com.dpm.payment.utils.RestApiUrl.URL_CASHIER_SAVE_PAYMENT;
import static com.dpm.payment.utils.RestApiUrl.URL_CASHIER_SEARCH_PROPERTY;
import static com.dpm.payment.utils.RestApiUrl.URL_LANDLORD_PROPERTY_LIST;

public class ActivityMainCashierProperty extends AppCompatActivity implements View.OnClickListener, OnCallBackListner {

    final static String KEY_FROM = "form";
    final static String VALUE_FROM_CASHIER = "ActivityMainCashierProperty";
    ProgressDialog progressDialog;
    Context mContext;
    AlertDialog dialog;
    /*toolbar*/
    View activityMain_view_search;
    /*toolbar*/
    TextView toolbar_tv_header;
    EditText activityMain_et_propertyId;
    Button activityMain_bt_search;
    TextView activityUserSearchResult_tv_name;
    Button activityUserSearchResult_bt_view_details;
    TextView activityUserSearchResult_tv_assesment_year, activityUserSearchResult_tv_assesment_year_value, activityUserSearchResult_tv_rate_payable_value, activityUserSearchResult_tv_discount_applicable_value, activityUserSearchResult_tv_arrear, activityUserSearchResult_tv_arrear_value,
            activityUserSearchResult_tv_penalty, activityUserSearchResult_tv_penalty_value, activityUserSearchResult_tv_amount_paid, activityUserSearchResult_tv_amount_paid_value, activityUserSearchResult_tv_balance,
            activityUserSearchResult_tv_balance_value, activityUserSearchResult_tv_paying_amount, activityUserSearchResult_tv_paying_pre_calculate, activityUserSearchResult_tv_discount_rate_payable_value, activityUserSearchResult_tv_council_adjustment_value, activityUserSearchResult_tv_net_assessed_value;
    EditText activityUserSearchResult_et_paying_amount;
    TextView activityUserSearchResult_tv_payment_type;
    RadioGroup activityUserSearchResult_rg_payment_type;
    AppCompatRadioButton activityUserSearchResult_rb_one, activityUserSearchResult_rb_two;
    TextView activityUserSearchResult_tv_total_amount, activityUserSearchResult_tv_total_pre_calculate;
    EditText activityUserSearchResult_et_total_amount;
    TextView activityUserSearchResult_tv_cheque_no;
    EditText activityUserSearchResult_et_cheque_no;
    TextView activityUserSearchResult_tv_payee_name;
    EditText activityUserSearchResult_et_payee_name;
    RecyclerView activityUserSearchResult_rv_dates;
    Button activityOrderDetails_bt_save;
    Button activityMain_bt_searchClear;
    TextView tvInputAmount;
    TextView tvInputAmount2;

    // FIXME: 19-09-2021
    Assessment dataModel;

    static final String KEY_PAYMENT_RECEIPT = "payment_receipt";

    CheckBox checkBox_pensioners_discount, checkBox_disability_discount;


    // FIXME: 19-09-2021
    private ImageView img_physical_receipt_image, img_pensioner_discount_image, img_disability_discount_image;
    private LinearLayout lin_physical_receipt_image, lin_pensioner_discount_image, lin_disability_discount_image;

    /*   private EditText edt_landlord_first_name,edt_landlord_middle_name,
               edt_landlord_surname,edt_landlord_street_number,edt_landlord_street_name,edt_landlord_email,edt_landlord_mobile_1;
   */
    private final int CODE_PHYSICAL = 0;
    private final int CODE_PENSIONER = 1;
    private final int CODE_DISABILITY = 2;

    private File file_physical, file_pensioner, file_disability;

    ApiRequest apiRequest;

    NestedScrollView nested_scroll_view;
    ScrollView scroll_view;

    List<PART> list_file;

    Spinner spin_payment_type, spin_payment_year;


    String balanceDue;

    private com.dpm.payment.utils.imagePicker.ImagePicker imagePicker;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        mContext = this;
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_cashier);
        apiRequest = new ApiRequest(this, this);
        imagePicker = new ImagePicker(this);
        list_file = new ArrayList<>();
        initializeViews();
        initializeListeners();
        initToolbar();
        onClick();
        setOnTextChanges();
        activityMain_view_search.setVisibility(View.GONE);

    }


    private void onClick() {
        activityUserSearchResult_rb_one.setOnCheckedChangeListener((compoundButton, isChecked) -> setChequeVisible(false));
        activityUserSearchResult_rb_two.setOnCheckedChangeListener((compoundButton, b) -> setChequeVisible(true));


    }

    private void setChequeVisible(boolean isVisible) {
        if (isVisible) {
            activityUserSearchResult_et_cheque_no.setEnabled(true);
        } else {
            activityUserSearchResult_et_cheque_no.setEnabled(false);
        }
    }

    private void initToolbar() {
        ImageView ivHome = findViewById(R.id.toolbar_iv_home);
        ivHome.setVisibility(View.GONE);
        AppCompatImageView ivProfile = findViewById(R.id.ivProfile);
        AppCompatImageView ivNotification = findViewById(R.id.ivNotification);
        ivProfile.setOnClickListener(v -> {
            showProfileOrNotification("profile");
        });
        ivNotification.setOnClickListener(v -> {
            showProfileOrNotification("notification");
        });
    }

    private void initializeViews() {

        //  nested_scroll_view = findViewById(R.id.nested_scroll_view);
        scroll_view = findViewById(R.id.scroll_view);
        checkBox_pensioners_discount = findViewById(R.id.checkBox_pensioners_discount);
        checkBox_disability_discount = findViewById(R.id.checkBox_disability_discount);


       /* edt_landlord_first_name = findViewById(R.id.edt_landlord_first_name);
        edt_landlord_middle_name = findViewById(R.id.edt_landlord_middle_name);
        edt_landlord_surname = findViewById(R.id.edt_landlord_surname);
        edt_landlord_street_number = findViewById(R.id.edt_landlord_street_number);
        edt_landlord_street_name = findViewById(R.id.edt_landlord_street_name);
        edt_landlord_email = findViewById(R.id.edt_landlord_email);
        edt_landlord_mobile_1 = findViewById(R.id.edt_landlord_mobile_1);


*/

        img_physical_receipt_image = findViewById(R.id.img_physical_receipt_image);
        img_pensioner_discount_image = findViewById(R.id.img_pensioner_discount_image);
        img_disability_discount_image = findViewById(R.id.img_disability_discount_image);

        lin_physical_receipt_image = findViewById(R.id.lin_physical_receipt_image);
        lin_pensioner_discount_image = findViewById(R.id.lin_pensioner_discount_image);
        lin_disability_discount_image = findViewById(R.id.lin_disability_discount_image);


        // checkBox_pensioners_discount.setEnabled(dataModel.getPensionerDiscount().equalsIgnoreCase("1")? true : false);
        //  checkBox_disability_discount.setEnabled(dataModel.getDisabilityDiscount().equalsIgnoreCase("1")? true : false);


        // FIXME: 19-09-2021

        img_physical_receipt_image.setOnClickListener(v -> OpenCamera(CODE_PHYSICAL));
        img_pensioner_discount_image.setOnClickListener(v -> OpenCamera(CODE_PENSIONER));
        img_disability_discount_image.setOnClickListener(v -> OpenCamera(CODE_DISABILITY));


        toolbar_tv_header = findViewById(R.id.toolbar_tv_header);
        toolbar_tv_header.setText(R.string.search_property);

        activityMain_et_propertyId = findViewById(R.id.activityMain_et_propertyId);


        activityMain_bt_search = findViewById(R.id.activityMain_bt_search);

        activityMain_bt_searchClear = findViewById(R.id.activityMain_bt_searchClear);

        activityMain_view_search = findViewById(R.id.activityMain_view_search);


        activityUserSearchResult_tv_discount_rate_payable_value = findViewById(R.id.activityUserSearchResult_tv_discount_rate_payable_value);
        activityUserSearchResult_tv_council_adjustment_value = findViewById(R.id.activityUserSearchResult_tv_council_adjustment_value);
        activityUserSearchResult_tv_net_assessed_value = findViewById(R.id.activityUserSearchResult_tv_net_assessed_value);
        activityUserSearchResult_tv_name = findViewById(R.id.activityUserSearchResult_tv_name);
        activityUserSearchResult_bt_view_details = findViewById(R.id.activityUserSearchResult_bt_view_details);
        activityUserSearchResult_tv_assesment_year = findViewById(R.id.activityUserSearchResult_tv_assesment_year);
        activityUserSearchResult_tv_assesment_year_value = findViewById(R.id.activityUserSearchResult_tv_assesment_year_value);
        activityUserSearchResult_tv_rate_payable_value = findViewById(R.id.activityUserSearchResult_tv_rate_payable_value);
        activityUserSearchResult_tv_discount_applicable_value = findViewById(R.id.activityUserSearchResult_tv_discount_applicable_value);
        activityUserSearchResult_tv_arrear = findViewById(R.id.activityUserSearchResult_tv_arrear);
        activityUserSearchResult_tv_arrear_value = findViewById(R.id.activityUserSearchResult_tv_arrear_value);
        activityUserSearchResult_tv_penalty = findViewById(R.id.activityUserSearchResult_tv_penalty);
        activityUserSearchResult_tv_penalty_value = findViewById(R.id.activityUserSearchResult_tv_penalty_value);
        activityUserSearchResult_tv_amount_paid = findViewById(R.id.activityUserSearchResult_tv_amount_paid);
        activityUserSearchResult_tv_amount_paid_value = findViewById(R.id.activityUserSearchResult_tv_amount_paid_value);
        activityUserSearchResult_tv_balance = findViewById(R.id.activityUserSearchResult_tv_balance);
        activityUserSearchResult_tv_balance_value = findViewById(R.id.activityUserSearchResult_tv_balance_value);
        activityUserSearchResult_tv_paying_amount = findViewById(R.id.activityUserSearchResult_tv_paying_amount);
        activityUserSearchResult_tv_paying_pre_calculate = findViewById(R.id.activityUserSearchResult_tv_paying_pre_calculate);
        activityUserSearchResult_et_paying_amount = findViewById(R.id.activityUserSearchResult_et_paying_amount);
        activityUserSearchResult_tv_payment_type = findViewById(R.id.activityUserSearchResult_tv_payment_type);
        activityUserSearchResult_rg_payment_type = findViewById(R.id.activityUserSearchResult_rg_payment_type);
        activityUserSearchResult_rb_one = findViewById(R.id.activityUserSearchResult_rb_one);
        activityUserSearchResult_rb_two = findViewById(R.id.activityUserSearchResult_rb_two);
        activityUserSearchResult_tv_total_amount = findViewById(R.id.activityUserSearchResult_tv_total_amount);
        activityUserSearchResult_tv_total_pre_calculate = findViewById(R.id.activityUserSearchResult_tv_total_pre_calculate);
        activityUserSearchResult_et_total_amount = findViewById(R.id.activityUserSearchResult_et_total_amount);
        activityUserSearchResult_tv_cheque_no = findViewById(R.id.activityUserSearchResult_tv_cheque_no);
        activityUserSearchResult_et_cheque_no = findViewById(R.id.activityUserSearchResult_et_cheque_no);
        activityUserSearchResult_tv_payee_name = findViewById(R.id.activityUserSearchResult_tv_payee_name);
        activityUserSearchResult_et_payee_name = findViewById(R.id.activityUserSearchResult_et_payee_name);
        activityUserSearchResult_rv_dates = findViewById(R.id.activityUserSearchResult_rv_dates);
        activityOrderDetails_bt_save = findViewById(R.id.activityOrderDetails_bt_save);
        tvInputAmount = findViewById(R.id.tvInputAmount);
        tvInputAmount2 = findViewById(R.id.tvInputAmount2);

        spin_payment_type = findViewById(R.id.spin_payment_type);
        spin_payment_year = findViewById(R.id.spin_payment_year);
        setSpinYear();
    }

    private void setSpinYear() {
        ArrayList<String> mList = new ArrayList<>();
        mList.add(String.valueOf(Calendar.getInstance().get(Calendar.YEAR)));
        ArrayAdapter aa = new ArrayAdapter(mContext, android.R.layout.simple_spinner_item, mList);
        aa.setDropDownViewResource(android.R.layout.simple_spinner_item);
        spin_payment_year.setAdapter(aa);

    }


    private void setOnTextChanges() {
        try {

       /*     activityUserSearchResult_et_total_amount.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

                }

                @Override
                public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

                    String mUsdStr = activityUserSearchResult_et_total_amount.getText().toString().trim();

                    try {

                        if (activityUserSearchResult_et_total_amount.getText().toString().trim().length() > 0) {
                            tvInputAmount2.setText("Le " + SetCommaText(activityUserSearchResult_et_total_amount.getText().toString().trim()));
                            LogUtils.showErrorLog("Enter String ", " Enter String 1 " + mUsdStr);
                        } else {
                            tvInputAmount2.setText("");
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }

                }

                @Override
                public void afterTextChanged(Editable editable) {

                }
            });*/


            activityUserSearchResult_et_paying_amount.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

                }

                @Override
                public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {


                    String mUsdStr = "";
                    mUsdStr = charSequence.toString();
                    if (TextUtils.isEmpty(mUsdStr)) {
                        activityUserSearchResult_et_total_amount.setText("");
                        tvInputAmount.setText("");
                        tvInputAmount2.setText("");
                        return;
                    }

                    try {
                        if (activityUserSearchResult_et_paying_amount.getText().toString().trim().length() > 0) {
                            tvInputAmount.setText("Le " + NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble(activityUserSearchResult_et_paying_amount.getText().toString().trim())));
                            // FIXME: 13-05-2022
                            double dueAmt = NumberFormater.Companion.parseDouble(balanceDue.replace(",", "")) - NumberFormater.Companion.parseDouble(charSequence.toString().trim());
                            activityUserSearchResult_et_total_amount.setText(NumberFormater.Companion.formatAmount(dueAmt));
                            tvInputAmount2.setText("Le " + NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble((activityUserSearchResult_et_total_amount.getText().toString().trim()))));
                            // LogUtils.showErrorLog("Enter String ", " Enter String 1 " + mUsdStr);

                            spin_payment_type.setSelection(dueAmt == 0 ? 1 : 0);


                        } else {
                            activityUserSearchResult_et_total_amount.setText("");
                            tvInputAmount.setText("");
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }


                }

                @Override
                public void afterTextChanged(Editable editable) {
                }
            });
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }



    private void initializeListeners() {
        activityMain_bt_search.setOnClickListener(this);

        activityMain_bt_searchClear.setOnClickListener(this);
        activityUserSearchResult_bt_view_details.setOnClickListener(this);
        activityOrderDetails_bt_save.setOnClickListener(this);
    }


    @Override
    public void onBackPressed() {
        super.onBackPressed();
        showLogoutDialog(ActivityMainCashierProperty.this);
    }


    //------------------------------------------------- Payment success Alert----------------------------------------------//
    private void showPaymentSuccessAlert() {

        AlertDialog.Builder builder = new AlertDialog.Builder(mContext, R.style.AlertDialogTheme);
        // Set a title for alert dialog
        builder.setTitle("Alert?");

        builder.setCancelable(false);

        // Ask the final question
        builder.setMessage("Successfully submit payment .\nDo you want to continue with next payment ?");

        // Set the alert dialog yes button click listener
        builder.setPositiveButton("OK", (dialog, which) -> {
            // Do something when user clicked the Yes button
            // Set the TextView visibility GONE

            reset();
            activityMain_view_search.setVisibility(View.GONE);


        });

        // Set the alert dialog no button click listener
        builder.setNegativeButton("Cancel", (dialog, which) -> {
            // Do something when No button clicked
            if (dialog != null) {
                dialog.dismiss();
            }
        });

        dialog = builder.create();
        // Display the alert dialog on interface
        dialog.show();
    }

    private void reset() {

        activityMain_et_propertyId.setText("");
        activityMain_et_propertyId.requestFocus();

        activityUserSearchResult_et_paying_amount.setText("");
        activityUserSearchResult_et_total_amount.setText("");
        activityUserSearchResult_et_cheque_no.setText("");
        activityUserSearchResult_et_payee_name.setText("");
    }

    @SuppressLint("NonConstantResourceId")
    @Override
    public void onClick(View v) {
        Intent intent = null;
        switch (v.getId()) {
            case R.id.activityMain_bt_search:
                try {
                    if (checkValidation()) {
                        if (DataUtils.isInternetConnectAvailable(mContext)) {
                            //     startActivityForResult(new Intent(ActivityLogin.this, PickUpLocationActivity.class), LOCATION_REQ);
                            reqSearch();

                        } else {

                            AlertDialogUtils.showInternetConnNotAvailableDialog(ActivityMainCashierProperty.this);
                            //  new CustomDialogWithOkayButton(mContext, mContext.getResources().getString(R.string.internet_connection_not_available), mContext.getResources().getString(R.string.OK), false).show();
                        }
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                break;
            case R.id.activityMain_bt_searchClear:

                reset();
                activityMain_view_search.setVisibility(View.GONE);


                break;

            case R.id.activityUserSearchResult_bt_view_details:
                intent = new Intent(mContext, ActivityMainDetails.class);
                intent.putExtra(KEY_FROM, VALUE_FROM_CASHIER);
                intent.putExtra("property_id", activityMain_et_propertyId.getText().toString().trim());
                intent.putExtra(KEY_PROPERTY_DETAILS + "1", new Gson().toJson(dataModel));
                break;
            case R.id.activityOrderDetails_bt_save:

                try {
                    if (checkValidationPaymentSubmit()) {

                        if (DataUtils.isInternetConnectAvailable(mContext)) {

                            String mPayingAmount = activityUserSearchResult_et_paying_amount.getText().toString();
                            String mTotalAmount = activityUserSearchResult_et_total_amount.getText().toString();
                            String mChequeNo = activityUserSearchResult_et_cheque_no.getText().toString();
                            String mPayeeName = activityUserSearchResult_et_payee_name.getText().toString();
                            String mPenalty = activityUserSearchResult_tv_penalty_value.getText().toString();


                            String payment_made = spin_payment_type.getSelectedItem().toString();
                            String payment_made_year = spin_payment_year.getSelectedItem().toString();


                            LogUtils.showErrorLog("paying_amount ", "paying amount : " + mPayingAmount);
                            LogUtils.showErrorLog("total amount", "total amount : " + mTotalAmount);
                            LogUtils.showErrorLog("cheque_no", "cheque no : " + mChequeNo);
                            LogUtils.showErrorLog("payee_name", "payee name : " + mPayeeName);

                            String mSelectedText = "";
                            if (activityUserSearchResult_rb_one.isChecked()) {
                                mSelectedText = activityUserSearchResult_rb_one.getText().toString().trim();
                            } else if (activityUserSearchResult_rb_two.isChecked()) {
                                mSelectedText = activityUserSearchResult_rb_two.getText().toString().trim();
                            }

                            LogUtils.showErrorLog("Selected PaymentType", "Selected PaymentType : " + mSelectedText);
                            LogUtils.showErrorLog("Penalty amount ", "Penalty amount : " + mPenalty);

                            reqSavePayment(mPayingAmount, mPenalty, mSelectedText, mChequeNo, mPayeeName, payment_made, payment_made_year);

                        } else {
                            AlertDialogUtils.showInternetConnNotAvailableDialog(ActivityMainCashierProperty.this);

                        }
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                break;


        }
        if (intent != null) {
            startActivity(intent);
        }
    }

    private boolean checkValidationPaymentSubmit() {
        boolean flag = false;
        ArrayList<String> errorList = new ArrayList<>();
        //---------------------------------------------------------------------------------------------------//
        String mPayingAmount = activityUserSearchResult_et_paying_amount.getText().toString();
        String mTotalAmount = activityUserSearchResult_et_total_amount.getText().toString();
        String mChequeNo = activityUserSearchResult_et_cheque_no.getText().toString();
        String mPayeeName = activityUserSearchResult_et_payee_name.getText().toString();
        String mPenalty = activityUserSearchResult_tv_penalty_value.getText().toString();

        try {



            /*todo if pensioners OR disability any of them selected then validation is not required  */

            if (!checkBox_pensioners_discount.isChecked() && !checkBox_disability_discount.isChecked()) {
               /* if (activityUserSearchResult_et_paying_amount.length() == 0) {
                    errorList.add("Enter amount paying.");
                }*/

                try {

                    Double mAmount = NumberFormater.Companion.parseDouble(mPayingAmount.trim());
                    if (mAmount > 0 && mAmount < 10) {
                        errorList.add("Paying amount should be minimum 10 le");
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

               /* if (activityUserSearchResult_et_total_amount.length() == 0) {
                    errorList.add("Enter total amount paying.");
                }*/
            }





          /*  try {

                Double mmTotalAmount = NumberFormater.Companion.parseDouble(mTotalAmount.trim());
                if (mmTotalAmount > 0 && mmTotalAmount < 10000) {
                    errorList.add("Total amount should be minimum 10000 le");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }*/

            if (activityUserSearchResult_rb_one.isChecked()) {
                if (activityUserSearchResult_et_cheque_no.length() == 0) {
                    errorList.add("Enter cheque no.");
                }
            }
            /*TODO payee name validation removed*/
            if (activityUserSearchResult_et_paying_amount.length() >0 &&   activityUserSearchResult_et_payee_name.length() == 0) {
                errorList.add("Enter Payee name.");
            }


            if (mChequeNo.trim().length() > 0 && mChequeNo.trim().length() < 5) {
                errorList.add("Cheque number should be 5 digit minimum.");
            }


            if (activityUserSearchResult_tv_penalty_value.length() == 0) {
                errorList.add("Enter Penalty name.");
            }


            if (file_physical == null && !checkBox_pensioners_discount.isChecked() && !checkBox_disability_discount.isChecked()) {
                errorList.add("Please upload the physical image");
            }

            if (checkBox_pensioners_discount.isChecked()) {
                if (file_pensioner == null) {
                    errorList.add("Please upload the pensioner image");
                }
            }

            if (checkBox_disability_discount.isChecked()) {
                if (file_disability == null) {
                    errorList.add("Please upload the disability image");
                }
            }


            if (errorList.size() > 0) {
                Toast.makeText(mContext, errorList.get(0), Toast.LENGTH_SHORT).show();
                flag = false;
            } else {
                flag = true;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return flag;
    }

    /*private void reqSavePayment(String mAmount, String penalty, String payment_type,
                                String cheque_number, String payee_name, String gghg) {

        progressDialog = new ProgressDialog(mContext);

        HashMap<String, String> headers = new HashMap<>();
        headers.put("Accept", "application/json");
        headers.put("Authorization", PrefUtil.getAuthType(mContext) + " " + PrefUtil.getToken(mContext));

        Map<String, String> req_params = new HashMap<>();

        req_params.put("amount", mAmount);
        req_params.put("penalty", "" + penalty);
        req_params.put("payment_type", "" + payment_type.toLowerCase());
        req_params.put("cheque_number", "" + cheque_number);
        req_params.put("payee_name", "" + payee_name);

        String finalURL = URL_CASHIER_SAVE_PAYMENT + activityMain_et_propertyId.getText().toString().trim();
        LogUtils.showErrorLog("header", headers.toString());
        LogUtils.showErrorLog("finalURL == : == ", finalURL);

        new RestApiRequestListener(this, TAG_REQUEST_SAVE_PAYMENT, finalURL, headers, req_params, new RestApiRequestListener.setOnRequestListener() {


            @Override
            public void onPreExecute() {
                progressDialog.setMessage("Saving ...");
                progressDialog.setCancelable(false);
                progressDialog.show();
            }

            @Override
            public void onSuccessListener(String response) {

                if (progressDialog != null) {
                    if (progressDialog.isShowing()) {
                        progressDialog.dismiss();

                        try {

                            LogUtils.showErrorLog("Response of save ", "Response of save " + response);

                            JSONObject mJsonResponse = new JSONObject(response);

                            try {

                                if (!mJsonResponse.optBoolean("success")) {
                                    Toast.makeText(ActivityMainCashierProperty.this, "Some issue occur issue details  " + response, Toast.LENGTH_LONG).show();
                                    return;
                                }

                                if (response == null) {
                                    AlertDialogUtils.showCommonDialog(mContext, "Internal error occur");
                                    return;
                                }
                            } catch (Exception ex) {
                                ex.printStackTrace();
                            }

                            String pdfUrl = "";
                            if (mJsonResponse.has("property") && mJsonResponse.getString("property") != null) {

                                if (mJsonResponse.has("pdfUrl")) {
                                    pdfUrl = mJsonResponse.optString("pdfUrl");
                                }

                                if (mJsonResponse.has("url") && mJsonResponse.getString("url") != null) {

                                    String ReciptUrl = mJsonResponse.optString("url");
                                    Intent mIntent = new Intent(mContext, WebViewPaymentRecipt.class);
                                    mIntent.putExtra(WebViewPaymentRecipt.KEY_PAYMENT_RECEIPT, ReciptUrl);
                                    mIntent.putExtra(WebViewPaymentRecipt.KEY_URL_PDF, pdfUrl);
                                    startActivity(mIntent);
                                } else {
                                    LogUtils.showErrorLog("TAG  ", "TAG : Null URL ");
                                }
                            } else {
                                AlertDialogUtils.showCommonDialog(mContext, "Payment not success Some internal error occur");

                                Toast.makeText(ActivityMainCashierProperty.this, "", Toast.LENGTH_LONG).show();

                            }
                        } catch (Exception ex) {
                            ex.printStackTrace();
                            Toast.makeText(ActivityMainCashierProperty.this, "Some internal error occur ", Toast.LENGTH_LONG).show();

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

    }*/

    // ------------------------- for using search API -----------------------------------------------//
    private boolean checkValidation() {

        boolean b;
        ArrayList<String> errorList = new ArrayList<>();

       /* if (getUserInputNoticeId().length() == 0) {
            errorList.add("Enter your Property Id");
        }*/

        if (getUserInputPropertyId().length() == 0) {
            errorList.add("Enter Property Id and try again.");
        }

        if (errorList.size() > 0) {
            Toast.makeText(mContext, errorList.get(0), Toast.LENGTH_SHORT).show();
            b = false;
        } else {
            b = true;
        }

        return b;
    }

    private String getUserInputPropertyId() {
        return activityMain_et_propertyId.getText().toString().trim();
    }

    /*  private String getUserInputNoticeId() {
          return activityMain_et_noticeNo.getText().toString().trim();
      }
  */
    // --------------------------------------------- Call for Search ----------------------------------------------//

    boolean pensionerStatus = false;
    boolean disabilityStatus = false;

    private void reqSearch() {

        progressDialog = new ProgressDialog(mContext);

        HashMap<String, String> headers = new HashMap<>();
        headers.put("Accept", "application/json");
        headers.put("Authorization", PrefUtil.getAuthType(mContext) + " " + PrefUtil.getToken(mContext));

        Map<String, String> req_params = new HashMap<>();
        //  req_params.put(REQUEST_KEY_OPEN_LOCATION_CODE, getUserInputNoticeId());
        req_params.put(REQUEST_KEY_PROPERTY_ID, getUserInputPropertyId());

        LogUtils.showErrorLog("header", headers.toString());
        LogUtils.showErrorLog("header", req_params.toString());

        Log.d("ApiCallResponse", "url " + URL_LANDLORD_PROPERTY_LIST);
        Log.d("ApiCallResponse", "headers " + headers);

        new RestApiRequestListener(this, TAG_REQUEST_SEARCH_PROPERTY, URL_CASHIER_SEARCH_PROPERTY,
                headers, req_params, new RestApiRequestListener.setOnRequestListener() {


            @Override
            public void onPreExecute() {
                progressDialog.setMessage("Searching...");
                progressDialog.setCancelable(false);
                progressDialog.show();
            }

            @Override
            public void onSuccessListener(String response) {

                /////// SEARCH RESPONSE


                if (progressDialog != null) {
                    if (progressDialog.isShowing()) {
                        progressDialog.dismiss();

                        try {

                            JSONObject mJsonResponse = new JSONObject(response);


                            if (mJsonResponse.has("property") && mJsonResponse.getString("property") == null) {
                                Toast.makeText(ActivityMainCashierProperty.this, "Property not found", Toast.LENGTH_LONG).show();
                            } else {
                                //TODO Edit by Debabrata: Save response to preference.

                                PrefUtil.saveSearchRequest(mContext, response.trim());

                                dataModel = new Gson().fromJson(mJsonResponse.getJSONObject("property").getJSONObject("assessment").toString()
                                        , Assessment.class);

                                activityUserSearchResult_tv_assesment_year.setText("Assessed Value " + dataModel.getAssessmentYear());




                                activityUserSearchResult_tv_assesment_year_value.setText(NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble(dataModel.getCurrentYearAssessmentAmount())));
                                activityUserSearchResult_tv_net_assessed_value.setText(NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble(dataModel.getProperty_net_assessed_value())));

                                try {
                                    activityUserSearchResult_tv_discount_applicable_value.setText(dataModel.getDiscounted_value()==null ?"0.00" : StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(dataModel.getDiscounted_value()))));
                                } catch (Exception ignored) {

                                }


                                // activityUserSearchResult_tv_rate_payable_value.setText(dataModel.getRate_payable_new());


                                try {
                                    activityUserSearchResult_tv_rate_payable_value.setText(NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble(dataModel.getRate_payable())));

                                } catch (Exception ignored) {

                                }
                                Double discountedRatePayable = NumberFormater.Companion.parseDouble(activityUserSearchResult_tv_rate_payable_value.getText().toString().replace(",","")) - NumberFormater.Companion.parseDouble(activityUserSearchResult_tv_discount_applicable_value.getText().toString().replace(",",""));
                                activityUserSearchResult_tv_discount_rate_payable_value.setText(NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble(NumberFormater.Companion.formatToTwoDecimalPlaces(discountedRatePayable))));


                                Helper.ASSESSED_VALUE = dataModel.getProperty_net_assessed_value();
                                Helper.DISCOUNT_APPLICABLE = dataModel.getRate_payable();
                                Helper.RATE_PAYABLE = dataModel.getRate_payable();

                                String discRatePayable = dataModel.getDiscounted_rate_payable();

                              //  activityUserSearchResult_tv_discount_rate_payable_value.setText(StringUtils.AmountWithComma(discRatePayable));

                                //activityUserSearchResult_tv_council_adjustment_value.setText(StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(dataModel.getCouncil_adjustments_parameters()))));
                                if (dataModel.getCouncil_adjustments_parameters() != null)
                                    activityUserSearchResult_tv_council_adjustment_value.setText(dataModel.getCouncil_adjustments_parameters());



                                if (dataModel.getPensionerDiscount().equalsIgnoreCase("0.00"))
                                    pensionerStatus = true;

                                if (dataModel.getDisabilityDiscount().equalsIgnoreCase("0.00"))
                                    disabilityStatus = true;


                                //  boolean pensionerStatus = dataModel.getPensionerDiscount().equalsIgnoreCase("0") ? true : false;
                                //  boolean disabilityStatus = dataModel.getDisabilityDiscount().equalsIgnoreCase("0") ? true : false;


                                checkBox_pensioners_discount.setOnCheckedChangeListener((buttonView, isChecked) -> {

                                    if (pensionerStatus) {
                                        if (isChecked)
                                            lin_pensioner_discount_image.setVisibility(View.VISIBLE);
                                        else
                                            lin_pensioner_discount_image.setVisibility(View.INVISIBLE);
                                    } else {
                                        checkBox_pensioners_discount.setChecked(false);
                                        Toast.makeText(ActivityMainCashierProperty.this, "You have already taken this discount.", Toast.LENGTH_SHORT).show();
                                    }
                                });
                                checkBox_disability_discount.setOnCheckedChangeListener((buttonView, isChecked) -> {
                                    if (disabilityStatus) {
                                        if (isChecked)
                                            lin_disability_discount_image.setVisibility(View.VISIBLE);
                                        else
                                            lin_disability_discount_image.setVisibility(View.INVISIBLE);
                                    } else {
                                        checkBox_disability_discount.setChecked(false);
                                        Toast.makeText(ActivityMainCashierProperty.this, "You have already taken this discount.", Toast.LENGTH_SHORT).show();
                                    }
                                });


                                SearchResponseModel searchResponseModel = (SearchResponseModel) CommonUtils.getObjectFromJson(response, SearchResponseModel.class);
                                if (searchResponseModel.getProperty() != null) {
                                    setData(searchResponseModel, dataModel);
                                }
                            }
                        } catch (Exception ex) {
                            ex.printStackTrace();
                            Toast.makeText(ActivityMainCashierProperty.this, "Property not found.", Toast.LENGTH_LONG).show();
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

    private void setData(SearchResponseModel searchResponseModel, Assessment dataModel) {

        /*,,
                ,,,,*/
        // FIXME: 20-09-2021
       /* edt_landlord_first_name.setText(searchResponseModel.getProperty().getLandlord().getFirstName());
        edt_landlord_middle_name.setText(searchResponseModel.getProperty().getLandlord().getMiddleName());
        edt_landlord_surname.setText(searchResponseModel.getProperty().getLandlord().getSurname());
        edt_landlord_street_number.setText(searchResponseModel.getProperty().getLandlord().getStreetNumber());
        edt_landlord_street_name.setText(searchResponseModel.getProperty().getLandlord().getStreetName());
        edt_landlord_email.setText(""+searchResponseModel.getProperty().getLandlord().getEmail());
        edt_landlord_mobile_1.setText(searchResponseModel.getProperty().getLandlord().getMobile1());
*/

        activityMain_view_search.setVisibility(View.VISIBLE);

        try {
            if (searchResponseModel.getProperty().getIsOrganization()) {
                String mOrganizationName = ((searchResponseModel.getProperty().getOrganizationName() == null) ? "" : "" + searchResponseModel.getProperty().getOrganizationName());
                activityUserSearchResult_tv_name.setText("" + mOrganizationName);
            } else {
                String title = ((searchResponseModel.getProperty().getLandlord().getTitles().getLabel() == null) ? "" : searchResponseModel.getProperty().getLandlord().getTitles().getLabel());
                String mFirstName = ((searchResponseModel.getProperty().getLandlord().getFirstName() == null) ? "" : searchResponseModel.getProperty().getLandlord().getFirstName());
                String lastName = ((searchResponseModel.getProperty().getLandlord().getMiddleName() == null) ? "" : searchResponseModel.getProperty().getLandlord().getMiddleName());
                String surName = ((searchResponseModel.getProperty().getLandlord().getSurname() == null) ? "" : searchResponseModel.getProperty().getLandlord().getSurname());
                activityUserSearchResult_tv_name.setText(title + " " + mFirstName + " " + lastName + " " + surName);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }


        activityUserSearchResult_tv_assesment_year.setText("Assessed Value " + searchResponseModel.getProperty().getAssessment().getAssessmentYear());
      //  activityUserSearchResult_tv_assesment_year_value.setText("" + StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(searchResponseModel.getProperty().getAssessment().getCurrentYearAssessmentAmount()))));


        activityUserSearchResult_tv_arrear_value.setText(StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(searchResponseModel.getProperty().getAssessment().getArrearDue()))));
        activityUserSearchResult_tv_penalty_value.setText(StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(searchResponseModel.getProperty().getAssessment().getPenalty()))));
        activityUserSearchResult_tv_amount_paid.setText("Amount Paid (" + searchResponseModel.getProperty().getAssessment().getAssessmentYear() + ")");
        activityUserSearchResult_tv_amount_paid_value.setText(StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(searchResponseModel.getProperty().getAssessment().getAmountPaid()))));



        try {

            for (SearchAssessmentHistoryModel item : searchResponseModel.getProperty().getAssessmentHistory()) {
                if (item.getAssessmentYear().equalsIgnoreCase("2024")){
                    String mBalance = "";
                   /* if (item.getBalance().contains("E")) {
                        mBalance = StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(item.getBalance())));
                    } else {
                        mBalance = StringUtils.AmountWithComma(StringUtils.roundStringValue(item.getBalance()));
                    }*/

                    mBalance = StringUtils.AmountWithComma(StringUtils.roundStringValue(item.getBalance().toString()));

                    balanceDue = mBalance;

                    activityUserSearchResult_tv_balance_value.setText("" + NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble(mBalance)));
                    activityUserSearchResult_tv_paying_pre_calculate.setText(getString(R.string.amount_due) + "\n" + "Le " + mBalance);
                    activityUserSearchResult_tv_total_pre_calculate.setText(getString(R.string.amount_due) + "\n" + "Le " + mBalance);
                }
            }






        } catch (Exception ex) {
            ex.printStackTrace();
        }


        //activityUserSearchResult_rv_dates = findViewById(R.id.activityUserSearchResult_rv_dates);

    }

    public void showLogoutDialog(Context mCtx) {
        try {
            AlertDialog mAlertDialog;
            AlertDialog.Builder builder = new AlertDialog.Builder(mCtx, R.style.AlertDialogTheme);
            // Set a title for alert dialog
            builder.setTitle("Alert?");

            builder.setCancelable(false);

            // Ask the final question
            builder.setMessage("" + mCtx.getResources().getString(R.string.do_you_want_to_logout));

            // Set the alert dialog yes button click listener
            builder.setPositiveButton("Ok", (dialog, which) -> {
                // Do something when user clicked the Yes button
                // Set the TextView visibility GONE
                dialog.dismiss();

                // PrefUtil.mClearALLData(mContext);

                Intent i = new Intent(ActivityMainCashierProperty.this, ActivityUserLogin.class);
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
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    // FIXME: 19-09-2021
    private void OpenCamera(int code) {
        imagePicker.dispatchTakePictureIntent(code, (path, requestCode) -> {
            if (requestCode == CODE_PHYSICAL) {

                View targetView = findViewById(R.id.layout_photo_upload);
                targetView.getParent().requestChildFocus(targetView,targetView);

                img_physical_receipt_image.setImageURI(Uri.fromFile(new File(path)));
                file_physical = new File(path);
                list_file.add(new PART("physical_receipt_image", file_physical));
            }
            else if (requestCode == CODE_PENSIONER) {

                file_pensioner = new File(path);
                img_pensioner_discount_image.setImageURI(Uri.fromFile(new File(path)));
                list_file.add(new PART("pensioner_discount_image", file_pensioner));
            }
            else if (requestCode == CODE_DISABILITY) {
                file_disability = new File(path);
                img_disability_discount_image.setImageURI(Uri.fromFile(new File(path)));
                list_file.add(new PART("disability_discount_image", file_disability));
            }
        });


    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode,
                                    Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        imagePicker.onActivityResult(requestCode, resultCode, data);
        if (resultCode == RESULT_OK) {


        }

    }


    private void reqSavePayment(String mAmount, String penalty, String payment_type,
                                String cheque_number, String payee_name, String payment_made, String payment_made_year) {

        if (!checkBox_pensioners_discount.isChecked()) {
            for (PART item : list_file) {
                if (item.getKey().equalsIgnoreCase("pensioner_discount_image")) {
                    list_file.remove(list_file.indexOf(item));
                    break;
                }
            }
        }

        if (!checkBox_disability_discount.isChecked()) {
            for (PART item : list_file) {
                if (item.getKey().equalsIgnoreCase("disability_discount_image")) {
                    list_file.remove(list_file.indexOf(item));
                    break;
                }
            }
        }

        Log.d("list_file", list_file.size() + "");


        payment_made = spin_payment_type.getSelectedItem().toString();
        payment_made_year = spin_payment_year.getSelectedItem().toString();

        progressDialog = new ProgressDialog(mContext);

        HashMap<String, String> headers = new HashMap<>();
        headers.put("Accept", "application/json");
        headers.put("Authorization", PrefUtil.getAuthType(mContext) + " " + PrefUtil.getToken(mContext));

        HashMap<String, String> req_params = new HashMap<>();


        req_params.put("amount", mAmount);
        req_params.put("penalty", "" + penalty);
        req_params.put("payment_type", "" + payment_type.toLowerCase());
        req_params.put("cheque_number", "" + cheque_number);
        req_params.put("payee_name", "" + payee_name);
        req_params.put("payment_made", "" + payment_made);
        req_params.put("payment_made_year", "" + payment_made_year);
        // FIXME: 20-09-2021
      /*  req_params.put("landlord_first_name", "" + edt_landlord_first_name.getText().toString());
        req_params.put("landlord_middle_name", "" + edt_landlord_middle_name.getText().toString());
        req_params.put("landlord_surname", "" + edt_landlord_surname.getText().toString());
        req_params.put("landlord_street_number", "" + edt_landlord_street_number.getText().toString());
        req_params.put("landlord_street_name", "" + edt_landlord_street_name.getText().toString());
        req_params.put("landlord_email", "" + edt_landlord_email.getText().toString());
        req_params.put("landlord_mobile_1", "" + edt_landlord_mobile_1.getText().toString());
*/
        String finalURL = URL_CASHIER_SAVE_PAYMENT + activityMain_et_propertyId.getText().toString().trim();
        LogUtils.showErrorLog("header", headers.toString());
        LogUtils.showErrorLog("finalURL == : == ", finalURL);
        LogUtils.showErrorLog("params == : == ", req_params.toString());

      /*  new RestApiRequestListener(this, TAG_REQUEST_SAVE_PAYMENT, finalURL, headers,
                req_params, new RestApiRequestListener.setOnRequestListener() {


            @Override
            public void onPreExecute() {
                progressDialog.setMessage("Saving ...");
                progressDialog.setCancelable(false);
                progressDialog.show();
            }

            @Override
            public void onSuccessListener(String response) {

                if (progressDialog != null) {
                    if (progressDialog.isShowing()) {
                        progressDialog.dismiss();

                        try {

                            LogUtils.showErrorLog("Response of save ", "Response of save " + response);

                            JSONObject mJsonResponse = new JSONObject(response);

                      */
        /*  try {

                            if (!mJsonResponse.optBoolean("success")) {
                                Toast.makeText(ActivityMainCashierProperty.this, "Some issue occur issue details  " +response, Toast.LENGTH_LONG).show();
                                return;
                            }

                            if(response==null)
                            {
                                AlertDialogUtils.showCommonDialog(mContext,"Internal error occur");
                                return;
                            }
                        }catch (Exception ex)
                        {
                            ex.printStackTrace();
                        }
                    */
        /*
                            String pdfUrl = "";
                            if (mJsonResponse.has("property") && mJsonResponse.getString("property") != null) {

                                if (mJsonResponse.has("pdfUrl")) {
                                    pdfUrl = mJsonResponse.optString("pdfUrl");
                                }

                                if (mJsonResponse.has("url") && mJsonResponse.getString("url") != null) {

                                    String ReciptUrl = mJsonResponse.optString("url");
                                    Intent mIntent = new Intent(mContext, WebViewPaymentRecipt.class);
                                    mIntent.putExtra(WebViewPaymentRecipt.KEY_PAYMENT_RECEIPT, ReciptUrl);
                                    mIntent.putExtra(WebViewPaymentRecipt.KEY_URL_PDF, pdfUrl);
                                    startActivity(mIntent);
                                } else {
                                    LogUtils.showErrorLog("TAG  ", "TAG : Null URL ");
                                }
                            } else {
                                AlertDialogUtils.showCommonDialog(mContext, "Payment not success Some internal error occur");

                                Toast.makeText(ActivityMainCashierProperty.this, "", Toast.LENGTH_LONG).show();

                            }
                        } catch (Exception ex) {
                            ex.printStackTrace();
                            Toast.makeText(ActivityMainCashierProperty.this, "Some internal error occur ", Toast.LENGTH_LONG).show();

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
        }).request();*/

        apiRequest.callMultiFileUpload(
                finalURL,
                req_params,
                list_file,
                PrefUtil.getAuthType(mContext) + " " + PrefUtil.getToken(mContext),
                "upload_data"
        );

    }

    @Override
    public void OnCallBackSuccess(String tag, String response) {

        if (tag.equalsIgnoreCase("upload_data")) {
            Log.d("response", response.toString());
            Toast.makeText(ActivityMainCashierProperty.this, "Success", Toast.LENGTH_LONG).show();
        /*    file_disability=null;
            file_physical=null;
            file_pensioner=null;
            lin_pensioner_discount_image.setVisibility(View.INVISIBLE);
            lin_disability_discount_image.setVisibility(View.INVISIBLE);
            img_physical_receipt_image.setImageDrawable(getDrawable(R.drawable.placeholder));
            img_disability_discount_image.setImageDrawable(getDrawable(R.drawable.placeholder));
            img_pensioner_discount_image.setImageDrawable(getDrawable(R.drawable.placeholder));*/

            img_physical_receipt_image.setImageDrawable(getDrawable(R.drawable.placeholder));
            img_pensioner_discount_image.setImageDrawable(getDrawable(R.drawable.placeholder));
            img_disability_discount_image.setImageDrawable(getDrawable(R.drawable.placeholder));

            checkBox_disability_discount.setChecked(false);
            checkBox_pensioners_discount.setChecked(false);

            activityUserSearchResult_et_paying_amount.setText("");
            activityUserSearchResult_et_total_amount.setText("");
            activityUserSearchResult_et_cheque_no.setText("");
            activityUserSearchResult_et_payee_name.setText("");
            spin_payment_year.setSelection(0);
            spin_payment_type.setSelection(0);


            try {

                LogUtils.showErrorLog("Response of save ", "Response of save " + response);

                JSONObject mJsonResponse = new JSONObject(response);

                try {

                  /*  if (!mJsonResponse.optBoolean("success")) {
                        Toast.makeText(ActivityMainCashierProperty.this, "Some issue occur issue details  " +response, Toast.LENGTH_LONG).show();
                        return;
                    }*/

                    if (response == null) {
                        AlertDialogUtils.showCommonDialog(mContext, "Internal error occur");
                        return;
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                String pdfUrl = "";
                if (mJsonResponse.has("property") && mJsonResponse.getString("property") != null) {

                    if (mJsonResponse.has("pdfUrl")) {
                        pdfUrl = mJsonResponse.optString("pdfUrl");
                    }

                    if (mJsonResponse.has("url") && mJsonResponse.getString("url") != null) {

                        String ReciptUrl = mJsonResponse.optString("url");
                        Intent mIntent = new Intent(mContext, WebViewPaymentRecipt.class);
                        mIntent.putExtra(WebViewPaymentRecipt.KEY_PAYMENT_RECEIPT, ReciptUrl);
                        mIntent.putExtra(WebViewPaymentRecipt.KEY_URL_PDF, pdfUrl);
                        startActivity(mIntent);
                    } else {
                        LogUtils.showErrorLog("TAG  ", "TAG : Null URL ");
                    }
                } else {
                    AlertDialogUtils.showCommonDialog(mContext, "Payment not success Some internal error occur");

                    Toast.makeText(ActivityMainCashierProperty.this, "", Toast.LENGTH_LONG).show();

                }
            } catch (Exception ex) {
                ex.printStackTrace();
                Toast.makeText(ActivityMainCashierProperty.this, "Some internal error occur ", Toast.LENGTH_LONG).show();

            }
        }
    }

    @Override
    public void OnCallBackError(String tag, String error, int i) {
        Log.d("response", error.toString());
        LogUtils.showErrorLog("reqNormalLogin", error);
    }

    private void showProfileOrNotification(String type) {
        Intent mIntent = new Intent(mContext, ActivityCep.class);
        mIntent.putExtra("type", type);
        startActivity(mIntent);
    }

}
