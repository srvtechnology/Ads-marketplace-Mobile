package com.dpm.payment.activities.cashier;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.core.content.ContextCompat;
import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.NumberFormater;
import com.dpm.payment.TabDataInitializer;
import com.dpm.payment.activities.WebViewActivity;
import com.dpm.payment.activities.cep.ActivityCep;
import com.dpm.payment.activities.landlord.LandlordPropertyViewDetails;
import com.dpm.payment.activities.user.LandlordResponseModel;
import com.dpm.payment.adapters.AssessmentHistoryAdapter;
import com.dpm.payment.adapters.CashierImageAdapter;
import com.dpm.payment.adapters.DataViewAdapter;
import com.dpm.payment.adapters.GeoRegistryDataAdapter;
import com.dpm.payment.adapters.ImageAdapter;
import com.dpm.payment.adapters.ImageTextAdapter;
import com.dpm.payment.adapters.PropertyImageAdapter;
import com.dpm.payment.adapters.ReceiptAdapter;
import com.dpm.payment.adapters.TransactionDetailAdapter;
import com.dpm.payment.interfaces.OnItemClickListener;
import com.dpm.payment.models.AssessmentHistory;
import com.dpm.payment.models.DataModel;
import com.dpm.payment.models.GeoRegistryModel;
import com.dpm.payment.models.MeterDetailsModel;
import com.dpm.payment.models.OccupancyModel.OccupancyTypeResponse;
import com.dpm.payment.models.OccupancyModel.TitlesItem;
import com.dpm.payment.models.SearchAssessmentModel;
import com.dpm.payment.models.SearchLandlordModel;
import com.dpm.payment.models.SearchOccupancyModel;
import com.dpm.payment.models.SearchPropertyModel;
import com.dpm.payment.models.TransactionModel;
import com.dpm.payment.models.propertydetail.Assessment;
import com.dpm.payment.models.receipt.LandLordReceiptResponse;
import com.dpm.payment.models.receipt.ReceiptResponse;
import com.dpm.payment.retrofit.Utills.ApiRequest;
import com.dpm.payment.retrofit.Utills.PART;
import com.dpm.payment.retrofit.interfaces.OnCallBackListner;
import com.dpm.payment.utils.CommonUtils;
import com.dpm.payment.utils.DownloadManager;
import com.dpm.payment.utils.DownloadPdfTask;
import com.dpm.payment.utils.LogUtils;
import com.dpm.payment.utils.PrefUtil;
import com.dpm.payment.utils.RestApiRequestListener;
import com.dpm.payment.utils.RestApiUrl;
import com.dpm.payment.utils.StringUtils;
import com.github.dhaval2404.imagepicker.ImagePicker;
import com.google.gson.Gson;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.MultiplePermissionsReport;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.multi.MultiplePermissionsListener;
import com.dpm.payment.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.dpm.payment.activities.landlord.LandlordPropertyDetailsActivity.KEY_PROPERTY_DETAILS;
import static com.dpm.payment.utils.ConstantData.TAG_LAND_LORD_RECEIPT;
import static com.dpm.payment.utils.RestApiUrl.URL_CASHIER_LANDLORD_EDIT_PROFILE;
import static com.dpm.payment.utils.RestApiUrl.URL_LANDLORD_PROPERTY_APPROVE;
import static com.dpm.payment.utils.RestApiUrl.URL_LANDLORD_RECEIPT;
import static com.dpm.payment.utils.RestApiUrl.URL_OCCUPANCY_TYPE;
import static com.dpm.payment.utils.StringUtils.getAppendListDataWithSpacialCharacter;

// Cashier login
public class ActivityMainDetails extends AppCompatActivity implements View.OnClickListener, OnCallBackListner {

    final static String VALUE_FROM_CASHIER = "ActivityMainCashierProperty";
    final static String KEY_FROM = "form";
    final static String VALUE_FROM_LANDLORD = "ActivityMainUserProperty";
    private static final int CODE_VERIFICATION_DOCUMENT = 100;
    private static final int CODE_ADDRESS_PROOF = 101;
    final int KEY_TYPE_LAND = 1;
    final int KEY_TYPE_CASHIER = 2;
    Context mContext;
    /*toolbar*/
    AlertDialog dialog;
    /*toolbar*/
    TextView toolbar_tv_header;
    ImageView toolbar_iv_home, toolbar_iv_search;
    //TODO Landload Ui By Debabrata
    TextView activitySearchDetails_tv_property_images, activitySearchDetails_tv_rate_payable, activitySearchDetails_tv_assessment_history, activitySearchDetails_tv_landlord_details, activitySearchDetails_tv_property_details, activitySearchDetails_tv_occupancy_details,
            activitySearchDetails_tv_assessment_details, activitySearchDetails_tv_geo_registry_details,
            activitySearchDetails_tv_councillor_adjustment, activitySearchDetails_tv_cashier_receipt,
            activitySearchDetails_tv_council_discount, activitySearchDetails_tv_government_policy, tvPensionerDiscount, tvDisabilityDiscount, tvDiscountedRatePayable,
            activitySearchDetails_tv_demand_note, tvDownloadDemandNote,tvDiscountedRatePayable1;


    Boolean expand_property_image = false, expand__rate_payable = false, expand_assessment_history = false, expand_landlord_details = false, expand_property_details = false,
            expand_occupancy_details = false, expand_assessment_details = false, expand_geo_registry_details = false, expand_payment_trans_details = false,
            expand_councillor_adjustment = false, expand_cashier_receipt_details = false, expand_pensioner_receipt_details = false, expand_disability_receipt_details = false,
            expand_council_discount = false, expand_government_policy = false, expand_demand_note = false;


    View include_property_images, include_tv_rate_payable, include_assessment_history, include_landlord_details, include_property_details, include_occupancy_details, include_assessment_details, include_geo_registry_details,
            include_councillor_adjustment, include_tv_cashier_receipt, include_tv_pensioner_receipt, include_tv_disability_receipt,
            include_tv_council_discount, include_tv_government_policy, include_search_details_demand_note;
    Spinner spnrDemandNoteYear;

    View include_payment_details;
    ImageView ivProfilePicLandload;
    //TODO Property UI By Debabrata
    RecyclerView rvLandload;
    List<DataModel> listLandload = new ArrayList<>();
    DataViewAdapter adapterLandload;
    //TODO Occupancy Ui By Debabrata
    RecyclerView rvProperty;
    List<DataModel> listProperty = new ArrayList<>();
    DataViewAdapter adapterProperty;
    //TODO Assessment Ui By Debabrata
    RecyclerView rvOccupancy;
    List<DataModel> listOccupancy = new ArrayList<>();
    DataViewAdapter adapterOccupancy;
    //TODO Geo Registry Ui By Debabrata
    RecyclerView rvAssesment;
    RecyclerView rvRatePayable;
    List<DataModel> listAssessment = new ArrayList<>();
    DataViewAdapter adapterAssessment;

    //TODO Assesment Geo Registry Ui By Debabrata
    TextView tvDigitalAddress1, tvDigitalAddress2;
    RecyclerView rvGeoregistry, rvGeoRegitryImg;
    List<DataModel> listGeoregistry = new ArrayList<>();
    GeoRegistryDataAdapter adapterGeoregistry;
    List<String> listGeoRegitryImg = new ArrayList<>();
    ImageTextAdapter adapterGeoRegistryImg;


    RecyclerView rvAssessmentImg;

    //-----------------------------------------//
    List<String> listAssessmentImg = new ArrayList<>();
    ImageAdapter adapterAssessmentImg;
    TextView tv_assesment_year_value;
    TextView AssesmentAmount;
    TextView tvPenaltyValue;
    TextView amountPaid;
    TextView tv_dueValue;
    TextView tvPenalty;
    TextView tvarrears;
    int TYPE_OF_REQ = 0;
    JSONObject JsonObject;

    List<TransactionModel> listPayment = new ArrayList<>();
    TransactionDetailAdapter adapterTransaction;
    RecyclerView rvPayment;
    RecyclerView rvAssessmentHistory;
    TextView activitySearchDetails_tv_payment;
    ArrayList<MeterDetailsModel> mListDataMeterDetails = new ArrayList<>();

    ArrayList<AssessmentHistory> mListAssessmentHistory = new ArrayList<>();

    AssessmentHistoryAdapter mAssessmentHistoryAdapter;
    // FIXME: 20-09-2021
    Assessment dataItem;

    private RecyclerView recyclerview_image_cashier, recyclerview_image_disability, recyclerview_image_pensioner, rv_councillor_adjustment, rv_government_policy, recyclerview_image_property;
    ;

    // FIXME: 23-09-2021
    AlertDialog dialogLandlord;
    AlertDialog dialogOccupancy;

    ApiRequest apiRequest;

    Button btn_edit_landlord, btn_edit_property_details, btn_edit_occupancy_details;

    // FIXME: 08-10-2021
    ImageView img_verification_document, img_address_proof;
    File file_verification_document, file_address_proof;
    TextView edt_note_id_proof, edt_note_address_proof;
    LinearLayout lin_id_proof, lin_address_proof;

    String old_street_flag = "0";

    SearchPropertyModel propertyModel;
    AlertDialog dialogLandlordProperty;

    ImageView img_address_proof_property, img_lin_conveyance_capture_property;
    LinearLayout lin_address_proof_property, lin_conveyance_capture_property;

    private static final int CODE_ADDRESS_PROOF_PROPERTY = 103;
    private static final int CODE_CONVEYANCE_CAPTURE_PROPERTY = 104;

    List<PART> list_file_landlord = new ArrayList<>();
    HashMap<String, File> list_map_landlord = new HashMap<>();
    String old_street_flag_landlord = "0";

    List<PART> list_file_landlord_property = new ArrayList<>();
    HashMap<String, File> list_map_landlord_property = new HashMap<>();
    String old_street_flag_property = "0";

    File file_address_proof_property, file_conveyance_capture_property;

    RecyclerView recycler_view_receipt;

    List<String> list_occupancy_type;
    List<TitlesItem> list_occupancy_title;


    String OccupancyType = "";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        mContext = this;
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search_user_details);
        apiRequest = new ApiRequest(this, this);

        getOccupancyType();

        initializeViews();
        initializeListeners();
        initToolbar();

        setData();
        getRecipientDemandNote();

        //    setDrawerProfile(PrefUtils.getProfile(mContext));
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle outState, @NonNull PersistableBundle outPersistentState) {
        super.onSaveInstanceState(outState, outPersistentState);
    }

    private void initToolbar() {
        ImageView ivHome = findViewById(R.id.toolbar_iv_home);

        AppCompatImageView ivProfile = findViewById(R.id.ivProfile);
        AppCompatImageView ivNotification = findViewById(R.id.ivNotification);
        ivProfile.setOnClickListener(v -> {
            showProfileOrNotification("profile");
        });
        ivNotification.setOnClickListener(v -> {
            showProfileOrNotification("notification");
        });
        ivHome.setOnClickListener(v -> {
            onBackPressed();
        });
    }

    private void setData() {

        try {

            getReceipt();

            dataItem = new Gson().fromJson(getIntent().getStringExtra(KEY_PROPERTY_DETAILS + "1"), Assessment.class);


            String mTesting = this.getIntent().getStringExtra(KEY_FROM);

            JsonObject = new JSONObject(PrefUtil.getSearchRequest(mContext));
            setLandloadData(JsonObject.getJSONObject("property").optJSONObject("landlord"), JsonObject.getJSONObject("property"));
            setOccupancyData(JsonObject.getJSONObject("property").optJSONObject("occupancy"), JsonObject.getJSONObject("property"));
            try {
                if (JsonObject.getJSONObject("property").optJSONArray("payments").length() > 0) {
                    setTransactionData(JsonObject.getJSONObject("property").optJSONArray("payments"));
                    activitySearchDetails_tv_payment.setVisibility(View.VISIBLE);

                } else {

                    activitySearchDetails_tv_payment.setVisibility(View.GONE);
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }


            setAssessmentData(JsonObject.getJSONObject("property").optJSONObject("assessment"), dataItem);
            setGeoRegistryData(JsonObject.getJSONObject("property").optJSONObject("geo_registry"), JsonObject.getJSONObject("property"));
            setMeterData(JsonObject.getJSONObject("property"));
            setPropertyData(JsonObject.getJSONObject("property"));


            TabDataInitializer.initAssessmentHistory(this, (SearchPropertyModel) CommonUtils.getObjectFromJson(JsonObject.getJSONObject("property").toString(), SearchPropertyModel.class));
            initCouncillorAdjustment();
            initGovernmentPolicy();
            // initAdjustedPayable(JsonObject.getString("discounted_value"));

            List<TransactionModel> pensionerImages = new ArrayList<TransactionModel>();
            List<TransactionModel> disabilityImages = new ArrayList<TransactionModel>();

            String disability_discount = "";
            String pensioner_discount = "";


            if (JsonObject.getJSONObject("property").getJSONArray("assessment_history").length() > 0) {
                disability_discount = JsonObject.getJSONObject("property").getJSONArray("assessment_history").getJSONObject(0).getString("disability_discount");
                pensioner_discount = JsonObject.getJSONObject("property").getJSONArray("assessment_history").getJSONObject(0).getString("pensioner_discount");
            }

            if (disability_discount == null || disability_discount.equalsIgnoreCase("")) {
                disability_discount = "0";
            }

            if (pensioner_discount == null || pensioner_discount.equalsIgnoreCase("")) {
                pensioner_discount = "0";
            }


            if (JsonObject.getJSONObject("pensioner_image_path").getString("pensioner_discount_image_path") != null) {
                TransactionModel transactionModel = new TransactionModel();
                transactionModel.setPensioner_discount_image_path(JsonObject.getJSONObject("pensioner_image_path").getString("pensioner_discount_image_path"));
                transactionModel.setPensioner_discount_approve(pensioner_discount);
                pensionerImages.add(transactionModel);
                initPensionerImage(pensionerImages);
            }

            if (JsonObject.getJSONObject("disability_image_path").getString("disability_discount_image_path") != null) {
                TransactionModel transactionModel1 = new TransactionModel();
                transactionModel1.setDisability_discount_image_path(JsonObject.getJSONObject("disability_image_path").getString("disability_discount_image_path"));

                transactionModel1.setDisability_discount_approve(disability_discount);
                disabilityImages.add(transactionModel1);
                initDisabilityImage(disabilityImages);
            }


        } catch (Exception e) {
            e.printStackTrace();
        }


    }


    private void initializeViews() {

        //----------------------------------------------------------------------------------//

        btn_edit_landlord = findViewById(R.id.btn_edit_landlord);
        btn_edit_property_details = findViewById(R.id.btn_edit_property_details);
        btn_edit_occupancy_details = findViewById(R.id.btn_edit_occupancy_details);
        // btn_edit_property_details.setVisibility(View.GONE);

        recyclerview_image_property = findViewById(R.id.recyclerview_image_property);
        recyclerview_image_cashier = findViewById(R.id.recyclerview_image_cashier);
        recycler_view_receipt = findViewById(R.id.recycler_view_receipt);
        recyclerview_image_disability = findViewById(R.id.recyclerview_image_disability);
        recyclerview_image_pensioner = findViewById(R.id.recyclerview_image_pensioner);


        recyclerview_image_property.setHasFixedSize(true);
        recyclerview_image_property.setFocusable(false);


        /*recyclerview_image_cashier.setHasFixedSize(true);
        recyclerview_image_cashier.setFocusable(false);*/

        //   recyclerview_image_disability.setHasFixedSize(true);
        //   recyclerview_image_disability.setFocusable(false);
//
        //   recyclerview_image_pensioner.setHasFixedSize(true);
        //   recyclerview_image_pensioner.setFocusable(false);


        tv_assesment_year_value = findViewById(R.id.activityDetailsAssesmentHistory_tv_assesment_year_value);

        AssesmentAmount = findViewById(R.id.activityDetailsAssesmentHistory_tv_arrear_value);
        tvPenaltyValue = findViewById(R.id.activityDetailsAssesmentHistory_tv_amount_paid_value);
        amountPaid = findViewById(R.id.activityDetailsAssesmentHistory_tv_balance_value);
        tv_dueValue = findViewById(R.id.activityDetailsAssesmentHistory_tv_due_value);
        tvarrears = findViewById(R.id.activityDetailsAssesmentHistory_tv_penalty_value);


        //--------------------------------------------------------------------------------//

        toolbar_tv_header = findViewById(R.id.toolbar_tv_header);
        toolbar_tv_header.setText(R.string.details);

        toolbar_iv_home = findViewById(R.id.toolbar_iv_home);
        toolbar_iv_home.setVisibility(View.VISIBLE);
        toolbar_iv_search = findViewById(R.id.toolbar_iv_search);


        activitySearchDetails_tv_property_images = findViewById(R.id.activitySearchDetails_tv_property_images);
        activitySearchDetails_tv_rate_payable = findViewById(R.id.activitySearchDetails_tv_rate_payable);
        activitySearchDetails_tv_assessment_history = findViewById(R.id.activitySearchDetails_tv_assessment_history);
        activitySearchDetails_tv_landlord_details = findViewById(R.id.activitySearchDetails_tv_landlord_details);
        activitySearchDetails_tv_assessment_details = findViewById(R.id.activitySearchDetails_tv_assessment_details);
        activitySearchDetails_tv_property_details = findViewById(R.id.activitySearchDetails_tv_property_details);
        activitySearchDetails_tv_occupancy_details = findViewById(R.id.activitySearchDetails_tv_occupancy_details);
        activitySearchDetails_tv_geo_registry_details = findViewById(R.id.activitySearchDetails_tv_geo_registry_details);
        activitySearchDetails_tv_cashier_receipt = findViewById(R.id.activitySearchDetails_tv_cashier_receipt);
        // activitySearchDetails_tv_pensioner_receipt = findViewById(R.id.activitySearchDetails_tv_pensioner_receipt);
        // activitySearchDetails_tv_disability_receipt = findViewById(R.id.activitySearchDetails_tv_disability_receipt);
        activitySearchDetails_tv_councillor_adjustment = findViewById(R.id.activitySearchDetails_tv_councillor_adjustment);
        activitySearchDetails_tv_council_discount = findViewById(R.id.activitySearchDetails_tv_council_discount);
        activitySearchDetails_tv_government_policy = findViewById(R.id.activitySearchDetails_tv_government_policy);
        tvPensionerDiscount = findViewById(R.id.tvPensionerDiscount);
        tvDisabilityDiscount = findViewById(R.id.tvDisabilityDiscount);
        tvDiscountedRatePayable = findViewById(R.id.tvDiscountedRatePayable);

        activitySearchDetails_tv_payment = findViewById(R.id.activitySearchDetails_tv_payment);


        include_tv_rate_payable = findViewById(R.id.include_tv_rate_payable);
        include_property_images = findViewById(R.id.include_property_images);
        include_assessment_history = findViewById(R.id.include_assessment_history);
        include_landlord_details = findViewById(R.id.include_landlord_details);
        include_property_details = findViewById(R.id.include_property_details);
        include_occupancy_details = findViewById(R.id.include_occupancy_details);
        include_assessment_details = findViewById(R.id.include_assessment_details);
        include_geo_registry_details = findViewById(R.id.include_geo_registry_details);
        include_tv_cashier_receipt = findViewById(R.id.include_tv_cashier_receipt);
        // include_tv_pensioner_receipt = findViewById(R.id.include_tv_pensioner_receipt);
        // include_tv_disability_receipt = findViewById(R.id.include_tv_disability_receipt);
        include_councillor_adjustment = findViewById(R.id.include_councillor_adjustment);
        include_tv_council_discount = findViewById(R.id.include_tv_council_discount);
        include_tv_government_policy = findViewById(R.id.include_tv_government_policy);


        include_payment_details = findViewById(R.id.include_payment_details);


        activitySearchDetails_tv_geo_registry_details = findViewById(R.id.activitySearchDetails_tv_geo_registry_details);
        activitySearchDetails_tv_geo_registry_details = findViewById(R.id.activitySearchDetails_tv_geo_registry_details);
        activitySearchDetails_tv_geo_registry_details = findViewById(R.id.activitySearchDetails_tv_geo_registry_details);
        activitySearchDetails_tv_geo_registry_details = findViewById(R.id.activitySearchDetails_tv_geo_registry_details);
        activitySearchDetails_tv_demand_note = findViewById(R.id.activitySearchDetails_tv_demand_note);
        spnrDemandNoteYear = findViewById(R.id.spnrDemandNoteYear);
        include_search_details_demand_note = findViewById(R.id.include_search_details_demand_note);
        tvDownloadDemandNote = findViewById(R.id.tvDownloadDemandNote);
        tvDiscountedRatePayable1 = findViewById(R.id.tvDiscountedRatePayable1);
        initLandlordView();
        initPropertyView();
        initOccupancyView();
        initAssessmentView();
        initGeoregistryView();
        initPaymentTrans();
        initGeoImg();
        initAssessmentImg();
        setDemandNoteYearAdapter();

    }

    private void setDemandNoteYearAdapter() {
        ArrayList<String> mList = new ArrayList<>();
        int year = Calendar.getInstance().get(Calendar.YEAR);
        for (int i = year; i > (year - 5); i--) {
            mList.add(String.valueOf(i));
        }
        ArrayAdapter aa = new ArrayAdapter(mContext, R.layout.adapter_text_blue, mList);
        aa.setDropDownViewResource(R.layout.adapter_text_blue);
        spnrDemandNoteYear.setAdapter(aa);
    }

    private void initCouncillorAdjustment() {
        rv_councillor_adjustment = findViewById(R.id.rv_councillor_adjustment);
        rv_councillor_adjustment.setLayoutManager(new LinearLayoutManager(this));
        rv_councillor_adjustment.setFocusable(false);
        ViewCompat.setNestedScrollingEnabled(rv_councillor_adjustment, false);

        DataViewAdapter adapter = new DataViewAdapter(TabDataInitializer.initCouncillorData(dataItem), R.layout.rowview_council_adjustment_details);
        rv_councillor_adjustment.setAdapter(adapter);
    }

    // rv_government_policy
    private void initGovernmentPolicy() {
        rv_government_policy = findViewById(R.id.rv_government_policy);
        rv_government_policy.setLayoutManager(new LinearLayoutManager(this));
        rv_government_policy.setFocusable(false);
        ViewCompat.setNestedScrollingEnabled(rv_government_policy, false);

        List<DataModel> councillor_list = new ArrayList<>();
        String property_taxable_value = "";
        try {
            property_taxable_value = JsonObject.getString("property_taxable_value");
        } catch (JSONException e) {
            e.printStackTrace();
        }


        councillor_list.add(new DataModel("Net Assessed Value", dataItem.getProperty_net_assessed_value()));
        // councillor_list.add(new DataModel("Taxable Property Value", property_taxable_value))

        ;
        councillor_list.add(new DataModel("Council_Group/Category", dataItem.getGroupName() + ""));
        councillor_list.add(new DataModel("Mill_Rate", dataItem.getMillRate() + ""));

        councillor_list.add(new DataModel("RATE PAYABLE " + dataItem.getAssessmentYear(),NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble(dataItem.getRate_payable())) ));

        DataViewAdapter adapter = new DataViewAdapter(councillor_list, dataItem.getAssessmentYear());
        rv_government_policy.setAdapter(adapter);
    }


    private void initPropertyImages(List<String> listOfImages) {

        if (listOfImages.size() == 1)
            recyclerview_image_property.setLayoutManager(new GridLayoutManager(ActivityMainDetails.this, 1));
        else if (listOfImages.size() == 2)
            recyclerview_image_property.setLayoutManager(new GridLayoutManager(ActivityMainDetails.this, 2));


        recyclerview_image_property.setAdapter(new PropertyImageAdapter(this, listOfImages, "O"));
    }

    private void initDisabilityImage(List<TransactionModel> listOfImages) {

        if (listOfImages.size() == 1)
            recyclerview_image_disability.setLayoutManager(new GridLayoutManager(ActivityMainDetails.this, 1));
        else if (listOfImages.size() == 2)
            recyclerview_image_disability.setLayoutManager(new GridLayoutManager(ActivityMainDetails.this, 2));


        recyclerview_image_disability.setAdapter(new CashierImageAdapter(this, listOfImages, "D"));
    }

    private void initPensionerImage(List<TransactionModel> listOfImages) {

        if (listOfImages.size() == 1)
            recyclerview_image_pensioner.setLayoutManager(new GridLayoutManager(ActivityMainDetails.this, 1));
        else if (listOfImages.size() == 2)
            recyclerview_image_pensioner.setLayoutManager(new GridLayoutManager(ActivityMainDetails.this, 2));

        recyclerview_image_pensioner.setAdapter(new CashierImageAdapter(this, listOfImages, "P"));

    }

    private void initCashierImage(List<TransactionModel> listOfImages) {


        if (listOfImages.size() == 1)
            recyclerview_image_cashier.setLayoutManager(new GridLayoutManager(ActivityMainDetails.this, 1));
        else if (listOfImages.size() == 2)
            recyclerview_image_cashier.setLayoutManager(new GridLayoutManager(ActivityMainDetails.this, 2));


        recyclerview_image_cashier.setAdapter(new CashierImageAdapter(this, listOfImages, "C"));

    }


    //TODO initPayment
    private void initPaymentTrans() {

        rvPayment = findViewById(R.id.rvPayment);
        rvPayment.setLayoutManager(new LinearLayoutManager(this));

        DividerItemDecoration itemDecorator = new DividerItemDecoration(this, DividerItemDecoration.VERTICAL);
        itemDecorator.setDrawable(ContextCompat.getDrawable(mContext, R.drawable.divider));
        rvPayment.addItemDecoration(itemDecorator);

        adapterTransaction = new TransactionDetailAdapter(listPayment);
        rvPayment.setAdapter(adapterTransaction);
        rvPayment.setFocusable(false);

    }

    //TODO setTransactionData by Debabrata
    private void setTransactionData(JSONArray transArray) {


        try {
            if (transArray != null) {

                LogUtils.printf("I am transArray.length(): " + transArray.length());

                List<TransactionModel> pensionerImages = new ArrayList<TransactionModel>();
                List<TransactionModel> cashierImages = new ArrayList<TransactionModel>();
                List<TransactionModel> disabilityImages = new ArrayList<TransactionModel>();

                for (int i = 0; i < transArray.length(); i++) {
                    try {
                        String obj = transArray.optJSONObject(i).toString().trim();

                        TransactionModel model = (TransactionModel) CommonUtils.getObjectFromJson(obj, TransactionModel.class);
                        listPayment.add(0, model);

                        /*if (model.getDisability_discount_image_path() != null && !model.getDisability_discount_image_path().equalsIgnoreCase(""))
                            if (model.getDisability_discount_approve().equalsIgnoreCase("1"))
                                disabilityImages.add(model);*/

                        if (model.getPhysical_receipt_image_path() != null && !model.getPhysical_receipt_image_path().equalsIgnoreCase(""))
                            cashierImages.add(model);

                       /* if (model.getPensioner_discount_image_path() != null && !model.getPensioner_discount_image_path().equalsIgnoreCase(""))
                            if (model.getPensioner_discount_approve().equalsIgnoreCase("1"))
                                pensionerImages.add(model);*/


                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                initCashierImage(cashierImages);


                adapterTransaction.notifyDataSetChanged();


            } else {

            }
        } catch (Exception e) {
            e.printStackTrace();
        }


    }



    private void initLandlordView() {

        ivProfilePicLandload = findViewById(R.id.ivProfilePicLandload);
        rvLandload = findViewById(R.id.rvLandload);
        rvLandload.setLayoutManager(new LinearLayoutManager(this));
        adapterLandload = new DataViewAdapter(listLandload, R.layout.rowview_landlord_details);
        rvLandload.setAdapter(adapterLandload);
        rvLandload.setFocusable(false);
        ViewCompat.setNestedScrollingEnabled(rvLandload, false);
    }

    private void initPropertyView() {


        rvProperty = findViewById(R.id.rvProperty);
        rvProperty.setLayoutManager(new LinearLayoutManager(this));
        adapterProperty = new DataViewAdapter(listProperty);
        rvProperty.setAdapter(adapterProperty);
        rvProperty.setFocusable(false);
        ViewCompat.setNestedScrollingEnabled(rvProperty, false);
    }

    private void initOccupancyView() {


        rvOccupancy = findViewById(R.id.rvOccupancy);
        rvOccupancy.setLayoutManager(new LinearLayoutManager(this));
        adapterOccupancy = new DataViewAdapter(listOccupancy);
        rvOccupancy.setAdapter(adapterOccupancy);
        rvOccupancy.setFocusable(false);
        ViewCompat.setNestedScrollingEnabled(rvOccupancy, false);
    }

    private void initAssessmentView() {


        rvAssesment = findViewById(R.id.rvAssesment);
        //rvRatePayable = findViewById(R.id.rvRatePayable);
        rvAssesment.setLayoutManager(new LinearLayoutManager(this));
        adapterAssessment = new DataViewAdapter(listAssessment);
        rvAssesment.setAdapter(adapterAssessment);
        rvAssesment.setFocusable(false);
        ViewCompat.setNestedScrollingEnabled(rvAssesment, false);
    }

    private void initAssessmentImg() {


        rvAssessmentImg = findViewById(R.id.rvAssessmentImg);
        rvAssessmentImg.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false));
        adapterAssessmentImg = new ImageAdapter(listAssessmentImg);
        rvAssessmentImg.setAdapter(adapterAssessmentImg);
        rvAssessmentImg.setFocusable(false);
        //ViewCompat.setNestedScrollingEnabled(rvAssesment, false);
    }

    private void initGeoregistryView() {


        //TODO add digital address1 and 2 textview;

        tvDigitalAddress1 = findViewById(R.id.tvDigitalAddress1);
        tvDigitalAddress2 = findViewById(R.id.tvDigitalAddress2);

        rvGeoregistry = findViewById(R.id.rvGeoregistry);
        rvGeoregistry.setLayoutManager(new LinearLayoutManager(this));
        adapterGeoregistry = new GeoRegistryDataAdapter(listGeoregistry);
        rvGeoregistry.setAdapter(adapterGeoregistry);
        rvGeoregistry.setFocusable(false);
        ViewCompat.setNestedScrollingEnabled(rvGeoregistry, false);
    }

    //TODO Create by debabrata
    private void initGeoImg() {


        rvGeoRegitryImg = findViewById(R.id.rvGeoRegitryImg);
        rvGeoRegitryImg.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false));
        adapterGeoRegistryImg = new ImageTextAdapter(mListDataMeterDetails);
        rvGeoRegitryImg.setAdapter(adapterGeoRegistryImg);
        rvGeoRegitryImg.setFocusable(false);

    }

    SearchLandlordModel landlordModel;

    private void setLandloadData(JSONObject landloadObject, JSONObject mMainObject) {
        try {
            if (landloadObject != null) {

                landlordModel = (SearchLandlordModel) CommonUtils.getObjectFromJson(landloadObject.toString().trim(), SearchLandlordModel.class);
                TabDataInitializer.setLandloardData(landloadObject, mMainObject, listLandload, adapterLandload);

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    private void setPropertyData(JSONObject propertyObject) {
        try {
            if (propertyObject != null) {

                propertyModel = (SearchPropertyModel) CommonUtils.getObjectFromJson(propertyObject.toString().trim(), SearchPropertyModel.class);

                TabDataInitializer.setPropertyData(propertyObject, listProperty, adapterProperty);

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void setGeoRegistryData(JSONObject georegistryObject, JSONObject mMainObj) {
        try {

            //TODO by Debabrata set Geo registry all data.
            if (georegistryObject != null) {

                GeoRegistryModel geoModel = (GeoRegistryModel) CommonUtils.getObjectFromJson(georegistryObject.toString().trim(), GeoRegistryModel.class);

                DataModel model1 = new DataModel();
                model1.setKey("Point 1");
                model1.setValue(geoModel.getPoint1());
                listGeoregistry.add(model1);

                DataModel model2 = new DataModel();
                model2.setKey("Point 2");
                model2.setValue(geoModel.getPoint2());
                listGeoregistry.add(model2);


                DataModel model3 = new DataModel();
                model3.setKey("Point 3");
                model3.setValue(geoModel.getPoint3());
                listGeoregistry.add(model3);

                DataModel model4 = new DataModel();
                model4.setKey("Point 4");
                model4.setValue(geoModel.getPoint4());
                listGeoregistry.add(model4);

                DataModel model5 = new DataModel();
                model5.setKey("Point 5");
                model5.setValue(geoModel.getPoint5());
                listGeoregistry.add(model5);


                DataModel model6 = new DataModel();
                model6.setKey("Point 6");
                model6.setValue(geoModel.getPoint6());
                listGeoregistry.add(model6);


                DataModel model7 = new DataModel();
                model7.setKey("Point 7");
                model7.setValue(geoModel.getPoint7());
                listGeoregistry.add(model7);


                DataModel model8 = new DataModel();
                model8.setKey("Point 8");
                model8.setValue(geoModel.getPoint8());
                listGeoregistry.add(model8);

                //-----------------------------------------------//
                String DorLatLng = ((geoModel.getDor_lat_long() == null) ? "" : geoModel.getDor_lat_long());


                DataModel DorLatLong = new DataModel();
                DorLatLong.setKey("Dor Lat Long");
                DorLatLong.setValue(DorLatLng);
                listGeoregistry.add(DorLatLong);

                String Digital_address = ((geoModel.getDigital_address() == null) ? "" : geoModel.getDigital_address());
                DataModel DigitalAddress = new DataModel();
                DigitalAddress.setKey("Digital Address");
                DigitalAddress.setValue(Digital_address);
                listGeoregistry.add(DigitalAddress);

                try {
                    String sOpenLocationCode = ((geoModel.getOpen_location_code() == null) ? "" : geoModel.getOpen_location_code());

                    String mPostcode = mMainObj.optString("postcode");
                    DataModel mOpenLocationCode = new DataModel();
                    mOpenLocationCode.setKey("Open Location Code");
                    mOpenLocationCode.setValue(mPostcode + " " + sOpenLocationCode);
                    listGeoregistry.add(mOpenLocationCode);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }


            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void setMeterData(JSONObject mMainObject) {
        try {

            JSONArray mListArray = mMainObject.getJSONArray("registry_meters");

            if (mMainObject != null) {
                for (int i = 0; i < mListArray.length(); i++) {
                    try {
                        mListDataMeterDetails.add((MeterDetailsModel) CommonUtils.getObjectFromJson(mListArray.getJSONObject(i).toString().trim(), MeterDetailsModel.class));
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }

            adapterGeoRegistryImg.notifyDataSetChanged();

        } catch (Exception ex) {
            ex.printStackTrace();
        }

    }

    SearchOccupancyModel occupancyModel;

    private void setOccupancyData(JSONObject occupancyObject, JSONObject JSONMainObj) {
        try {
            if (occupancyObject != null) {

                occupancyModel = (SearchOccupancyModel) CommonUtils.getObjectFromJson(occupancyObject.toString().trim(), SearchOccupancyModel.class);

                OccupancyType = TabDataInitializer.setOccupancyData(occupancyObject, JSONMainObj, listOccupancy, adapterOccupancy);

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void setAssessmentData(JSONObject assessmentObject, Assessment dataItem) {

        try {
            if (assessmentObject != null) {

                tvPensionerDiscount.setText(StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(assessmentObject.optString("pensioner_discount")))));
                tvDisabilityDiscount.setText(StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(assessmentObject.optString("disability_discount")))));
                SearchAssessmentModel assessmentModel = (SearchAssessmentModel) CommonUtils.getObjectFromJson(assessmentObject.toString().trim(), SearchAssessmentModel.class);

                List<String> propertyImages = new ArrayList<>();
                // propertyImages.add(assessmentModel.getAssessmentImages1());
                // propertyImages.add(assessmentModel.getAssessmentImages2());
                propertyImages.add(assessmentModel.getOriginalOne());
                propertyImages.add(assessmentModel.getOriginalTwo());
                initPropertyImages(propertyImages);

                String mCategories = "";
                ArrayList<String> mListData = new ArrayList<>();
                for (int i = 0; i < assessmentModel.getCategories().size(); i++) {
                    try {
                        mListData.add(assessmentModel.getCategories().get(i).getLabel());

                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }

                try {

                    mCategories = getAppendListDataWithSpacialCharacter(mListData, ",");
                    DataModel model1 = new DataModel();
                    model1.setKey("Property Type");
                    model1.setValue(mCategories);
                    listAssessment.add(model1);

                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                try {

                    listAssessment.add(new DataModel("Floor Area", "" + dataItem.getSquareMeter() + " (sq ft) "));
                } catch (Exception ex) {
                    listAssessment.add(new DataModel("Floor Area", ""));
                    ex.printStackTrace();
                }


           /*     try {
                    DataModel model2_2 = new DataModel();
                    model2_2.setKey("Property Types(Total)");
                    String mPropertyTypeLabel = "";

                    JSONArray types_total = assessmentObject.getJSONArray("types_total");
                    JSONObject objectType = types_total.getJSONObject(0);
                    mPropertyTypeLabel = objectType.optString("label");
                    LogUtils.showErrorLog("Types ", " Types  types_total " + mPropertyTypeLabel);
                    model2_2.setValue("" + mPropertyTypeLabel);
                    listAssessment.add(model2_2);
                } catch (Exception e) {
                    e.printStackTrace();
                }*/


                try {
                    String mLabel = "";
                    DataModel model2 = new DataModel();
                    model2.setKey("Habitable Floors");
                    JSONArray type = assessmentObject.getJSONArray("types");

                    try {
                        if (type.length() == 1) {
                            JSONObject objectType0 = type.getJSONObject(0);
                            mLabel = objectType0.optString("label");
                            LogUtils.showErrorLog("Types ", " Types  types_total " + mLabel);
                        } else if (type.length() == 2) {
                            JSONObject objectType0 = type.getJSONObject(0);
                            JSONObject objectType1 = type.getJSONObject(1);
                            mLabel = objectType0.optString("label") + "," + objectType1.optString("label");

                            LogUtils.showErrorLog("Types ", " Types  types_total " + mLabel);
                        } else if (type.length() == 3) {
                            JSONObject objectType0 = type.getJSONObject(0);
                            JSONObject objectType1 = type.getJSONObject(1);
                            JSONObject objectType2 = type.getJSONObject(2);
                            mLabel = objectType0.optString("label") + "," +
                                    objectType1.optString("label") + "," +
                                    objectType2.optString("label");
                            LogUtils.showErrorLog("Types ", " Types  types_total " + mLabel);
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                    model2.setValue(mLabel);
                    listAssessment.add(model2);

                } catch (Exception e) {
                    e.printStackTrace();
                }


                try {
                    DataModel model3 = new DataModel();
                    model3.setKey("Wall Materials");
                    model3.setValue(assessmentModel.getWallMaterial().getLabel());
                    listAssessment.add(model3);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }


                try {
                    DataModel model4 = new DataModel();
                    model4.setKey("Roof Type");
                    model4.setValue(assessmentModel.getRoofMaterial().getLabel());
                    listAssessment.add(model4);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                try {
                    listAssessment.add(new DataModel("window_type", dataItem.getWindowType().getLabel()));
                } catch (Exception ex) {
                    listAssessment.add(new DataModel("Window_type", ""));
                    ex.printStackTrace();
                }
                try {
                    listAssessment.add(new DataModel("sanitation", dataItem.getSanitationType().getLabel() + ""));
                } catch (Exception ex) {
                    listAssessment.add(new DataModel("sanitation", ""));
                    ex.printStackTrace();
                }


                try {

                    String mStrFinal = "";
                    ArrayList<String> list = new ArrayList<>();
                    for (int i = 0; i < assessmentModel.getValuesAdded().size(); i++) {
                        try {
                            list.add(assessmentModel.getValuesAdded().get(i).getLabel());

                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }

                    mStrFinal = getAppendListDataWithSpacialCharacter(list, ",");

                    DataModel model6 = new DataModel();
                    model6.setKey("Value Added Parameters");
                    model6.setValue("" + mStrFinal);
                    listAssessment.add(model6);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                try {

                    DataModel model7 = new DataModel();
                    model7.setKey("Property Use");
                    model7.setValue(String.valueOf(assessmentModel.getPropertyUse().getLabel()));
                    listAssessment.add(model7);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }


                try {
                    DataModel model8 = new DataModel();
                    model8.setKey("Property Zone");
                    model8.setValue(String.valueOf(assessmentModel.getZone().getLabel()));
                    listAssessment.add(model8);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }


                try {
                    String GatedCommStr = "No";
                    String GatedCommunity = ((assessmentModel.getGatedCommunity() == null) ? "No" : assessmentModel.getGatedCommunity());
                    if (GatedCommunity.equalsIgnoreCase("0")) {
                        GatedCommStr = "No";

                    } else if (GatedCommunity.equalsIgnoreCase("No") || GatedCommunity.equalsIgnoreCase("")) {
                        GatedCommStr = "No";
                    } else {
                        GatedCommStr = "Yes";
                    }

                    DataModel model10 = new DataModel();
                    model10.setKey("Gated Community");
                    model10.setValue(GatedCommStr);
                    listAssessment.add(model10);
                } catch (Exception ex) {
                    DataModel model10 = new DataModel();
                    ex.printStackTrace();
                    model10.setKey("Gated Community");
                    model10.setValue("No");
                    listAssessment.add(model10);
                }


                try {
                    String Swimming = "";

                    LogUtils.showErrorLog("Swimming Pool", "assessmentModel  ");

                    Swimming = ((assessmentModel.getSwimming().getLabel() == null) ? "" : assessmentModel.getSwimming().getLabel());

                    DataModel model11 = new DataModel();
                    model11.setKey("Swimming Pool");
                    model11.setValue(Swimming);
                    listAssessment.add(model11);


                    LogUtils.showErrorLog("Swimming Pool", "Swimming Pool  " + Swimming);
                } catch (Exception ex) {
                    ex.printStackTrace();
                    DataModel model11 = new DataModel();
                    model11.setKey("Swimming Pool");
                    model11.setValue("No");
                    listAssessment.add(model11);
                }


              /*  try {
                    String PropertyDimension = ((assessmentModel.getDimension().getLabel() == null) ? "" : "" + assessmentModel.getDimension().getLabel() + " Sq. Meters");


                    DataModel model5 = new DataModel();
                    model5.setKey("Property Dimension");
                    model5.setValue(PropertyDimension);
                    listAssessment.add(model5);


                } catch (Exception ex) {
                    ex.printStackTrace();
                }


                try {
                    String NoOfShop = ((assessmentModel.getNoOfShop() == null) ? "" : "" + assessmentModel.getNoOfShop());


                    if (NoOfShop.trim().length() != 0) {
                        DataModel model18 = new DataModel();
                        model18.setKey("Number Of Shops");
                        model18.setValue(NoOfShop);
                        listAssessment.add(model18);
                    }
                    LogUtils.showErrorLog("test NoOfShop", "NoOfShop " + NoOfShop);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                try {

                    String NoOfMast = ((assessmentModel.getNoOfMast() == null) ? "" : "" + assessmentModel.getNoOfMast());

                    DataModel model18 = new DataModel();
                    if (NoOfMast.trim().length() != 0) {
                        model18.setKey("Number Of Mast");
                        model18.setValue(String.valueOf(NoOfMast));
                        listAssessment.add(model18);
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                try {

                    String NoOfCompoundHouse = ((assessmentModel.getNoOfCompoundHouse() == null) ? "" : "" + assessmentModel.getNoOfCompoundHouse());

                    if (NoOfCompoundHouse.trim().length() != 0) {
                        DataModel model18 = new DataModel();
                        model18.setKey("Number Of Compound House");
                        model18.setValue(String.valueOf(NoOfCompoundHouse));
                        listAssessment.add(model18);
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                try {

                    String CompoundName = ((assessmentModel.getCompoundName() == null) ? "" : "" + assessmentModel.getCompoundName());
                    if (CompoundName.trim().length() != 0) {
                        DataModel model18 = new DataModel();
                        model18.setKey("Compound Name");
                        model18.setValue(String.valueOf(CompoundName));
                        listAssessment.add(model18);
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }*/


                try {
                    String PropertyRateWithoutGst = ((assessmentModel.getPropertyRateWithoutGst() == null) ? "" : "Le " + NumberFormater.Companion.formatAmount(NumberFormater.Companion.parseDouble(assessmentModel.getPropertyRateWithoutGst())));

                    DataModel model9 = new DataModel();
                    model9.setKey("Assessed Value");
                    model9.setValue(PropertyRateWithoutGst);
                    listAssessment.add(model9);
                    LogUtils.showErrorLog("Calculated Property Rate ", "Calculated Property Rate " + PropertyRateWithoutGst);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                //  listAssessment.add(new DataModel("Window type", dataItem.getWindowTypePercentage() + "%"));
              /*  listAssessment.add(new DataModel("pensioner_discount", dataItem.getPensionerDiscount().equalsIgnoreCase("1") ? "Yes" : "No"));
                listAssessment.add(new DataModel("disability_discount", dataItem.getDisabilityDiscount().equalsIgnoreCase("1") ? "Yes" : "No"));
             */


                adapterAssessment.notifyDataSetChanged();
                // Assessments //

                LogUtils.printf("I am img asment 1: " + assessmentModel.getOriginalOne());
                if (assessmentModel.getOriginalOne() != null) {
                    listAssessmentImg.add(assessmentModel.getOriginalOne());
                }
                LogUtils.printf("I am img asment 2: " + assessmentModel.getOriginalTwo());

                if (assessmentModel.getOriginalTwo() != null) {
                    listAssessmentImg.add(assessmentModel.getOriginalTwo());
                }


                // FIXME: 19-09-2021


                adapterAssessmentImg.notifyDataSetChanged();

            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    private void initializeListeners() {

        toolbar_iv_home.setOnClickListener(this);
//        toolbar_iv_search.setOnClickListener(this);

        btn_edit_landlord.setOnClickListener(this);
        btn_edit_property_details.setOnClickListener(this);
        btn_edit_occupancy_details.setOnClickListener(this);


        activitySearchDetails_tv_rate_payable.setOnClickListener(this);
        activitySearchDetails_tv_assessment_history.setOnClickListener(this);
        activitySearchDetails_tv_property_images.setOnClickListener(this);
        activitySearchDetails_tv_landlord_details.setOnClickListener(this);
        activitySearchDetails_tv_assessment_details.setOnClickListener(this);
        activitySearchDetails_tv_property_details.setOnClickListener(this);
        activitySearchDetails_tv_occupancy_details.setOnClickListener(this);
        activitySearchDetails_tv_geo_registry_details.setOnClickListener(this);
        activitySearchDetails_tv_payment.setOnClickListener(this);
        activitySearchDetails_tv_cashier_receipt.setOnClickListener(this);
        //activitySearchDetails_tv_pensioner_receipt.setOnClickListener(this);
        //activitySearchDetails_tv_disability_receipt.setOnClickListener(this);
        activitySearchDetails_tv_councillor_adjustment.setOnClickListener(this);
        activitySearchDetails_tv_council_discount.setOnClickListener(this);
        activitySearchDetails_tv_government_policy.setOnClickListener(this);
        activitySearchDetails_tv_demand_note.setOnClickListener(this);
        tvDownloadDemandNote.setOnClickListener(this);
    }

    @Override
    public void onBackPressed() {

        super.onBackPressed();
    }


    private void showLogoutAlert() {
        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);

        // Set a title for alert dialog
        builder.setTitle("Logout?");

        // Ask the final question
        builder.setMessage("Are you sure you want to logout?");

        // Set the alert dialog yes button click listener
        builder.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                // Do something when user clicked the Yes button
                // Set the TextView visibility GONE
                Intent in = new Intent(mContext, ActivityCashierLogin.class);
                startActivity(in);
                finish();
            }
        });

        // Set the alert dialog no button click listener
        builder.setNegativeButton("No", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                // Do something when No button clicked
                if (dialog != null) {
                    dialog.dismiss();
                }
            }
        });

        dialog = builder.create();
        // Display the alert dialog on interface
        dialog.show();
    }

    boolean isIdRequired = false;
    boolean isAddressRequired = false;

    public void initLandlordDialog(SearchLandlordModel searchResponseModel) {
        LayoutInflater factory = LayoutInflater.from(this);
        final View deleteDialogView = factory.inflate(R.layout.dialog_edit_landlord_cashier, null);
        dialogLandlord = new AlertDialog.Builder(this).create();
        dialogLandlord.setView(deleteDialogView);

        WindowManager.LayoutParams params = dialogLandlord.getWindow().getAttributes();
        params.width = WindowManager.LayoutParams.MATCH_PARENT;
        params.height = WindowManager.LayoutParams.MATCH_PARENT;
        params.gravity = Gravity.CENTER;
        dialogLandlord.getWindow().setAttributes(params);
        dialogLandlord.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);

        EditText edt_landlord_first_name = deleteDialogView.findViewById(R.id.edt_landlord_first_name);
        EditText edt_landlord_middle_name = deleteDialogView.findViewById(R.id.edt_landlord_middle_name);
        EditText edt_landlord_surname = deleteDialogView.findViewById(R.id.edt_landlord_surname);
        EditText edt_landlord_street_number = deleteDialogView.findViewById(R.id.edt_landlord_street_number);
        EditText edt_landlord_old_street_number = deleteDialogView.findViewById(R.id.edt_landlord_old_street_number);
        EditText edt_landlord_street_name = deleteDialogView.findViewById(R.id.edt_landlord_street_name);
        EditText edt_landlord_email = deleteDialogView.findViewById(R.id.edt_landlord_email);
        EditText edt_landlord_mobile_1 = deleteDialogView.findViewById(R.id.edt_landlord_mobile_1);
        Button btn_save_landlord_info = deleteDialogView.findViewById(R.id.btn_save_landlord_info);
        EditText edt_landlord_additional_address = deleteDialogView.findViewById(R.id.edt_landlord_additional_address);
        edt_landlord_additional_address.setText(JsonObject.optJSONObject("property").optJSONObject("landlord").optString("additional_address_id"));



        EditText area = deleteDialogView.findViewById(R.id.edt_area);
        EditText nin = deleteDialogView.findViewById(R.id.edt_nin);
        EditText tinEdt = deleteDialogView.findViewById(R.id.edt_tin);


        // FIXME: 13-05-2022
        RadioButton rb_male = deleteDialogView.findViewById(R.id.rb_male);
        RadioButton rb_female = deleteDialogView.findViewById(R.id.rb_female);
        EditText edt_landlord_postcode = deleteDialogView.findViewById(R.id.edt_landlord_postcode);
        EditText edt_landlord_province = deleteDialogView.findViewById(R.id.edt_landlord_province);
        EditText edt_landlord_district = deleteDialogView.findViewById(R.id.edt_landlord_district);
        EditText edt_landlord_chiefdom = deleteDialogView.findViewById(R.id.edt_landlord_chiefdom);
        EditText edt_landlord_ward = deleteDialogView.findViewById(R.id.edt_landlord_ward);
        EditText edt_landlord_section = deleteDialogView.findViewById(R.id.edt_landlord_section);
        EditText edt_landlord_mobile_2 = deleteDialogView.findViewById(R.id.edt_landlord_mobile_2);
        EditText edt_landlord_title = deleteDialogView.findViewById(R.id.edt_landlord_title);
        EditText edt_landlord_constituency = deleteDialogView.findViewById(R.id.edt_landlord_constituency);

        if (searchResponseModel.getSex() != null) {
            if (searchResponseModel.getSex().equalsIgnoreCase("M"))
                rb_male.setChecked(true);
            else rb_female.setChecked(true);
        }

        edt_landlord_postcode.setText(searchResponseModel.getPostcode());
        edt_landlord_province.setText(searchResponseModel.getProvince());
        edt_landlord_district.setText(searchResponseModel.getDistrict());
        edt_landlord_chiefdom.setText(searchResponseModel.getChiefdom());
        edt_landlord_constituency.setText(searchResponseModel.getConstituency());
        edt_landlord_ward.setText(searchResponseModel.getWard());
        edt_landlord_section.setText(searchResponseModel.getSection());
        edt_landlord_mobile_2.setText(searchResponseModel.getMobile2());
        edt_landlord_title.setText(searchResponseModel.getTitles().getLabel());


        img_verification_document = deleteDialogView.findViewById(R.id.img_verification_document);
        img_address_proof = deleteDialogView.findViewById(R.id.img_address_proof);
        edt_note_address_proof = deleteDialogView.findViewById(R.id.edt_note_address_proof);
        edt_note_id_proof = deleteDialogView.findViewById(R.id.edt_note_id_proof);

        lin_id_proof = deleteDialogView.findViewById(R.id.lin_id_proof);
        lin_address_proof = deleteDialogView.findViewById(R.id.lin_address_proof);
        //  img_address_proof = deleteDialogView.findViewById(R.id.img_address_proof);


        // FIXME: 20-09-2021
        edt_landlord_first_name.setText(searchResponseModel.getFirstName());
        edt_landlord_middle_name.setText(searchResponseModel.getMiddleName());
        edt_landlord_surname.setText(searchResponseModel.getSurname());
        edt_landlord_street_number.setText(searchResponseModel.getStreetNumber());
        edt_landlord_street_name.setText(searchResponseModel.getStreetName());
        edt_landlord_email.setText("" + searchResponseModel.getEmail());
        edt_landlord_mobile_1.setText(searchResponseModel.getMobile1());

        /// newly added
        edt_landlord_old_street_number.setText(searchResponseModel.getStreetNumber());


        try {

            LinearLayout layoutFirstName = deleteDialogView.findViewById(R.id.layoutFirstName);
            LinearLayout layoutMiddleName = deleteDialogView.findViewById(R.id.layoutMiddleName);
            LinearLayout layoutSurtName = deleteDialogView.findViewById(R.id.layoutSurtName);
            LinearLayout layoutTin = deleteDialogView.findViewById(R.id.layoutTin);
            LinearLayout layoutNin = deleteDialogView.findViewById(R.id.layoutNin);

            if (JsonObject.getJSONObject("property").optBoolean("is_organization")) {
                layoutFirstName.setVisibility(View.GONE);
                layoutMiddleName.setVisibility(View.GONE);
                layoutSurtName.setVisibility(View.GONE);
                layoutNin.setVisibility(View.GONE);


                layoutTin.setVisibility(View.VISIBLE);

                String tin = ((JsonObject.getJSONObject("property").getJSONObject("landlord").getJSONObject("property").optString("organization_tin") == null) ? "" : "" + JsonObject.getJSONObject("property").getJSONObject("landlord").getJSONObject("property").optString("organization_tin"));
                tinEdt.setText(tin);


            } else {
                layoutFirstName.setVisibility(View.VISIBLE);
                layoutMiddleName.setVisibility(View.VISIBLE);
                layoutSurtName.setVisibility(View.VISIBLE);
                layoutNin.setVisibility(View.VISIBLE);


                layoutTin.setVisibility(View.GONE);

                String ninType = ((JsonObject.getJSONObject("property").getJSONObject("landlord").optString("nin_number") == null) ? "" : "" + JsonObject.getJSONObject("property").getJSONObject("landlord").optString("nin_number"));
                nin.setText(ninType);

            }

            String pArea = JsonObject.getJSONObject("property").getJSONObject("landlord").optString("property_area");
            area.setText(pArea);

        } catch (JSONException e) {

        }


        dialogLandlord.show();

        img_verification_document.setOnClickListener(v -> OpenCamera(CODE_VERIFICATION_DOCUMENT));
        img_address_proof.setOnClickListener(v -> OpenCamera(CODE_ADDRESS_PROOF));


        edt_landlord_first_name.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (searchResponseModel.getFirstName() == null || searchResponseModel.getFirstName().isEmpty()) {
                    lin_id_proof.setVisibility(View.VISIBLE);
                    isIdRequired = true;
                } else if (!searchResponseModel.getFirstName().equalsIgnoreCase(s.toString())) {
                    lin_id_proof.setVisibility(View.VISIBLE);
                    isIdRequired = true;
                } else {
                    lin_id_proof.setVisibility(View.GONE);
                    isIdRequired = false;
                }
            }
        });
        edt_landlord_middle_name.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {

                if (searchResponseModel.getMiddleName() == null || searchResponseModel.getMiddleName().isEmpty()) {
                    lin_id_proof.setVisibility(View.VISIBLE);
                    isIdRequired = true;
                } else if (!searchResponseModel.getMiddleName().equalsIgnoreCase(s.toString())) {
                    lin_id_proof.setVisibility(View.VISIBLE);
                    isIdRequired = true;
                } else {
                    lin_id_proof.setVisibility(View.GONE);
                    isIdRequired = false;
                }
            }
        });
        edt_landlord_surname.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (searchResponseModel.getSurname() == null || searchResponseModel.getSurname().isEmpty()) {
                    lin_id_proof.setVisibility(View.VISIBLE);
                    isIdRequired = true;
                } else if (!searchResponseModel.getSurname().equalsIgnoreCase(s.toString())) {
                    lin_id_proof.setVisibility(View.VISIBLE);
                    isIdRequired = true;
                } else {
                    lin_id_proof.setVisibility(View.GONE);
                    isIdRequired = false;
                }
            }
        });
        edt_landlord_street_number.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {

                if (searchResponseModel.getStreet_numbernew() == null || searchResponseModel.getStreet_numbernew().isEmpty()) {
                    lin_address_proof.setVisibility(View.VISIBLE);
                    isAddressRequired = true;
                } else if (!searchResponseModel.getStreet_numbernew().equalsIgnoreCase(s.toString())) {
                    lin_address_proof.setVisibility(View.VISIBLE);
                    isAddressRequired = true;
                } else {
                    lin_address_proof.setVisibility(View.GONE);
                    isAddressRequired = false;

                }
            }
        });
        edt_landlord_street_name.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (searchResponseModel.getStreetName() == null || searchResponseModel.getStreetName().isEmpty()) {
                    lin_address_proof.setVisibility(View.VISIBLE);
                    isAddressRequired = true;
                } else if (!searchResponseModel.getStreetName().equalsIgnoreCase(s.toString())) {
                    lin_address_proof.setVisibility(View.VISIBLE);
                    isAddressRequired = true;
                } else {
                    lin_address_proof.setVisibility(View.GONE);
                    isAddressRequired = false;

                }
            }
        });
        ///// newly added
        edt_landlord_old_street_number.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (searchResponseModel.getStreetNumber() == null || searchResponseModel.getStreetNumber().isEmpty()) {
                    if (s.length() > 0) {
                        old_street_flag = "1";
                        lin_address_proof.setVisibility(View.VISIBLE);
                        isAddressRequired = true;
                    }
                } else if (!searchResponseModel.getStreetNumber().equalsIgnoreCase(s.toString())) {
                    {
                        old_street_flag = "1";
                        lin_address_proof.setVisibility(View.VISIBLE);
                        isAddressRequired = true;
                    }
                } else {
                    old_street_flag = "0";
                    lin_address_proof.setVisibility(View.GONE);
                    isAddressRequired = false;
                }
            }
        });

        btn_save_landlord_info.setOnClickListener(v -> {
            HashMap<String, String> req_params = new HashMap<>();

            // FIXME: 20-09-2021
            req_params.put("landlord_first_name", "" + edt_landlord_first_name.getText().toString());
            req_params.put("landlord_middle_name", "" + edt_landlord_middle_name.getText().toString());
            req_params.put("landlord_surname", "" + edt_landlord_surname.getText().toString());
            req_params.put("landlord_street_number", "" + edt_landlord_street_number.getText().toString());
            req_params.put("landlord_street_name", "" + edt_landlord_street_name.getText().toString());
            req_params.put("landlord_email", "" + edt_landlord_email.getText().toString());
            req_params.put("landlord_mobile_1", "" + edt_landlord_mobile_1.getText().toString());
            req_params.put("old_street_number", "" + edt_landlord_old_street_number.getText().toString());
            req_params.put("old_street_flag", "" + old_street_flag);
            req_params.put("requested_by", "cashier");

            // FIXME: 13-05-2022
            req_params.put("landlord_ownerTitle_id", "" + edt_landlord_title.getText().toString());
            req_params.put("landlord_ward", "" + edt_landlord_ward.getText().toString());
            req_params.put("landlord_constituency", "" + edt_landlord_constituency.getText().toString());
            req_params.put("landlord_section", "" + edt_landlord_section.getText().toString());
            req_params.put("landlord_chiefdom", "" + edt_landlord_chiefdom.getText().toString());
            req_params.put("landlord_district", "" + edt_landlord_district.getText().toString());
            req_params.put("landlord_province", "" + edt_landlord_province.getText().toString());
            req_params.put("landlord_postcode", "" + edt_landlord_postcode.getText().toString());
            req_params.put("landlord_mobile_2", "" + edt_landlord_mobile_2.getText().toString());
            req_params.put("landlord_sex", rb_male.isChecked() ? "M" : "F");


            req_params.put("tinNumber", "" + tinEdt.getText().toString());
            req_params.put("ninNumber", "" + nin.getText().toString());
            req_params.put("property_area", "" + area);


            String finalURL = URL_CASHIER_LANDLORD_EDIT_PROFILE + getIntent().getStringExtra("property_id");

            Log.d("request", req_params.toString());
            Log.d("request_url", finalURL);

            if (isIdRequired && isAddressRequired) {
                if (file_verification_document != null && file_address_proof != null) {

                    apiRequest.callFileUpload(
                            finalURL,
                            req_params,
                            new PART("verification_document", file_verification_document),
                            new PART("address_document", file_address_proof),
                            PrefUtil.getAuthType(mContext) + " " + PrefUtil.getToken(mContext),
                            "upload_data");

                } else
                    Toast.makeText(ActivityMainDetails.this, "Image shouldn't be empty", Toast.LENGTH_SHORT).show();
            } else if (isIdRequired) {
                if (file_verification_document != null) {

                    apiRequest.callFileUpload(
                            finalURL,
                            req_params,
                            new PART("verification_document", file_verification_document),
                            PrefUtil.getAuthType(mContext) + " " + PrefUtil.getToken(mContext),
                            "upload_data");

                } else
                    Toast.makeText(ActivityMainDetails.this, "Image shouldn't be empty", Toast.LENGTH_SHORT).show();
            } else if (isAddressRequired) {
                if (file_address_proof != null) {

                    apiRequest.callFileUpload(
                            finalURL,
                            req_params,
                            new PART("address_document", file_address_proof),
                            PrefUtil.getAuthType(mContext) + " " + PrefUtil.getToken(mContext),
                            "upload_data");

                } else
                    Toast.makeText(ActivityMainDetails.this, "Image shouldn't be empty", Toast.LENGTH_SHORT).show();
            } else {
                apiRequest.callPostFormData(
                        finalURL,
                        req_params,
                        PrefUtil.getAuthType(mContext) + " " + PrefUtil.getToken(mContext),
                        "upload_data"
                );
            }


        });


        try {
            if (JsonObject.getJSONObject("property").optBoolean("is_organization")) {

                try {

                    String organization_name = ((JsonObject.getJSONObject("property").optString("organization_name") == null) ? "" : "" + JsonObject.getJSONObject("property").optString("organization_name"));

                    deleteDialogView.findViewById(R.id.layoutOrganizationName).setVisibility(View.VISIBLE);
                    ((EditText)deleteDialogView.findViewById(R.id.edt_organization_Name)).setText(organization_name);

                } catch (Exception ex) {
                    ex.printStackTrace();
                }
                try {

                    String OrganizationType = ((JsonObject.getJSONObject("property").optString("organization_type") == null) ? "" : "" + JsonObject.getJSONObject("property").optString("organization_type"));

                    deleteDialogView.findViewById(R.id.layoutOrganizationType).setVisibility(View.VISIBLE);
                    ((EditText)deleteDialogView.findViewById(R.id.edt_organization_Type)).setText(OrganizationType);


                    if (OrganizationType.equalsIgnoreCase("School")) {
                        listOccupancy.add(new DataModel("School Type", JsonObject.getJSONObject("property").optString("organization_school_type")));
                        String schoolType = JsonObject.getJSONObject("property").optString("organization_school_type");

                        deleteDialogView.findViewById(R.id.layoutSchoolType).setVisibility(View.VISIBLE);
                        ((EditText)deleteDialogView.findViewById(R.id.edt_school_Type)).setText(schoolType);


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


            }
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }


    }


    // FIXME: 19-09-2021
    private void OpenCamera(int code) {
        ImagePicker.Companion.with(this)
                .crop()                    //Crop image(Optional), Check Customization for more option
                .compress(1024)            //Final image size will be less than 1 MB(Optional)
                .maxResultSize(1080, 1080)    //Final image resolution will be less than 1080 x 1080(Optional)
                .cameraOnly()
                .start(code);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode,
                                    Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == RESULT_OK) {

            if (requestCode == CODE_VERIFICATION_DOCUMENT) {
                img_verification_document.setImageURI(Uri.fromFile(ImagePicker.Companion.getFile(data)));
                file_verification_document = ImagePicker.Companion.getFile(data);
            } else if (requestCode == CODE_ADDRESS_PROOF) {
                img_address_proof.setImageURI(Uri.fromFile(ImagePicker.Companion.getFile(data)));
                file_address_proof = ImagePicker.Companion.getFile(data);
            } else if (requestCode == CODE_ADDRESS_PROOF_PROPERTY) {
                img_address_proof_property.setImageURI(Uri.fromFile(ImagePicker.Companion.getFile(data)));
                file_address_proof_property = ImagePicker.Companion.getFile(data);
                // list_file.add(new PART("address_document", file_address_proof));
                // replaceFile(new PART("address_document", file_address_proof));

                list_map_landlord_property.put("address_document", file_address_proof_property);

            } else if (requestCode == CODE_CONVEYANCE_CAPTURE_PROPERTY) {
                img_lin_conveyance_capture_property.setImageURI(Uri.fromFile(ImagePicker.Companion.getFile(data)));
                file_conveyance_capture_property = ImagePicker.Companion.getFile(data);
                list_map_landlord_property.put("conveyance_proof", file_conveyance_capture_property);
            }
        }
    }

    @Override
    public void onClick(View v) {
        Intent intent = null;
        switch (v.getId()) {

            case R.id.toolbar_iv_home:
                onBackPressed();
                break;
            case R.id.toolbar_iv_search:
                //  intent = new Intent(mContext, ActDe)
                break;

            case R.id.btn_edit_property_details:
                initLandlordPropertyDialog(propertyModel);
                //   if (dialogLandlord != null) dialogLandlord.show();
                break;
            case R.id.btn_edit_occupancy_details:
                initOccupancyDialog();
                //   if (dialogLandlord != null) dialogLandlord.show();
                break;

            case R.id.btn_edit_landlord:
                initLandlordDialog(landlordModel);
                //   if (dialogLandlord != null) dialogLandlord.show();
                break;


            case R.id.activitySearchDetails_tv_assessment_history:
                if (expand_assessment_history) {
                    include_assessment_history.setVisibility(View.GONE);
                    activitySearchDetails_tv_assessment_history.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                    activitySearchDetails_tv_assessment_history.setTextColor(getResources().getColor(R.color.colorBlack));
                    activitySearchDetails_tv_assessment_history.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                    expand_assessment_history = false;

                } else {
                    include_assessment_history.setVisibility(View.VISIBLE);
                    activitySearchDetails_tv_assessment_history.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                    activitySearchDetails_tv_assessment_history.setTextColor(getResources().getColor(R.color.colorWhite));
                    activitySearchDetails_tv_assessment_history.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);
                    expand_assessment_history = true;

                }
                break;

            case R.id.activitySearchDetails_tv_rate_payable:
                if (expand__rate_payable) {
                    include_tv_rate_payable.setVisibility(View.GONE);
                    activitySearchDetails_tv_rate_payable.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                    activitySearchDetails_tv_rate_payable.setTextColor(getResources().getColor(R.color.colorBlack));
                    activitySearchDetails_tv_rate_payable.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                    expand__rate_payable = false;

                } else {
                    include_tv_rate_payable.setVisibility(View.VISIBLE);
                    activitySearchDetails_tv_rate_payable.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                    activitySearchDetails_tv_rate_payable.setTextColor(getResources().getColor(R.color.colorWhite));
                    activitySearchDetails_tv_rate_payable.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);
                    expand__rate_payable = true;

                }
                break;

            case R.id.activitySearchDetails_tv_property_images:
                if (expand_property_image) {
                    include_property_images.setVisibility(View.GONE);
                    activitySearchDetails_tv_property_images.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                    activitySearchDetails_tv_property_images.setTextColor(getResources().getColor(R.color.colorBlack));
                    activitySearchDetails_tv_property_images.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                    expand_property_image = false;

                } else {
                    include_property_images.setVisibility(View.VISIBLE);
                    activitySearchDetails_tv_property_images.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                    activitySearchDetails_tv_property_images.setTextColor(getResources().getColor(R.color.colorWhite));
                    activitySearchDetails_tv_property_images.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);
                    expand_property_image = true;

                }
                break;


            case R.id.activitySearchDetails_tv_landlord_details:
                if (expand_landlord_details) {
                    include_landlord_details.setVisibility(View.GONE);
                    activitySearchDetails_tv_landlord_details.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                    activitySearchDetails_tv_landlord_details.setTextColor(getResources().getColor(R.color.colorBlack));
                    activitySearchDetails_tv_landlord_details.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                    expand_landlord_details = false;

                } else {
                    include_landlord_details.setVisibility(View.VISIBLE);
                    activitySearchDetails_tv_landlord_details.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                    activitySearchDetails_tv_landlord_details.setTextColor(getResources().getColor(R.color.colorWhite));
                    activitySearchDetails_tv_landlord_details.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);
                    expand_landlord_details = true;

                }
                break;
            case R.id.activitySearchDetails_tv_assessment_details:
                if (expand_assessment_details) {
                    include_assessment_details.setVisibility(View.GONE);
                    activitySearchDetails_tv_assessment_details.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                    activitySearchDetails_tv_assessment_details.setTextColor(getResources().getColor(R.color.colorBlack));
                    activitySearchDetails_tv_assessment_details.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                    expand_assessment_details = false;

                } else {
                    include_assessment_details.setVisibility(View.VISIBLE);
                    activitySearchDetails_tv_assessment_details.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                    activitySearchDetails_tv_assessment_details.setTextColor(getResources().getColor(R.color.colorWhite));
                    activitySearchDetails_tv_assessment_details.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);
                    expand_assessment_details = true;

                }

                break;
            case R.id.activitySearchDetails_tv_property_details:

                if (expand_property_details) {
                    include_property_details.setVisibility(View.GONE);
                    activitySearchDetails_tv_property_details.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                    activitySearchDetails_tv_property_details.setTextColor(getResources().getColor(R.color.colorBlack));
                    activitySearchDetails_tv_property_details.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                    expand_property_details = false;

                } else {
                    include_property_details.setVisibility(View.VISIBLE);
                    activitySearchDetails_tv_property_details.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                    activitySearchDetails_tv_property_details.setTextColor(getResources().getColor(R.color.colorWhite));
                    activitySearchDetails_tv_property_details.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);
                    expand_property_details = true;
                }
                break;
            case R.id.activitySearchDetails_tv_occupancy_details:

                if (expand_occupancy_details) {
                    include_occupancy_details.setVisibility(View.GONE);
                    activitySearchDetails_tv_occupancy_details.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                    activitySearchDetails_tv_occupancy_details.setTextColor(getResources().getColor(R.color.colorBlack));
                    activitySearchDetails_tv_occupancy_details.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                    expand_occupancy_details = false;

                } else {
                    include_occupancy_details.setVisibility(View.VISIBLE);
                    activitySearchDetails_tv_occupancy_details.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                    activitySearchDetails_tv_occupancy_details.setTextColor(getResources().getColor(R.color.colorWhite));
                    activitySearchDetails_tv_occupancy_details.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);
                    expand_occupancy_details = true;
                }
                break;
            case R.id.activitySearchDetails_tv_geo_registry_details:
                if (expand_geo_registry_details) {
                    include_geo_registry_details.setVisibility(View.GONE);
                    activitySearchDetails_tv_geo_registry_details.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                    activitySearchDetails_tv_geo_registry_details.setTextColor(getResources().getColor(R.color.colorBlack));
                    activitySearchDetails_tv_geo_registry_details.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                    expand_geo_registry_details = false;

                } else {
                    include_geo_registry_details.setVisibility(View.VISIBLE);
                    activitySearchDetails_tv_geo_registry_details.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                    activitySearchDetails_tv_geo_registry_details.setTextColor(getResources().getColor(R.color.colorWhite));
                    activitySearchDetails_tv_geo_registry_details.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);
                    expand_geo_registry_details = true;
                }
                break;
            case R.id.activitySearchDetails_tv_payment:

                try {
                    if (expand_payment_trans_details) {
                        include_payment_details.setVisibility(View.GONE);
                        activitySearchDetails_tv_payment.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                        activitySearchDetails_tv_payment.setTextColor(getResources().getColor(R.color.colorBlack));
                        activitySearchDetails_tv_payment.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                        expand_payment_trans_details = false;

                    } else {
                        include_payment_details.setVisibility(View.VISIBLE);
                        activitySearchDetails_tv_payment.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                        activitySearchDetails_tv_payment.setTextColor(getResources().getColor(R.color.colorWhite));
                        activitySearchDetails_tv_payment.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);

                        expand_payment_trans_details = true;
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                break;


            // FIXME: 24-09-2021 


            case R.id.activitySearchDetails_tv_cashier_receipt:

                try {
                    if (expand_cashier_receipt_details) {
                        include_tv_cashier_receipt.setVisibility(View.GONE);
                        activitySearchDetails_tv_cashier_receipt.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                        activitySearchDetails_tv_cashier_receipt.setTextColor(getResources().getColor(R.color.colorBlack));
                        activitySearchDetails_tv_cashier_receipt.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                        expand_cashier_receipt_details = false;

                    } else {
                        include_tv_cashier_receipt.setVisibility(View.VISIBLE);
                        activitySearchDetails_tv_cashier_receipt.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                        activitySearchDetails_tv_cashier_receipt.setTextColor(getResources().getColor(R.color.colorWhite));
                        activitySearchDetails_tv_cashier_receipt.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);

                        expand_cashier_receipt_details = true;
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                break;


            case R.id.activitySearchDetails_tv_councillor_adjustment:

                try {
                    if (expand_councillor_adjustment) {
                        include_councillor_adjustment.setVisibility(View.GONE);
                        activitySearchDetails_tv_councillor_adjustment.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                        activitySearchDetails_tv_councillor_adjustment.setTextColor(getResources().getColor(R.color.colorBlack));
                        activitySearchDetails_tv_councillor_adjustment.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                        expand_councillor_adjustment = false;

                    } else {
                        include_councillor_adjustment.setVisibility(View.VISIBLE);
                        activitySearchDetails_tv_councillor_adjustment.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                        activitySearchDetails_tv_councillor_adjustment.setTextColor(getResources().getColor(R.color.colorWhite));
                        activitySearchDetails_tv_councillor_adjustment.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);

                        expand_councillor_adjustment = true;
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                break;
            case R.id.activitySearchDetails_tv_council_discount:

                try {
                    if (expand_council_discount) {
                        include_tv_council_discount.setVisibility(View.GONE);
                        activitySearchDetails_tv_council_discount.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                        activitySearchDetails_tv_council_discount.setTextColor(getResources().getColor(R.color.colorBlack));
                        activitySearchDetails_tv_council_discount.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                        expand_council_discount = false;

                    } else {
                        include_tv_council_discount.setVisibility(View.VISIBLE);
                        activitySearchDetails_tv_council_discount.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                        activitySearchDetails_tv_council_discount.setTextColor(getResources().getColor(R.color.colorWhite));
                        activitySearchDetails_tv_council_discount.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);

                        expand_council_discount = true;
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                break;
            case R.id.activitySearchDetails_tv_government_policy:

                try {
                    if (expand_government_policy) {
                        include_tv_government_policy.setVisibility(View.GONE);
                        activitySearchDetails_tv_government_policy.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                        activitySearchDetails_tv_government_policy.setTextColor(getResources().getColor(R.color.colorBlack));
                        activitySearchDetails_tv_government_policy.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                        expand_government_policy = false;

                    } else {
                        include_tv_government_policy.setVisibility(View.VISIBLE);
                        activitySearchDetails_tv_government_policy.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                        activitySearchDetails_tv_government_policy.setTextColor(getResources().getColor(R.color.colorWhite));
                        activitySearchDetails_tv_government_policy.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);

                        expand_government_policy = true;
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                break;
            case R.id.activitySearchDetails_tv_demand_note:

                try {
                    if (expand_demand_note) {
                        include_search_details_demand_note.setVisibility(View.GONE);
                        activitySearchDetails_tv_demand_note.setBackground(getDrawable(R.drawable.square_corner_solid_grey));
                        activitySearchDetails_tv_demand_note.setTextColor(getResources().getColor(R.color.colorBlack));
                        activitySearchDetails_tv_demand_note.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_down_24), null);
                        expand_demand_note = false;

                    } else {
                        include_search_details_demand_note.setVisibility(View.VISIBLE);
                        activitySearchDetails_tv_demand_note.setBackground(getDrawable(R.drawable.square_corner_solid_blue));
                        activitySearchDetails_tv_demand_note.setTextColor(getResources().getColor(R.color.colorWhite));
                        activitySearchDetails_tv_demand_note.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, getResources().getDrawable(R.drawable.ic_baseline_keyboard_arrow_up_24), null);

                        expand_demand_note = true;
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                break;
            case R.id.tvDownloadDemandNote:
                getDemandNote();
                break;

        }
        if (intent != null) {
            startActivity(intent);
        }


    }

    public void initLandlordPropertyDialog(SearchPropertyModel searchResponseModel) {
        LayoutInflater factory = LayoutInflater.from(this);
        final View deleteDialogView = factory.inflate(R.layout.dialog_edit_landlord_property_details, null);
        dialogLandlordProperty = new AlertDialog.Builder(this).create();
        dialogLandlordProperty.setView(deleteDialogView);

        WindowManager.LayoutParams params = dialogLandlordProperty.getWindow().getAttributes();
        params.width = WindowManager.LayoutParams.MATCH_PARENT;
        params.height = WindowManager.LayoutParams.MATCH_PARENT;
        params.gravity = Gravity.CENTER;
        dialogLandlordProperty.getWindow().setAttributes(params);
        dialogLandlordProperty.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);


        Button btn_save_ = deleteDialogView.findViewById(R.id.btn_save_);


        EditText edt_landlord_street_number = deleteDialogView.findViewById(R.id.edt_landlord_street_number);
        EditText edt_landlord_street_name = deleteDialogView.findViewById(R.id.edt_landlord_street_name);
        EditText edt_landlord_new_street_number = deleteDialogView.findViewById(R.id.edt_landlord_new_street_number);

        img_address_proof_property = deleteDialogView.findViewById(R.id.img_address_proof_property);
        img_lin_conveyance_capture_property = deleteDialogView.findViewById(R.id.img_lin_conveyance_capture_property);

        lin_address_proof_property = deleteDialogView.findViewById(R.id.lin_address_proof_property);
        lin_conveyance_capture_property = deleteDialogView.findViewById(R.id.lin_conveyance_capture_property);

        //  img_address_proof = deleteDialogView.findViewById(R.id.img_address_proof);


        // FIXME: 16-05-2022

        EditText edt_landlord_section = deleteDialogView.findViewById(R.id.edt_landlord_section);
        EditText edt_landlord_constituency = deleteDialogView.findViewById(R.id.edt_landlord_constituency);
        EditText edt_landlord_ward = deleteDialogView.findViewById(R.id.edt_landlord_ward);
        EditText edt_landlord_chiefdom = deleteDialogView.findViewById(R.id.edt_landlord_chiefdom);
        EditText edt_landlord_postcode = deleteDialogView.findViewById(R.id.edt_landlord_postcode);
        EditText edt_landlord_province = deleteDialogView.findViewById(R.id.edt_landlord_province);
        EditText edt_landlord_district = deleteDialogView.findViewById(R.id.edt_landlord_district);
        EditText edt_landlord_area = deleteDialogView.findViewById(R.id.edt_landlord_area);
        EditText edt_landlord_additional_address = deleteDialogView.findViewById(R.id.edt_landlord_additional_address);


        edt_landlord_postcode.setText(searchResponseModel.getPostcode());
        edt_landlord_province.setText(searchResponseModel.getProvince());
        edt_landlord_district.setText(searchResponseModel.getDistrict());
        edt_landlord_chiefdom.setText(searchResponseModel.getChiefdom());
        edt_landlord_constituency.setText(searchResponseModel.getConstituency());
        edt_landlord_ward.setText(searchResponseModel.getWard() + "");
        edt_landlord_section.setText(searchResponseModel.getSection());


        // FIXME: 20-09-2021

        edt_landlord_street_number.setText(searchResponseModel.getStreetNumber());
        edt_landlord_street_name.setText(searchResponseModel.getStreetName());
        edt_landlord_new_street_number.setText(searchResponseModel.getStreet_numbernew());
        edt_landlord_area.setText(JsonObject.optJSONObject("property").optString("propertyArea"));
        edt_landlord_additional_address.setText(JsonObject.optJSONObject("property").optJSONObject("landlord").optString("additional_address_id"));


        dialogLandlordProperty.show();


        img_address_proof_property.setOnClickListener(v -> OpenCamera(CODE_ADDRESS_PROOF_PROPERTY));
        img_lin_conveyance_capture_property.setOnClickListener(v -> OpenCamera(CODE_CONVEYANCE_CAPTURE_PROPERTY));


        edt_landlord_street_name.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (searchResponseModel.getStreetName() == null || searchResponseModel.getStreetName().isEmpty()) {
                    lin_address_proof_property.setVisibility(View.VISIBLE);
                    lin_conveyance_capture_property.setVisibility(View.VISIBLE);
                    isAddressRequired = true;
                    old_street_flag_landlord = "1";
                } else if (!searchResponseModel.getStreetName().equalsIgnoreCase(s.toString())) {
                    lin_address_proof_property.setVisibility(View.VISIBLE);
                    lin_conveyance_capture_property.setVisibility(View.VISIBLE);
                    isAddressRequired = true;
                    old_street_flag_landlord = "1";
                } else {
                    lin_address_proof_property.setVisibility(View.GONE);
                    lin_conveyance_capture_property.setVisibility(View.GONE);
                    isAddressRequired = false;
                    old_street_flag_landlord = "0";

                }
            }
        });
        ///// newly added
        edt_landlord_street_number.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (searchResponseModel.getStreetNumber() == null || searchResponseModel.getStreetNumber().isEmpty()) {
                    if (s.length() > 0) {
                        lin_address_proof_property.setVisibility(View.VISIBLE);
                        lin_conveyance_capture_property.setVisibility(View.VISIBLE);
                        isAddressRequired = true;
                        old_street_flag_landlord = "1";
                    }
                } else if (!searchResponseModel.getStreetNumber().equalsIgnoreCase(s.toString())) {
                    lin_address_proof_property.setVisibility(View.VISIBLE);
                    lin_conveyance_capture_property.setVisibility(View.VISIBLE);
                    isAddressRequired = true;
                    old_street_flag_landlord = "1";
                } else {
                    lin_address_proof_property.setVisibility(View.GONE);
                    lin_conveyance_capture_property.setVisibility(View.GONE);
                    isAddressRequired = false;
                    old_street_flag_landlord = "0";

                }
            }
        });

        edt_landlord_new_street_number.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (searchResponseModel.getStreet_numbernew() == null || searchResponseModel.getStreet_numbernew().isEmpty()) {
                    if (s.length() > 0) {
                        lin_address_proof_property.setVisibility(View.VISIBLE);
                        lin_conveyance_capture_property.setVisibility(View.VISIBLE);
                        isAddressRequired = true;
                        old_street_flag_landlord = "1";
                    }
                } else if (!searchResponseModel.getStreet_numbernew().equalsIgnoreCase(s.toString())) {
                    lin_address_proof_property.setVisibility(View.VISIBLE);
                    lin_conveyance_capture_property.setVisibility(View.VISIBLE);
                    isAddressRequired = true;
                    old_street_flag_landlord = "1";
                } else {
                    lin_address_proof_property.setVisibility(View.GONE);
                    lin_conveyance_capture_property.setVisibility(View.GONE);
                    isAddressRequired = false;
                    old_street_flag_landlord = "0";

                }
            }
        });

        btn_save_.setOnClickListener(v -> {
            HashMap<String, String> req_params = new HashMap<>();

            // FIXME: 20-09-2021

            req_params.put("landlord_street_number", "" + edt_landlord_street_number.getText().toString());
            req_params.put("landlord_street_numbernew", "" + edt_landlord_new_street_number.getText().toString());
            req_params.put("landlord_street_name", "" + edt_landlord_street_name.getText().toString());
            //req_params.put("old_street_flag", "" + old_street_flag_landlord);
            req_params.put("requested_by", "Cashier");


            // FIXME: 16-05-2022

            req_params.put("temp_ward", "" + edt_landlord_ward.getText().toString());
            req_params.put("temp_constituency", "" + edt_landlord_constituency.getText().toString());
            req_params.put("temp_section", "" + edt_landlord_section.getText().toString());
            req_params.put("temp_chiefdom", "" + edt_landlord_chiefdom.getText().toString());
            req_params.put("temp_district", "" + edt_landlord_district.getText().toString());
            req_params.put("temp_province", "" + edt_landlord_province.getText().toString());
            req_params.put("temp_postcode", "" + edt_landlord_postcode.getText().toString());


            //  if (isAddressRequired) {
            if (!list_map_landlord_property.containsKey("address_document")) {
                Toast.makeText(ActivityMainDetails.this, "Please select address document", Toast.LENGTH_SHORT).show();
                return;
            }
            //  }

            list_file_landlord_property = new ArrayList<>();
            for (Map.Entry<String, File> entry : list_map_landlord_property.entrySet()) {
                list_file_landlord_property.add(new PART(entry.getKey(), entry.getValue()));
            }

            if (list_file_landlord_property.size() == 0) {
                Toast.makeText(ActivityMainDetails.this, "Image shouldn't be empty", Toast.LENGTH_SHORT).show();
                return;
            }


            String finalURL = URL_LANDLORD_PROPERTY_APPROVE + landlordModel.getPropertyId();

            apiRequest.callMultiFileUpload(
                    finalURL,
                    req_params,
                    list_file_landlord_property,
                    // PrefUtil.getAuthType(mContext) + " " + PrefUtil.getToken(mContext),
                    PrefUtil.getAuthType(mContext) + " " + PrefUtil.getToken(mContext),
                    "upload_data_property");


        });

    }


    @Override
    public void OnCallBackSuccess(String tag, String response) {

        if (tag.equalsIgnoreCase("upload_data")) {

            file_verification_document = null;
            file_address_proof = null;

            if (dialogLandlord != null && dialogLandlord.isShowing())
                dialogLandlord.dismiss();
            lin_address_proof.setVisibility(View.GONE);
            lin_id_proof.setVisibility(View.GONE);
            img_address_proof.setImageDrawable(getDrawable(R.drawable.placeholder));
            img_verification_document.setImageDrawable(getDrawable(R.drawable.placeholder));

            try {
                JSONObject object = new JSONObject(response);
                Toast.makeText(this, "" + object.getString("status") + " Please wait for approval", Toast.LENGTH_SHORT).show();
            } catch (JSONException e) {
                e.printStackTrace();
            }


        }
        if (tag.equalsIgnoreCase("upload_data_property")) {

            list_map_landlord_property.clear();
            list_file_landlord_property.clear();

            if (dialogLandlordProperty != null && dialogLandlordProperty.isShowing())
                dialogLandlordProperty.dismiss();

            lin_address_proof_property.setVisibility(View.GONE);
            img_address_proof_property.setImageDrawable(getDrawable(R.drawable.placeholder));


            try {
                JSONObject object = new JSONObject(response);
                Toast.makeText(this, "" + object.getString("status") + " Please wait for approval", Toast.LENGTH_SHORT).show();
            } catch (JSONException e) {
                e.printStackTrace();
            }


        }
        if (tag.equalsIgnoreCase("upload_data_occupancy")) {


            try {
                JSONObject object = new JSONObject(response);
                Log.d("upload_data_occupancy", object.toString());
                Toast.makeText(this, "" + object.getString("success") + " Please wait for approval", Toast.LENGTH_SHORT).show();
                dialogOccupancy.dismiss();
            } catch (JSONException e) {
                e.printStackTrace();
            }


        }
        if (tag.equalsIgnoreCase("getReceipt")) {

            ReceiptResponse receiptResponse = new Gson().fromJson(response, ReceiptResponse.class);

            recycler_view_receipt.setHasFixedSize(true);
            recycler_view_receipt.setFocusable(false);

            recycler_view_receipt.setAdapter(new ReceiptAdapter(receiptResponse.getDatas() != null ? receiptResponse.getDatas() : new ArrayList<>(), new OnItemClickListener() {
                @Override
                public void onItemClick(View view, int position) {
                    switch (view.getId()) {
                        case R.id.tvView:
                            Intent intent = new Intent(ActivityMainDetails.this, WebViewActivity.class);
                            intent.putExtra("url", receiptResponse.getDatas().get(position).getUrl());
                            startActivity(intent);
                            break;
                        case R.id.tvDownload:
                            if (!TextUtils.isEmpty(receiptResponse.getDatas().get(position).getPdf_url())) {
                               // checkStoragePermission(receiptResponse.getDatas().get(position).getPdf_url());
                                DownloadManager.Companion.downloadFile(ActivityMainDetails.this, receiptResponse.getDatas().get(position).getPdf_url());


                            }
                            break;
                    }
                }
            }));


        }
        if (tag.equalsIgnoreCase("getOccupancyType")) {
            OccupancyTypeResponse res = new Gson().fromJson(response, OccupancyTypeResponse.class);
            list_occupancy_type = res.getDatas().getOccupancyType();
            list_occupancy_title = res.getDatas().getTitles();


        }

    }

    @Override
    public void OnCallBackError(String tag, String error, int i) {

    }

    private ProgressDialog progressDialog;

    public void getReceipt() {
        String url = URL_LANDLORD_RECEIPT + getIntent().getStringExtra("property_id");
        apiRequest.callGetRequest(url, "getReceipt");
    }

    public void getOccupancyType() {
        String url = "http://mrms.sigmaventuressl.com/apiv2/get-occupency-types";
        apiRequest.callGetRequest(URL_OCCUPANCY_TYPE, "getOccupancyType");

    }

    private void getDemandNote() {
        HashMap<String, String> headers = new HashMap<>();
        headers.put("Accept", "application/json");
        headers.put("Authorization", PrefUtil.getAuthType(mContext) + " " + PrefUtil.getToken(mContext));
        progressDialog = new ProgressDialog(mContext);
        new RestApiRequestListener(this, TAG_LAND_LORD_RECEIPT, RestApiUrl.URL_DEMAND_NOTE + dataItem.getPropertyId() + "/" + dataItem.getAssessmentYear(), headers, null, new RestApiRequestListener.setOnRequestListener() {
            @Override
            public void onPreExecute() {
                progressDialog.setMessage("" + mContext.getResources().getString(R.string.loading_please_wait));
                progressDialog.setCancelable(false);
                progressDialog.show();
            }

            @Override
            public void onSuccessListener(String response) {
                if (progressDialog != null) {
                    if (progressDialog.isShowing()) {
                        progressDialog.dismiss();
                    }
                }
                LandLordReceiptResponse mLandLordReceiptResponse = new Gson().fromJson(response, LandLordReceiptResponse.class);
                if (!TextUtils.isEmpty(mLandLordReceiptResponse.getPdf_path())) {
                   // checkStoragePermission(mLandLordReceiptResponse.getPdf_path());
                    DownloadManager.Companion.downloadFile(ActivityMainDetails.this, mLandLordReceiptResponse.getPdf_path());

                }
            }

            @Override
            public void onErrorListener(String errorMessage) {
                if (progressDialog != null) {
                    if (progressDialog.isShowing()) {
                        progressDialog.dismiss();
                    }
                }
            }
        }).getRequest();

    }

    private void getRecipientDemandNote() {
        HashMap<String, String> headers = new HashMap<>();
        headers.put("Accept", "application/json");
        headers.put("Authorization", PrefUtil.getAuthType(mContext) + " " + PrefUtil.getToken(mContext));
        progressDialog = new ProgressDialog(mContext);
        new RestApiRequestListener(this, TAG_LAND_LORD_RECEIPT, "http://67.211.221.76/mrms-link/apiv2/payment/receipt-name" + "/" + dataItem.getPropertyId() + "/" + dataItem.getAssessmentYear(),
                headers, null, new RestApiRequestListener.setOnRequestListener() {
            @Override
            public void onPreExecute() {
                progressDialog.setMessage("" + mContext.getResources().getString(R.string.loading_please_wait));
                progressDialog.setCancelable(false);
                progressDialog.show();
            }

            @Override
            public void onSuccessListener(String response) {
                if (progressDialog != null) {
                    if (progressDialog.isShowing()) {
                        progressDialog.dismiss();
                    }
                }
                // findViewById(R.id.edtRecipientName)
                try {
                    JSONObject obj = new JSONObject(response);

                    if (!obj.isNull("recipient_name")) {
                        EditText edtRecipientName = findViewById(R.id.edtRecipientName);
                        edtRecipientName.setText(obj.optString("recipient_name"));
                    }
                } catch (JSONException e) {
                    throw new RuntimeException(e);
                }


            }

            @Override
            public void onErrorListener(String errorMessage) {
                if (progressDialog != null) {
                    if (progressDialog.isShowing()) {
                        progressDialog.dismiss();
                    }
                }
            }
        }).getRequest();

    }


    public void initOccupancyDialog() {
        try {
            TabDataInitializer.initOccupancyDialog(this, JsonObject.getJSONObject("property"), list_occupancy_title, OccupancyType, list_occupancy_type, occupancyModel, apiRequest);
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }

    }

    private void showProfileOrNotification(String type) {
        Intent mIntent = new Intent(mContext, ActivityCep.class);
        mIntent.putExtra("type", type);
        startActivity(mIntent);
    }

    private void checkStoragePermission(String url) {
        Dexter.withContext(ActivityMainDetails.this)
                .withPermissions(Manifest.permission.READ_EXTERNAL_STORAGE,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE)
                .withListener(new MultiplePermissionsListener() {
                    @Override
                    public void onPermissionsChecked(MultiplePermissionsReport multiplePermissionsReport) {
                        if (multiplePermissionsReport.areAllPermissionsGranted()) {
                            // do you work now
                            DownloadPdfTask mDownloadPdfTask = new DownloadPdfTask(ActivityMainDetails.this, url);
                            mDownloadPdfTask.execute();
                        }
                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(List<PermissionRequest> list, PermissionToken permissionToken) {
                        permissionToken.continuePermissionRequest();
                    }
                })
                .check();
    }
}
