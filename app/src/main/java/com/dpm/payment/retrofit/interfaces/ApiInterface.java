package com.dpm.payment.retrofit.interfaces;

import com.google.gson.JsonObject;

import java.util.HashMap;
import java.util.List;

import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.FieldMap;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.Headers;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.Part;
import retrofit2.http.PartMap;
import retrofit2.http.Url;

public interface ApiInterface {

    @GET()
    Call<String> get(@Url String url, @Header("tag") String tag);

    @Headers({"Content-Type: application/json"})
    @POST()
    Call<String> getPostByJsonBody(@Url String url, @Body HashMap<String, String> params, @Header("tag") String tag);


    @Headers({"Content-Type: application/json"})
    @POST()
    Call<String> getPostByJsonBody(@Url String url, @Body JsonObject params, @Header("tag") String tag);


    @FormUrlEncoded
    @POST()
    Call<String> getPostByFromData(@Url String url, @FieldMap HashMap<String, String> params, @Header("Authorization") String header, @Header("tag") String tag);


    @Multipart
    @POST()
    Call<String> uploadMultiPart(@Url String url, @PartMap HashMap<String, RequestBody> param, @Part MultipartBody.Part file, @Part MultipartBody.Part file1, @Part MultipartBody.Part file2, @Header("Authorization") String header, @Header("tag") String tag);

    @Multipart
    @POST()
    Call<String> uploadMultiPart(@Url String url, @PartMap HashMap<String, RequestBody> param, @Part MultipartBody.Part file, @Part MultipartBody.Part file1, @Header("Authorization") String header, @Header("tag") String tag);

    @Multipart
    @POST()
    Call<String> uploadMultiPart(@Url String url, @PartMap HashMap<String, RequestBody> param, @Part MultipartBody.Part file, @Header("Authorization") String header, @Header("tag") String tag);

    @Multipart
    @POST()
    Call<String> uploadListMultiPart(@Url String url, @PartMap HashMap<String, RequestBody> param, @Part List<MultipartBody.Part> file, @Header("Authorization") String header, @Header("tag") String tag);

}
