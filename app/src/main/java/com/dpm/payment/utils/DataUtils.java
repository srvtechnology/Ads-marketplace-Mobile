package com.dpm.payment.utils;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Base64;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.Transformation;
import android.webkit.MimeTypeMap;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.nio.charset.StandardCharsets;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Currency;
import java.util.Date;
import java.util.Enumeration;
import java.util.Locale;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class DataUtils {
    public static boolean isDataValid(String text) {
        return text != null && !text.equals("") && text.length() != 0;
    }

    /**
     * Get IP address from first non-localhost interface
     *
     * @param useIPv4 true=return ipv4, false=return ipv6
     * @return address or empty string
     */
    public static String getIPAddress(boolean useIPv4) {

        try {

            for (final Enumeration<NetworkInterface> enumerationNetworkInterface = NetworkInterface.getNetworkInterfaces(); enumerationNetworkInterface.hasMoreElements(); ) {
                final NetworkInterface networkInterface = enumerationNetworkInterface.nextElement();
                LogUtils.showErrorLog("enumerationNetworkInterface ::::", "" + enumerationNetworkInterface.hasMoreElements());
                for (Enumeration<InetAddress> enumerationIntAddress = networkInterface.getInetAddresses(); enumerationIntAddress.hasMoreElements(); ) {
                    final InetAddress inetAddress = enumerationIntAddress.nextElement();
                    final String ipAddress = inetAddress.getHostAddress();
                    LogUtils.showErrorLog("enumerationNetworkInterface ipAddress::::", "" + inetAddress.getHostAddress());
                    if (!inetAddress.isLoopbackAddress() && inetAddress instanceof Inet4Address) {
                        return ipAddress;
                    }
                }
            }
            return null;
        } catch (final Exception e) {
            return "NA";
        }
    }


    /**
     * Check weather internet connection available or not
     *
     * @return boolean result
     */

    public static boolean isInternetConnectAvailable(Context context) {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);

        NetworkInfo wifiNetwork = cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
        if (wifiNetwork != null && wifiNetwork.isConnected()) {
            return true;
        }

        NetworkInfo mobileNetwork = cm.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
        if (mobileNetwork != null && mobileNetwork.isConnected()) {
            return true;
        }

        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        return activeNetwork != null && activeNetwork.isConnected();

    }


    public static String getMimeType(String url) {
        String type = null;
        String extension = MimeTypeMap.getFileExtensionFromUrl(url);
        if (extension != null) {
            type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
        }
        return type;
    }

    public static String capitalize(String capString) {
        StringBuffer capBuffer = new StringBuffer();
        Matcher capMatcher = Pattern.compile("([a-z])([a-z]*)", Pattern.CASE_INSENSITIVE).matcher(capString);
        while (capMatcher.find()) {
            capMatcher.appendReplacement(capBuffer, capMatcher.group(1).toUpperCase() + capMatcher.group(2).toLowerCase());
        }

        return capMatcher.appendTail(capBuffer).toString();
    }


    public static String getBase64FromPath(String path) {

        String base64 = "";
        try {/*from w  w w.j a v  a2 s  .  c  om*/
            File file = new File(path);
            byte[] buffer = new byte[(int) file.length() + 100];
            @SuppressWarnings("resource")
            int length = new FileInputStream(file).read(buffer);
            base64 = Base64.encodeToString(buffer, 0, length,
                    Base64.DEFAULT);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return base64;

    }

    public static void long_log(String log) {
        try {
            int maxLogSize = 1000;
            for (int i = 0; i <= log.length() / maxLogSize; i++) {
                int start = i * maxLogSize;
                int end = (i + 1) * maxLogSize;
                end = end > log.length() ? log.length() : end;
                LogUtils.showErrorLog("text====", log.substring(start, end));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static byte[] decodeBase64(String coded) {
        byte[] valueDecoded = new byte[0];
        valueDecoded = Base64.decode(coded.getBytes(StandardCharsets.UTF_8), Base64.DEFAULT);
        return valueDecoded;
    }

    private static String encodeBase64String(byte[] coded) {
        String valueDecoded = "";
        try {
            valueDecoded = Base64.encodeToString(coded, Base64.DEFAULT);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return valueDecoded;
    }

    public static String replaceStringCharacter(String replace_string, String old_character, String newCharacter) {
        return replace_string.replaceAll(old_character, newCharacter);
    }

    public static String getCurrencySymbol(String planCountryCode) {
        String symbol = "";
        try {
            Currency currency = Currency.getInstance(planCountryCode);
            symbol = currency.getSymbol();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return symbol;
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

    public static String getDateForCommentInGallery() {
        String currentDate = "";
        try {
            Date _date = Calendar.getInstance().getTime();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'", Locale.ENGLISH);
            currentDate = sdf.format(_date);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return currentDate;
    }


    public static void expand(final View v, long duration) {
        v.measure(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        final int targetHeight = v.getMeasuredHeight();

        v.getLayoutParams().height = 0;
        v.setVisibility(View.VISIBLE);
        Animation a = new Animation() {
            @Override
            protected void applyTransformation(float interpolatedTime, Transformation t) {
                v.getLayoutParams().height = interpolatedTime == 1
                        ? ViewGroup.LayoutParams.WRAP_CONTENT
                        : (int) (targetHeight * interpolatedTime);
                v.requestLayout();
            }

            @Override
            public boolean willChangeBounds() {
                return true;
            }
        };

        //a.setDuration((int) (targetHeight / v.getContext().getResources().getDisplayMetrics().density));
        a.setDuration(duration);
        v.startAnimation(a);
    }

    public static void expandHorizontally(final View v, long duration) {
        v.measure(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        final int targetWidth = v.getMeasuredWidth();

        v.getLayoutParams().width = 0;
        v.setVisibility(View.VISIBLE);
        Animation a = new Animation() {
            @Override
            protected void applyTransformation(float interpolatedTime, Transformation t) {
                v.getLayoutParams().width = interpolatedTime == 1
                        ? ViewGroup.LayoutParams.WRAP_CONTENT
                        : (int) (targetWidth * interpolatedTime);
                v.requestLayout();
            }

            @Override
            public boolean willChangeBounds() {
                return true;
            }
        };

        //a.setDuration((int) (targtetHeight / v.getContext().getResources().getDisplayMetrics().density));
        a.setDuration(duration);
        v.startAnimation(a);
    }

    public static void collapseHorizontally(final View v, long duration) {
        final int initialWidth = v.getMeasuredWidth();

        Animation a = new Animation() {
            @Override
            protected void applyTransformation(float interpolatedTime, Transformation t) {
                if (interpolatedTime == 1) {
                    v.setVisibility(View.GONE);
                } else {
                    v.getLayoutParams().height = initialWidth - (int) (initialWidth * interpolatedTime);
                    v.requestLayout();
                }
            }

            @Override
            public boolean willChangeBounds() {
                return true;
            }
        };

        //a.setDuration((int) (initialHeight / v.getContext().getResources().getDisplayMetrics().density));
        a.setDuration(duration);
        v.startAnimation(a);
    }

    public static String getDate(long time) {
        Date date = new Date(time * 1000L); // *1000 is to convert seconds to milliseconds
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH); // the format of your date
        //  sdf.setTimeZone(TimeZone.getTimeZone("GMT-4"));

        return sdf.format(date);
    }

    public static void collapse(final View v, long duration) {
        final int initialHeight = v.getMeasuredHeight();

        Animation a = new Animation() {
            @Override
            protected void applyTransformation(float interpolatedTime, Transformation t) {
                if (interpolatedTime == 1) {
                    v.setVisibility(View.GONE);
                } else {
                    v.getLayoutParams().height = initialHeight - (int) (initialHeight * interpolatedTime);
                    v.requestLayout();
                }
            }

            @Override
            public boolean willChangeBounds() {
                return true;
            }
        };

        //a.setDuration((int) (initialHeight / v.getContext().getResources().getDisplayMetrics().density));
        a.setDuration(duration);
        v.startAnimation(a);
    }

    public static String convertUtcToLocalTime(String utcTime) {
        //utcTime = "09/16/2019, 22:08:59 PM";
        String formattedDate = "";
        SimpleDateFormat df = new SimpleDateFormat("MM/dd/yyyy, HH:mm:ss a", Locale.getDefault());
        df.setTimeZone(TimeZone.getTimeZone("UTC"));
        Date date = null;
        try {
            date = df.parse(utcTime);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        df.setTimeZone(TimeZone.getDefault());
        SimpleDateFormat df_new = new SimpleDateFormat("MM/dd/yyyy, HH:mm:ss", Locale.getDefault());
        formattedDate = df_new.format(date);
        return formattedDate;
    }

    public static String getCapsSentences(String tagName) {
        String[] splits = tagName.toLowerCase().split(" ");
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < splits.length; i++) {
            String eachWord = splits[i];
            if (i > 0 && eachWord.length() > 0) {
                sb.append(" ");
            }
            String cap = eachWord.substring(0, 1).toUpperCase()
                    + eachWord.substring(1);
            sb.append(cap);
        }
        return sb.toString();
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

    public static String getYYYYMMDDFormatFromString(String mStringFormat) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");

        Date myDate = null;
        try {
            myDate = dateFormat.parse(mStringFormat);

        } catch (ParseException e) {
            e.printStackTrace();
        }

      //  SimpleDateFormat timeFormat = new SimpleDateFormat("d MMM, yyyy");

        SimpleDateFormat timeFormat = new SimpleDateFormat("yyyy MMM, d HH:mm a",Locale.ENGLISH);
        String finalDate = timeFormat.format(myDate);



        return "" + finalDate;

    }

    public static String getDateForBot() {
        String currentDate = "";
        Date _date = Calendar.getInstance().getTime();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ssZ", Locale.ENGLISH);
        currentDate = sdf.format(_date);
        return currentDate;
    }

    public static String getDateUserInput() {
        String currentDate = "";
        try {
            Date _date = Calendar.getInstance().getTime();
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy hh:mm a", Locale.ENGLISH);
            currentDate = sdf.format(_date);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return currentDate;
    }

    public static String getLocalTimeZone() {
        String localTime = "";
        try {
            Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("GMT"),
                    Locale.getDefault());
            Date currentLocalTime = calendar.getTime();
            DateFormat date = new SimpleDateFormat("Z");
            localTime = date.format(currentLocalTime);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return localTime;
    }

    public static String getDateYYYYMMDDToMMMDDYYYY(String userTime) {
        String newFormatTime = "";
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.ENGLISH);//2019-03-08T12:00:19Z
            SimpleDateFormat output = new SimpleDateFormat("MMM dd,yyyy", Locale.ENGLISH);
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

    public static String getFormattedDateFolder(String timeZone) {

// SimpleDateFormat sdf3 = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.ENGLISH);
        SimpleDateFormat sdf3 = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.ENGLISH);
        Date d1 = null;
        try {
            d1 = sdf3.parse(timeZone);

        } catch (Exception e) {
            e.printStackTrace();
        }

        String formateDate = new SimpleDateFormat("dd-MMM , yyyy", Locale.ENGLISH).format(d1);
        return formateDate;
    }

    public static String getDateYYYYMMDDToMMMDDYYYYFile(String userTime) {
        String newFormatTime = "";
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss'.'SSS'Z'", Locale.ENGLISH);//2019-03-08T12:00:19Z
            SimpleDateFormat output = new SimpleDateFormat("MMM dd,yyyy", Locale.ENGLISH);
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


    public static String getFormattedDate(String timeZone) {

// SimpleDateFormat sdf3 = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.ENGLISH);
        SimpleDateFormat sdf3 = new SimpleDateFormat("EEE MMM dd HH:mm:ss zzz yyyy", Locale.ENGLISH);
        Date d1 = null;
        try {
            d1 = sdf3.parse(timeZone);

        } catch (Exception e) {
            e.printStackTrace();
        }

        String formateDate = new SimpleDateFormat("dd-MMM , yyyy", Locale.ENGLISH).format(d1);

        return formateDate;

    }
}