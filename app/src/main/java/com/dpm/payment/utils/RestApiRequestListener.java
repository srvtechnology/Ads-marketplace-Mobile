package com.dpm.payment.utils;


import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;

import com.android.volley.AuthFailureError;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.NetworkError;
import com.android.volley.NetworkResponse;
import com.android.volley.NoConnectionError;
import com.android.volley.ParseError;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.ServerError;
import com.android.volley.TimeoutError;
import com.android.volley.toolbox.StringRequest;
import com.dpm.payment.DPMPaymentApplication;
import com.dpm.payment.activities.user.ActivityUserLogin;

import java.util.Map;

public class RestApiRequestListener {
    private static final String CACHE_CONTROL = "Cache-Control";

    int NO_OF_RETRY = 2;
    int TIME_OUT = 12000;
    private String mURL;//full url
    private Map<String, String> mRequestBody;//JsonObject.toString();
    private Map<String, String> mRequestHeader;//JsonObject.toString();
    private String reqTag;
    private setOnRequestListener setOnRequestListener;
    private Activity activity;

    public RestApiRequestListener(Activity activity,
                                  String reqTag,
                                  String url,
                                  Map<String, String> mRequestHeader,
                                  Map<String, String> mRequestBody,

                                  setOnRequestListener mSetOnRequestListener) {

        this.activity = activity;
        this.mRequestBody = mRequestBody;
        this.reqTag = reqTag;
        this.mURL = url;
        this.setOnRequestListener = mSetOnRequestListener;
        this.mRequestHeader = mRequestHeader;

    }

    public void request() {

        LogUtils.showErrorLog("request", "Url:" + mURL);
        LogUtils.showErrorLog("request", "body: " + mRequestBody);

        DPMPaymentApplication.getInstance().cancelPendingRequests(reqTag);

        setOnRequestListener.onPreExecute();

        StringRequest strReq = new StringRequest(Request.Method.POST, mURL, response -> {

            LogUtils.printf("I am " + reqTag + " response: " + response);

            setOnRequestListener.onSuccessListener(response);


        }, error -> {

            boolean isSessionExpire=false;
            try {
                LogUtils.printf("I am error: " );

                //setOnRequestListener.onErrorListener(error.getMessage());
                String errorUserMessage = "";
                if (error instanceof TimeoutError || error instanceof NoConnectionError) {
                    errorUserMessage = "There is Some error Occurs\n\nNo Connection Available\nTime out error";

                    LogUtils.printf("I am volley error: TimeoutError or NoConnectionError: " + error.getMessage());
                    //This indicates that the reuest has either time out or there is no connection

                } else if (error instanceof AuthFailureError) {
                    isSessionExpire=true;
                    errorUserMessage = "Session expired please login again.";

                    LogUtils.printf("I am volley error: AuthFailureError: " + error.getMessage());
                    //Error indicating that there was an Authentication Failure while performing the request

                } else if (error instanceof ServerError) {
                    errorUserMessage = "Server not responding. Please try again.";

                    LogUtils.printf("I am volley error: ServerError: " + error.getMessage());
                    //Indicates that the server responded with a error response


                } else if (error instanceof NetworkError) {

                    errorUserMessage = "Network error. Please try again.";

                    LogUtils.printf("I am volley error: NetworkError: " + error.getMessage());
                    //Indicates that there was network error while performing the request


                } else if (error instanceof ParseError) {

                    errorUserMessage = "Invalid Data Error. Please try again.";

                    LogUtils.printf("I am volley error: ParseError: " + error.getMessage());
                    // Indicates that the server response could not be parsed

                } else {
                    errorUserMessage = "Unknown Error. Please try again.";

                    LogUtils.printf("I am volley error: Unknown Error: " + error.getMessage());

                }

                //==========================================
                setOnRequestListener.onErrorListener("Error");
                openErrorDialog(errorUserMessage,isSessionExpire);
            }catch (Exception ex)
            {
                ex.printStackTrace();
            }


            //===================
        }) {
            @Override
            public Priority getPriority() {
                return Priority.HIGH;
            }

            @Override
            public Map<String, String> getHeaders() {

                return mRequestHeader;
            }

        /*    @Override
            public byte[] getBody() {
                return mRequestBody == null ? null : mRequestBody.getBytes(StandardCharsets.UTF_8);
            }*/

            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                return mRequestBody;
            }

            @Override
            protected Response<String> parseNetworkResponse(NetworkResponse response) {
                int mStatusCode = response.statusCode;
                LogUtils.printf("Status code is  = = = > " + mStatusCode);
                response.headers.remove(CACHE_CONTROL);
                return super.parseNetworkResponse(response);
            }

        };

        //===========================


        setRetryPolicy(strReq);
        strReq.setShouldCache(false);
        DPMPaymentApplication.getInstance().addToRequestQueue(strReq, reqTag);


    }

    private void setRetryPolicy(StringRequest request) {

        DPMPaymentApplication.getInstance().getRequestQueue().getCache().clear();

        request.setRetryPolicy(new DefaultRetryPolicy(TIME_OUT, NO_OF_RETRY, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

    }

    private void openErrorDialog(String message,boolean isSessionExpire) {

        try {
            String mMessage="Retry";

            if(isSessionExpire)
            {
                mMessage="Login";
            }
            AlertDialog.Builder builder = new AlertDialog.Builder(activity);
            builder.setTitle("Error");
            builder.setCancelable(false);
            builder.setMessage("" + message);



            builder.setPositiveButton(mMessage, (dialog, id) -> {


                try {
                    if (isSessionExpire) {
                        Intent mIntent = new Intent(activity, ActivityUserLogin.class);
                        activity.startActivity(mIntent);
                        activity.finishAffinity();
                    } else {
                        request();
                    }
                }catch (Exception ex)
                {
                    ex.printStackTrace();
                }

                dialog.dismiss();
            });
            builder.setNegativeButton("Back", (dialog, id) -> {
                // User cancelled the dialog
                try {
                    //activity.startActivity(new Intent(activity, HomeActivity.class));
                   // activity.finishAffinity();
                    dialog.dismiss();

                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                dialog.dismiss();
            }).create().show();
        }catch (Exception ex)
        {
            ex.printStackTrace();
        }

    }
    public void getRequest() {

        LogUtils.showErrorLog("request", "Url:" + mURL);
        LogUtils.showErrorLog("request", "body: " + mRequestBody);

        DPMPaymentApplication.getInstance().cancelPendingRequests(reqTag);

        setOnRequestListener.onPreExecute();

        StringRequest strReq = new StringRequest(Request.Method.GET, mURL, response -> {

            LogUtils.printf("I am " + reqTag + " response: " + response);

            setOnRequestListener.onSuccessListener(response);


        }, error -> {

            boolean isSessionExpire=false;
            try {

                //      setOnRequestListener.onErrorListener(error.getMessage());


                String errorUserMessage = "";

                if (error instanceof TimeoutError || error instanceof NoConnectionError) {
                    errorUserMessage = "There is Some error Occurs\n\nNo Connection Available\nTime out error";
                    //This indicates that the reuest has either time out or there is no connection

                } else if (error instanceof AuthFailureError) {
                    isSessionExpire=true;
                    errorUserMessage = "Session expired please login again.";
                    //Error indicating that there was an Authentication Failure while performing the request

                } else if (error instanceof ServerError) {
                    errorUserMessage = "Server not responding. Please try again.";
                    //Indicates that the server responded with a error response
                } else if (error instanceof NetworkError) {

                    errorUserMessage = "Network error. Please try again.";
                    //Indicates that there was network error while performing the request
                } else if (error instanceof ParseError) {
                    errorUserMessage = "Invalid Data Error. Please try again.";
                    // Indicates that the server response could not be parsed

                } else {
                    errorUserMessage = "Unknown Error. Please try again.";
                }
                //==========================================
                setOnRequestListener.onErrorListener("Error");
                openErrorDialog(errorUserMessage,isSessionExpire);
            }catch (Exception ex)
            {
                ex.printStackTrace();
            }


            //===================
        }) {
            @Override
            public Priority getPriority() {
                return Priority.HIGH;
            }

            @Override
            public Map<String, String> getHeaders() {

                return mRequestHeader;
            }

            @Override
            protected Response<String> parseNetworkResponse(NetworkResponse response) {
                response.headers.remove(CACHE_CONTROL);
                return super.parseNetworkResponse(response);
            }
        };

        //===========================


        setRetryPolicy(strReq);
        strReq.setShouldCache(false);
        DPMPaymentApplication.getInstance().addToRequestQueue(strReq, reqTag);


    }

    public interface setOnRequestListener {
        void onPreExecute();

        void onSuccessListener(String response);

        void onErrorListener(String errorMessage);
    }

}
