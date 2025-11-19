package com.dpm.payment.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import com.dpm.payment.activities.user.LandlordResponseModel;
import com.dpm.payment.models.LoginModel;
import com.dpm.payment.models.cep.GuestUser;
import com.dpm.payment.models.cep.GuestUserResponse;
import com.google.gson.Gson;

import static com.dpm.payment.utils.CommonUtils.getObjectFromJson;
import static com.dpm.payment.utils.ConstantData.GUEST_INFO;


public class PrefUtil {



    public static String getJsonFromObject(Object object, Class<?> classType) {
        String jsonText = "";
        if (object != null) {
            Gson gson = new Gson();
            jsonText = gson.toJson(object, classType);
        }
        return jsonText;
    }

    public static Object getObjectFromJson(String jsonText, Class<?> classType) {
        Object object = null;
        if (jsonText != null) {
            Gson gson = new Gson();
            object = gson.fromJson(jsonText, classType);
        }
        return object;
    }

    public static void savePayment(Context context, String mPaymentUrl) {

        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        sp.edit().putString("payment_url", mPaymentUrl).apply();

    }


    public static String getPaymentUrl(Context context) {
        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        String landlord_property_list = sp.getString("payment_url", null);

        return landlord_property_list;
    }

    //----------------------------------  user login ---------------------


    public static void saveLandlordPropertyList(Context context, String PropertyListJsonObject) {

        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        sp.edit().putString("Landlord_property_list", PropertyListJsonObject).apply();

    }


    public static String getLandlordPropertyList(Context context) {
        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        String landlord_property_list = sp.getString("Landlord_property_list", null);

        return landlord_property_list;
    }

    public static void saveLandlordProfile(Context context, String profileJsonObject) {

        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        sp.edit().putString("Landlord_profile", profileJsonObject).apply();

    }

    public static LandlordResponseModel getLandlordProfile(Context context) {
        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        String userJson = sp.getString("Landlord_profile", null);

        LogUtils.showErrorLog("Enter Landlord_profile ","Landlord_profile  : "+userJson);
        LandlordResponseModel user = null;
        if (userJson != null) {
            user = (LandlordResponseModel) getObjectFromJson(userJson, LandlordResponseModel.class);
        }
        return user;
    }

    public static String getLandlordProfileString(Context context) {
        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        String userJson = sp.getString("Landlord_profile", null);


        return userJson;
    }


    //---------------------------------- Cashier user ---------------------

    public static void saveProfile(Context context, String profileJsonObject) {

        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        sp.edit().putString("user_profile", profileJsonObject).apply();

    }


    public static LoginModel getProfile(Context context) {
        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        String userJson = sp.getString("user_profile", null);
        LoginModel user = null;
        if (userJson != null) {
            user = (LoginModel) getObjectFromJson(userJson, LoginModel.class);
        }
        return user;
    }
    public static String getToken(Context context) {
        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        String userJson = sp.getString("user_profile", null);
        LoginModel user = null;
        if (userJson != null) {
            user = (LoginModel) getObjectFromJson(userJson, LoginModel.class);
        }
        return user.getToken();
    }
    public static String getAuthType(Context context) {
        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        String userJson = sp.getString("user_profile", null);
        LoginModel user = null;
        if (userJson != null) {
            user = (LoginModel) getObjectFromJson(userJson, LoginModel.class);
        }
        return user.getAuthType();
    }

    public static void saveProfileAddress(Context context, String addressJsonObject) {

        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        sp.edit().putString("user_profile_address", addressJsonObject).apply();

    }



    //ifUserExistReturnUserId else return blank;
    public static String getUserId(Context context) {

        String userId;

        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);


        String userJson = sp.getString("user_profile", null);

        if (userJson != null) {
            LoginModel user = (LoginModel) getObjectFromJson(userJson, LoginModel.class);
            userId = user.getUser().getId() + "";
        } else {
            userId = "";
        }

        return userId;
    }


    //TODO Create by Naresh: saveSearchRequest
    public static String getSearchForLandlordRequest(Context mContext) {

        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(mContext);

        return sp.getString("saveSearchRequestLand", null);

    }
    //TODO Create by Naresh: saveSearchRequest
    public static void saveSearchLandlordRequest(Context mContext, String response) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(mContext);
        sp.edit().putString("saveSearchRequestLand", response).apply();
    }


    //TODO Create by Debabrata: saveSearchRequest
    public static void saveSearchRequest(Context mContext, String response) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(mContext);
        sp.edit().putString("saveSearchRequest", response).apply();
    }

    //TODO Create by Debabrata: getSearchRequestResponse
    public static String getSearchRequest(Context mContext) {

        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(mContext);

        return sp.getString("saveSearchRequest", null);

    }

    public static void mClearALLData(Context context) {

        SharedPreferences sp = android.preference.PreferenceManager.getDefaultSharedPreferences(context);
        sp.edit().clear().commit();
    }

    public static void saveCouncilName(Context mContext, String councilName) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(mContext);
        sp.edit().putString("council_name", councilName).apply();
    }

    public static String getCouncilName(Context mContext) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(mContext);
        return sp.getString("council_name", null);
    }

    public static void saveGuestUser(Context mContext, GuestUserResponse mGuestUserResponse){
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(mContext);
        if(mGuestUserResponse==null){
            sharedPreferences.edit().putString(GUEST_INFO, "").apply();
            return;
        }
        String strJson =new Gson().toJson(mGuestUserResponse);
        sharedPreferences.edit().putString(GUEST_INFO, strJson).apply();
    }

    public static GuestUserResponse getGuestUser(Context mContext){
        String strJson = PreferenceManager.getDefaultSharedPreferences(mContext).getString(GUEST_INFO, "");
        if(strJson==null || strJson.trim()=="")
            return null;
        else
            return new Gson().fromJson(strJson,GuestUserResponse.class);
    }

    public static String getValueFromKey(Context mContext, String key) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(mContext);
        return sp.getString(key, "");
    }
    public static void setValueForKey(Context mContext, String key,String value) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(mContext);
        sp.edit().putString(key, value).apply();;
    }
}
