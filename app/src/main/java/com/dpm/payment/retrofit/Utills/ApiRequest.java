package com.dpm.payment.retrofit.Utills;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.dpm.payment.BuildConfig;
import com.dpm.payment.retrofit.interfaces.ApiInterface;
import com.dpm.payment.retrofit.interfaces.OnCallBackListner;
import com.google.gson.GsonBuilder;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;

import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;


public class ApiRequest {
    private Context context;
    private OnCallBackListner listner;
    private ProgressDialog progressDialog;


    public ApiRequest(Context context, OnCallBackListner listner) {
        this.context = context;
        this.listner = listner;

    }

    private void loader() {
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        progressDialog = new ProgressDialog(context);
        progressDialog.setMessage("Please Wait...");
        progressDialog.setCancelable(false);


    }


    public void callGetRequest(String url, String tag) {
        if (NetWorkChecker.check(context)) {
            //    if (!tag.equals(CUSTOMER_CHAT_COUNT)) {
            loader();
            if (progressDialog != null) {
                progressDialog.show();
            }
            //   }

            ApiInterface apiInterface = ApiClient.getClient().create(ApiInterface.class);
            Call<String> callMethod = apiInterface.get(url, tag);
            callMethod.enqueue(new Callback<String>() {
                @Override
                public void onResponse(Call<String> call, Response<String> response) {

                    onCallBackSuccess(call, response);
                }

                @Override
                public void onFailure(Call<String> call, Throwable t) {
                    onCallBackFaild(call, t);
                }
            });
        }

    }


    public void callPostFormData(String url, HashMap<String, String> params,String header, String tag) {
        if (NetWorkChecker.check(context)) {

            //   if (!tag.equals(MESSAGE_LIST)) {
            loader();
            if (progressDialog != null) {
                progressDialog.show();
            }
            //   }

            ApiInterface apiInterface = ApiClient.getClient().create(ApiInterface.class);
            Call<String> callMethod = apiInterface.getPostByFromData(url, params,header, tag);
            callMethod.enqueue(new Callback<String>() {
                @Override
                public void onResponse(Call<String> call, Response<String> response) {

                    onCallBackSuccess(call, response);
                    if (BuildConfig.DEBUG) {
                        try {
                            Log.i("response_body" + call.request().header("tag"), response.body());
                            Log.i("response_body" + call.request().header("tag"), url);
                            Log.i("response_body" + call.request().header("tag") + "_params", "" + new GsonBuilder().create().toJson(params));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }


                }

                @Override
                public void onFailure(Call<String> call, Throwable t) {
                    onCallBackFaild(call, t);
                }
            });
        }

    }


    public void callFileUpload(String url, @NonNull HashMap<String, String> param, @NonNull PART part, @NonNull PART part1, @NonNull PART part2, String header, String tag) {

        if (NetWorkChecker.check(context)) {
            loader();
            if (progressDialog != null) {
                progressDialog.show();
            }

            ApiInterface service = ApiClient.getClient().create(ApiInterface.class);

            Call<String> stringCall = service.uploadMultiPart(url, getParam(param), Params.createMultiPart(part), Params.createMultiPart(part1), Params.createMultiPart(part2), header, tag);
            stringCall.enqueue(new Callback<String>() {
                @Override
                public void onResponse(@NonNull Call<String> call, @NonNull Response<String> response) {

                    onCallBackSuccess(call, response);
                }

                @Override
                public void onFailure(@NonNull Call<String> call, @NonNull Throwable t) {

                    onCallBackFaild(call, t);

                }
            });
        }

    }
    public void callFileUpload(String url, @NonNull HashMap<String, String> param, @NonNull PART part, String header, String tag) {

        if (NetWorkChecker.check(context)) {
            loader();
            if (progressDialog != null) {
                progressDialog.show();
            }

            ApiInterface service = ApiClient.getClient().create(ApiInterface.class);

            Call<String> stringCall = service.uploadMultiPart(url, getParam(param), Params.createMultiPart(part),header, tag);
            stringCall.enqueue(new Callback<String>() {
                @Override
                public void onResponse(@NonNull Call<String> call, @NonNull Response<String> response) {

                    onCallBackSuccess(call, response);
                }

                @Override
                public void onFailure(@NonNull Call<String> call, @NonNull Throwable t) {

                    onCallBackFaild(call, t);

                }
            });
        }

    }

    public void callMultiFileUpload(String url, @NonNull HashMap<String, String> param, @NonNull List<PART> part, String header, String tag) {

        if (NetWorkChecker.check(context)) {
            loader();
            if (progressDialog != null) {
                progressDialog.show();
            }

            ApiInterface service = ApiClient.getClient().create(ApiInterface.class);

            Call<String> stringCall = service.uploadListMultiPart(url, getParam(param), Params.createPartList(part),header, tag);
            stringCall.enqueue(new Callback<String>() {
                @Override
                public void onResponse(@NonNull Call<String> call, @NonNull Response<String> response) {

                    onCallBackSuccess(call, response);
                }

                @Override
                public void onFailure(@NonNull Call<String> call, @NonNull Throwable t) {

                    onCallBackFaild(call, t);

                }
            });
        }

    }

    public void callFileUpload(String url, @NonNull HashMap<String, String> param, @NonNull PART part, @NonNull PART part1, String header, String tag) {

        if (NetWorkChecker.check(context)) {
            loader();
            if (progressDialog != null) {
                progressDialog.show();
            }

            ApiInterface service = ApiClient.getClient().create(ApiInterface.class);

            Call<String> stringCall = service.uploadMultiPart(url, getParam(param), Params.createMultiPart(part),Params.createMultiPart(part1),header, tag);
            stringCall.enqueue(new Callback<String>() {
                @Override
                public void onResponse(@NonNull Call<String> call, @NonNull Response<String> response) {

                    onCallBackSuccess(call, response);
                }

                @Override
                public void onFailure(@NonNull Call<String> call, @NonNull Throwable t) {

                    onCallBackFaild(call, t);

                }
            });
        }

    }


    public void onCallBackSuccess(Call<String> call, Response<String> response) {

        if (response.isSuccessful()) {

            if (progressDialog != null) {
                progressDialog.dismiss();
            }


            try {
                listner.OnCallBackSuccess(call.request().header("tag"), response.body().toString());

            } catch (Exception e) {
                listner.OnCallBackError(call.request().header("tag"), e.getMessage(), -1);
                e.printStackTrace();
            }
        } else {
            if (progressDialog != null) {
                progressDialog.dismiss();
            }
            try {
                JSONObject object = new JSONObject(response.errorBody().toString());

                if (object.has("error"))
                    ToastUtils.showLong((Activity) context, object.getString("error"), true);


            } catch (JSONException e) {
                e.printStackTrace();
                // ToastUtils.showLong((Activity) context, context.getString(R.string.Somethingwrong), true);

            }


        }


    }


    public void onCallBackFaild(Call<String> call, Throwable t) {


        try {
            if (progressDialog != null) {
                progressDialog.dismiss();
            }
            if (listner != null) {
                listner.OnCallBackError(call.request().header("tag"), t.getMessage(), -1);
            }

            //  ToastUtils.showLong((Activity) context, context.getString(R.string.Somethingwrong), true);
            Log.e("response_body" + call.request().header("tag"), call.toString());

        } catch (Exception e) {

            listner.OnCallBackError(call.request().header("tag"), e.getMessage(), -1);

            // ToastUtils.showLong((Activity) context, context.getString(R.string.Somethingwrong), true);

        }


    }


    private HashMap<String, RequestBody> getParam(HashMap<String, String> param) {
        HashMap<String, RequestBody> tempParam = new HashMap<>();
        for (String key : param.keySet()) {
            tempParam.put(key, toRequestBody(param.get(key)));
        }

        return tempParam;
    }


    private static RequestBody toRequestBody(String value) {
        return RequestBody.create(
                okhttp3.MultipartBody.FORM, value);
    }
}

