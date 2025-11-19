package com.dpm.payment.activities;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.os.Looper;
import android.provider.Settings;
import android.widget.Button;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.dpm.payment.utils.LogUtils;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResponse;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionDeniedResponse;
import com.karumi.dexter.listener.PermissionGrantedResponse;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.single.PermissionListener;
import com.dpm.payment.BuildConfig;
import com.dpm.payment.R;

import org.json.JSONObject;

import java.text.DateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class PickUpLocationActivity extends AppCompatActivity {

    // location updates interval - 10sec
    public static final int REQUEST_FOR_DEVICE_LOCATION = 25;
    private static final long UPDATE_INTERVAL_IN_MILLISECONDS = 10000;

    private static final long FASTEST_UPDATE_INTERVAL_IN_MILLISECONDS = 5000;

    private static final int REQUEST_CHECK_SETTINGS = 100;
    Context context;
    Button btnLocation;
    ProgressDialog progressDialog;
    // location last updated time
    private String mLastUpdateTime;
    private FusedLocationProviderClient mFusedLocationClient;
    private SettingsClient mSettingsClient;
    private LocationRequest mLocationRequest;
    private LocationSettingsRequest mLocationSettingsRequest;
    private LocationCallback mLocationCallback;
    private Location mCurrentLocation;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pick_up_location);
        this.setFinishOnTouchOutside(true);
        context = this;

        progressDialog = new ProgressDialog(this);

        progressDialog.setMessage("Location Fetching");

        progressDialog.setCancelable(false);

        progressDialog.show();


        initLocation();

        startLocationFetching();

    }


    private void initLocation() {

        mFusedLocationClient = LocationServices.getFusedLocationProviderClient(this);
        mSettingsClient = LocationServices.getSettingsClient(this);

        mLocationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                super.onLocationResult(locationResult);
                // location is received
                mCurrentLocation = locationResult.getLastLocation();
                mLastUpdateTime = DateFormat.getTimeInstance().format(new Date());

                updateLocationUI();
            }
        };


        mLocationRequest = new LocationRequest();
        mLocationRequest.setInterval(UPDATE_INTERVAL_IN_MILLISECONDS);
        mLocationRequest.setFastestInterval(FASTEST_UPDATE_INTERVAL_IN_MILLISECONDS);
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);

        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder();
        builder.addLocationRequest(mLocationRequest);
        mLocationSettingsRequest = builder.build();
    }


    private void startLocationUpdates() {

        mSettingsClient
                .checkLocationSettings(mLocationSettingsRequest)
                .addOnSuccessListener(this, new OnSuccessListener<LocationSettingsResponse>() {
                    @SuppressLint("MissingPermission")
                    @Override
                    public void onSuccess(LocationSettingsResponse locationSettingsResponse) {
                        // LogUtils.printf( "All location settings are satisfied.");

                        // Toast.makeText(getApplicationContext(), "Started location updates!", Toast.LENGTH_SHORT).show();

                        //noinspection MissingPermission
                        mFusedLocationClient.requestLocationUpdates(mLocationRequest,
                                mLocationCallback, Looper.myLooper());
                        //  Toast.makeText(context, "startLocationUpdates before", Toast.LENGTH_SHORT).show();

                        // updateLocationUI();
                        //   Toast.makeText(context, "startLocationUpdates after", Toast.LENGTH_SHORT).show();

                    }


                })
                .addOnFailureListener(this, new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        int statusCode = ((ApiException) e).getStatusCode();
                        switch (statusCode) {
                            case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                                LogUtils.printf("Location settings are not satisfied. Attempting to upgrade " +
                                        "location settings ");
                                try {
                                    // Show the dialog by calling startResolutionForResult(), and check the
                                    // result in onActivityResult().
                                    ResolvableApiException rae = (ResolvableApiException) e;
                                    rae.startResolutionForResult(PickUpLocationActivity.this, REQUEST_CHECK_SETTINGS);
                                } catch (IntentSender.SendIntentException sie) {
                                    LogUtils.printf("PendingIntent unable to execute request.");
                                }
                                break;
                            case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                                String errorMessage = "Location settings are inadequate, and cannot be " +
                                        "fixed here. Fix in Settings.";
                                //LogUtils.printf( errorMessage);

                                Toast.makeText(context, errorMessage, Toast.LENGTH_LONG).show();
                        }

                        //updateLocationUI();
                    }
                });
    }


    public void startLocationFetching() {
        // Requesting ACCESS_FINE_LOCATION using Dexter library
        Dexter.withActivity(this)
                .withPermission(Manifest.permission.ACCESS_FINE_LOCATION)
                .withListener(new PermissionListener() {
                    @Override
                    public void onPermissionGranted(PermissionGrantedResponse response) {

                        startLocationUpdates();
                    }

                    @Override
                    public void onPermissionDenied(PermissionDeniedResponse response) {
                        if (response.isPermanentlyDenied()) {
                            // open device settings when the permission is
                            // denied permanently
                            openSettings();
                        }
                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(PermissionRequest permission, PermissionToken token) {
                        token.continuePermissionRequest();
                    }
                }).check();
    }


    public void stopLocationUpdates() {
        // Removing location updates
        mFusedLocationClient
                .removeLocationUpdates(mLocationCallback)
                .addOnCompleteListener(this, new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        //Toast.makeText(getApplicationContext(), "Location updates stopped!", Toast.LENGTH_SHORT).show();

                    }
                });
    }


    private void updateLocationUI() {

        String loc = null;
        if (mCurrentLocation != null) {
            loc =
                    "Lat: " + mCurrentLocation.getLatitude() + ", " +
                            "Lng: " + mCurrentLocation.getLongitude();

            try {

                JSONObject object = new JSONObject();

                object.put("lat", mCurrentLocation.getLatitude());
                object.put("lng", mCurrentLocation.getLongitude());
                object.put("date_in_mili", mCurrentLocation.getTime());
                //object.put("date", mCurrentLocation.getTime());

                // LogUtils.printf("I am Address State: " + getStateFromLatLng(mCurrentLocation));
                //getStateFromLatLng(mCurrentLocation);




                //New South Wales(-31.840233,145.612793)
                //Queensland(-20.917574,142.702789)
                //Tasmania(-41.640079,146.315918)
                //South Australia(-30.000233,136.209152)
                //Western Australia(-25.760321,122.805176)
                //Victoria (-37.020100,144.964600)
                //Northern Territory (-19.491411,132.550964)
                //Australian Capital Territory (-35.473469,149.012375)


                LogUtils.printf("I am Address State: " + getStateFromLatLng(mCurrentLocation));

                successReult(object);
//                new ReqUpdateLocation(object, String.valueOf(mCurrentLocation.getLatitude()), String.valueOf(mCurrentLocation.getLongitude()), getStateFromLatLng(mCurrentLocation)).execute();



            } catch (Exception e) {
                e.printStackTrace();
            }

            stopLocationUpdates();
        }

        // giving a blink animation on TextView


        // location last updated time
        LogUtils.printf("I am loc Last updated on: " + loc);
        LogUtils.printf("I am loc Last updated on: " + mLastUpdateTime);


    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {
            // Check for the integer request code originally supplied to startResolutionForResult().
            case REQUEST_CHECK_SETTINGS:
                switch (resultCode) {
                    case Activity.RESULT_OK:
                        LogUtils.printf("User agreed to make required location settings changes.");
                        // Nothing to do. startLocationupdates() gets called in onResume again.
                        break;
                    case Activity.RESULT_CANCELED:
                        LogUtils.printf("User chose not to make required location settings changes.");

                        break;
                }
                break;
        }
    }

    private void openSettings() {
        Intent intent = new Intent();
        intent.setAction(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        Uri uri = Uri.fromParts("package",
                BuildConfig.APPLICATION_ID, null);
        intent.setData(uri);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    private void successReult(JSONObject object) {

        try {
            progressDialog.dismiss();
        } catch (Exception e) {
            e.printStackTrace();
        }


        Intent intent = getIntent();
        intent.putExtra("response", object.toString());
        setResult(RESULT_OK, intent);
        finish();
    }

    private void cancelReult() {
        Intent intent = getIntent();

        setResult(RESULT_CANCELED, intent);
        finish();
    }

    public String getStateFromLatLng(Location location) {
        String state = "";
        try {


            Geocoder geocoder;
            List<Address> addresses;
            geocoder = new Geocoder(context, Locale.getDefault());


            addresses = geocoder.getFromLocation(location.getLatitude(), location.getLongitude(), 1); // Here 1 represent max location result to returned, by documents it recommended 1 to 5


            if (addresses.size() > 0) {
                state = addresses.get(0).getAdminArea();
            } else {
                state = "";
            }


        } catch (Exception e) {
            e.printStackTrace();
        }


        return state;

    }




}