package com.dpm.payment.utils;

import android.app.Activity;
import android.app.DatePickerDialog;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiManager;
import android.provider.MediaStore;
import android.provider.Settings;
import android.text.TextUtils;
import android.text.format.Formatter;
import android.util.Patterns;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.DatePicker;
import android.widget.ImageView;
import android.widget.Toast;

import com.dpm.payment.NumberFormater;
import com.dpm.payment.R;
import com.dpm.payment.activities.login.ActivityLogin;
import com.google.gson.Gson;
import com.squareup.picasso.Callback;
import com.squareup.picasso.Picasso;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.FileNameMap;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.URL;
import java.net.URLConnection;
import java.nio.charset.StandardCharsets;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Locale;

import static android.content.Context.WIFI_SERVICE;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

public class CommonUtils {

    public static void hideKeyBoard(Activity activity) {

        try {
            InputMethodManager imm = (InputMethodManager) activity.getSystemService(Activity.INPUT_METHOD_SERVICE);
            View view = activity.getCurrentFocus();
            if (view == null) {
                view = new View(activity);
            }
            imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public static void hideKeyBoard(Activity activity, View view) {

        /*InputMethodManager imm = (InputMethodManager)mContext.getSystemService(mContext.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(clGoogle.getWindowToken(), 0);*/

        try {
            InputMethodManager imm = (InputMethodManager) activity.getSystemService(Activity.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String loadJSONFromAsset(Context mContext, String mFileName) {
        String json = null;

        try {
            InputStream is = mContext.getAssets().open(mFileName + ".json");
            int size = is.available();
            byte[] buffer = new byte[size];
            is.read(buffer);
            is.close();
            json = new String(buffer, StandardCharsets.UTF_8);
        } catch (IOException ex) {
            ex.printStackTrace();
            return null;
        }
        return json;
    }


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

    public static void showCustomCalendarDialog(Context mContext, int maxCalendarLimit, int minCalendarLimit, final GetDOBFromDialogCallBack dobFromDialogCallBack) {

        final Calendar c = Calendar.getInstance();
        int mYear = c.get(Calendar.YEAR);
        int mMonth = c.get(Calendar.MONTH);
        int mDay = c.get(Calendar.DAY_OF_MONTH);

        final Calendar minCal = Calendar.getInstance();
        minCal.add(Calendar.YEAR, minCalendarLimit);
        //minCal.add(Calendar.DATE,-5);

        final Calendar MaxCal = Calendar.getInstance();
        MaxCal.add(Calendar.YEAR, maxCalendarLimit);

        //  dp.setMaxDate(System.currentTimeMillis());


        DatePickerDialog datePickerDialog = new DatePickerDialog(mContext, R.style.date_picker_theme,
                new DatePickerDialog.OnDateSetListener() {

                    @Override
                    public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                        dobFromDialogCallBack.getDOBFromDialog("" + year + "-" + (monthOfYear + 1) + "-" + dayOfMonth);
                        //txtDate.setText(dayOfMonth + "-" + (monthOfYear + 1) + "-" + year);

                    }
                }, mYear, mMonth, mDay);
        datePickerDialog.getDatePicker().setMaxDate(MaxCal.getTimeInMillis());
        datePickerDialog.getDatePicker().setMinDate(minCal.getTimeInMillis());
        datePickerDialog.show();


    }

    public static void showCustomCalendarDialogForDOB(Context mContext, int maxCalendarLimit, int minCalendarLimit, final GetDOBFromDialogCallBack dobFromDialogCallBack) {

        final Calendar c = Calendar.getInstance();
        int mYear = c.get(Calendar.YEAR);
        int mMonth = c.get(Calendar.MONTH);
        int mDay = c.get(Calendar.DAY_OF_MONTH);

        final Calendar minCal = Calendar.getInstance();
        minCal.add(Calendar.YEAR, minCalendarLimit);

        final Calendar MaxCal = Calendar.getInstance();
        MaxCal.add(Calendar.YEAR, maxCalendarLimit);

        DatePickerDialog datePickerDialog = new DatePickerDialog(mContext, R.style.date_picker_theme,
                new DatePickerDialog.OnDateSetListener() {

                    @Override
                    public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                        Calendar calendar = Calendar.getInstance();
                        calendar.set(year, monthOfYear, dayOfMonth);

                        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");

                        String dateString = dateFormat.format(calendar.getTime());

                        dobFromDialogCallBack.getDOBFromDialog(dateString);
                        //txtDate.setText(dayOfMonth + "-" + (monthOfYear + 1) + "-" + year);

                    }
                }, mYear, mMonth, mDay);
        datePickerDialog.getDatePicker().setMaxDate(MaxCal.getTimeInMillis());
        datePickerDialog.getDatePicker().setMinDate(minCal.getTimeInMillis());
        datePickerDialog.show();


    }

    public static boolean isInternetConnectAvailable(Context context) {
        ConnectivityManager cm = (ConnectivityManager) context
                .getSystemService(Context.CONNECTIVITY_SERVICE);

        NetworkInfo wifiNetwork = cm
                .getNetworkInfo(ConnectivityManager.TYPE_WIFI);
        if (wifiNetwork != null && wifiNetwork.isConnected()) {
            return true;
        }

        NetworkInfo mobileNetwork = cm
                .getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
        if (mobileNetwork != null && mobileNetwork.isConnected()) {
            return true;
        }

        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        return activeNetwork != null && activeNetwork.isConnected();

    }

    public static String getDateForSetGoal(String userTime) {
        String newFormatTime = "";
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'", Locale.ENGLISH);//2019-03-08T12:00:19Z
            SimpleDateFormat output = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
            Date d = null;
            try {
                d = sdf.parse(userTime);
            } catch (ParseException e) {
                e.printStackTrace();
            }
            newFormatTime = output.format(d);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return newFormatTime;
    }

    public static String getDeviceId(Context context) {
        String deviceId = "0";
        try {
            deviceId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return deviceId;
    }

    public static String getLocalIpAddress() {
        try {
            for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements(); ) {
                NetworkInterface intf = en.nextElement();
                for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements(); ) {
                    InetAddress inetAddress = enumIpAddr.nextElement();
                    if (!inetAddress.isLoopbackAddress()) {
                        String ip = Formatter.formatIpAddress(inetAddress.hashCode());
                        return ip;
                    }
                }
            }
        } catch (SocketException ignored) {
        }
        return null;
    }

    public static String getWifiMacID(Context context) {

        String m_wlanMacAdd = "";
        WifiManager m_wm = (WifiManager) context.getSystemService(WIFI_SERVICE);
        m_wlanMacAdd = m_wm.getConnectionInfo().getMacAddress();

        return m_wlanMacAdd;
    }

    public static boolean isValidUrl(String url) {
        /* Try creating a valid URL */
        try {
            new URL(url).toURI();
            return true;
        }

        // If there was an Exception
        // while creating URL object
        catch (Exception e) {
            return false;
        }
    }

    public static void show(Context ctx, String s) {
        Toast.makeText(ctx, s, Toast.LENGTH_LONG).show();
    }

    public static int dpToPx(int dp) {
        return (int) (dp * Resources.getSystem().getDisplayMetrics().density);
    }

    public static String getDateForBot() {
        String currentDate = "";
        Date _date = Calendar.getInstance().getTime();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ssZ", Locale.ENGLISH);
        currentDate = sdf.format(_date);
        return currentDate;
    }

    public static String getDateForEditGoalModification() {
        String currentDate = "";
        try {
            Date _date = Calendar.getInstance().getTime();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
            currentDate = sdf.format(_date);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return currentDate;
    }

    public static String getMimeType(String fileUrl) throws IOException {
        FileNameMap fileNameMap = URLConnection.getFileNameMap();
        String type = fileNameMap.getContentTypeFor(fileUrl);
        return type;
    }


    public static String getYYYYMMDDFormatFromTimestamp(long timeStamp) {
        Date myDate = null;
        myDate = new Date(timeStamp);

        SimpleDateFormat timeFormat = new SimpleDateFormat("d MMM, yyyy");
        String finalDate = timeFormat.format(myDate);

        return finalDate;

    }

    public static void loadImages(ImageView view, String filePath, Bitmap bitmap) {
        if (bitmap != null) {
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream);
            byte[] byteArray = stream.toByteArray();
            //           mImageBase64 = "" + Base64.encodeToString(byteArray, Base64.DEFAULT);
            //         mImageType = "jpg";//(photos.get(0).split("\\."))[1];
        }

        Picasso.get()
                .load("file://" + filePath)
                // .centerCrop()
                .error(R.drawable.ic_my_profile)
                .into(view, new Callback() {
                    @Override
                    public void onSuccess() {
                    }

                    @Override
                    public void onError(Exception e) {
                        try {
                            if (bitmap != null) {
                                view.setImageBitmap(bitmap);
                            }
                        } catch (Exception ex) {
                            ex.printStackTrace();
                            view.setBackgroundResource(R.drawable.ic_my_profile);
                        }
                    }

                });

    }

    public static void loadImages(ImageView view, String filePath) {
        Picasso.get()
                .load(filePath)
                // .centerCrop()
                .error(R.drawable.ic_my_profile)
                .into(view);

    }


    public static Bitmap getBitmapFromURL(String src, int imgHeight, int imgWidth) {
        try {
            URL url = new URL(src);
            HttpURLConnection connection = (HttpURLConnection) url
                    .openConnection();
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            Bitmap myBitmap = BitmapFactory.decodeStream(input);
            return getResizedBitmap(myBitmap, imgHeight, imgWidth);
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    public static Bitmap getResizedBitmap(Bitmap bm, int newHeight, int newWidth) {
        int width = bm.getWidth();
        int height = bm.getHeight();
        float scaleWidth = ((float) newWidth) / width;
        float scaleHeight = ((float) newHeight) / height;
        // CREATE A MATRIX FOR THE MANIPULATION
        Matrix matrix = new Matrix();
        // RESIZE THE BIT MAP
        matrix.postScale(scaleWidth, scaleHeight);

        // "RECREATE" THE NEW BITMAP
        Bitmap resizedBitmap = Bitmap.createBitmap(bm, 0, 0, width, height,
                matrix, false);

        return resizedBitmap;
    }

    public static Uri getImageUri(Context inContext, Bitmap inImage) {
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        inImage.compress(Bitmap.CompressFormat.JPEG, 100, bytes);
        String path = MediaStore.Images.Media.insertImage(inContext.getContentResolver(), inImage, "Title", null);
        return Uri.parse(path);
    }


    public interface GetDOBFromDialogCallBack {
        void getDOBFromDialog(String mDOB);
    }

    public static HashMap<String, String> getHeader(){
        HashMap<String, String> headers = new HashMap<>();
        headers.put("Accept", "application/json");
        return headers;
    }

    public static boolean isValidEmail(CharSequence target) {
        return (!TextUtils.isEmpty(target) && Patterns.EMAIL_ADDRESS.matcher(target).matches());
    }

    public static String calculateDiscountRatePayable(String ratePayable, String pensionerDiscount, String disabilityDiscount){

        return String.valueOf((int)(NumberFormater.Companion.parseDouble(ratePayable) - NumberFormater.Companion.parseDouble(pensionerDiscount) - NumberFormater.Companion.parseDouble(disabilityDiscount)));
    }


    public  static void showLogoutDialog(AppCompatActivity activity)
    {
        try {
            AlertDialog mAlertDialog;
            AlertDialog.Builder builder = new AlertDialog.Builder(activity, R.style.AlertDialogTheme);
            // Set a title for alert dialog
            builder.setTitle("Alert?");

            builder.setCancelable(false);

            // Ask the final question
            builder.setMessage("" + activity.getResources().getString(R.string.do_you_want_to_logout));

            // Set the alert dialog yes button click listener
            builder.setPositiveButton("OK", (dialog, which) -> {
                // Do something when user clicked the Yes button
                // Set the TextView visibility GONE
                dialog.dismiss();
                Intent i = new Intent(activity, ActivityLogin.class);
                i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                activity.startActivity(i);
                activity.finish();

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

}
