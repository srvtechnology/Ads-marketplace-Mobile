package com.dpm.payment.retrofit.interfaces;

import org.json.JSONObject;

public interface OnCallBackListner {

    void OnCallBackSuccess(String tag, String response);
    void OnCallBackError(String tag, String error, int i);
}
