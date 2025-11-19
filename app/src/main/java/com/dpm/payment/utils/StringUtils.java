package com.dpm.payment.utils;

import android.text.TextUtils;

import com.dpm.payment.NumberFormater;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Locale;

public class StringUtils {

    public static String AmountWithComma(String sTeam) {
        if (sTeam == null)
            return "";
        String temp = "";
        String temp1 = "";
        try {

            LogUtils.showErrorLog("sTeam ", "sTeam " + sTeam);

            //   String sTeam=  "1.15725030246094E10";


            if (sTeam.contains("\\.")) {
                temp1 = sTeam.split("\\.")[0];
                LogUtils.showErrorLog("temp1", "temp1 " + temp1);
            } else {
                temp1 = sTeam;
                LogUtils.showErrorLog("temp1", "temp1 " + temp1);
            }


            // long myNumber = Integer.parseInt(temp1);
            BigInteger bigIntegerStr = new BigInteger(temp1);
            NumberFormat nf = NumberFormat.getInstance(Locale.US);
            temp = nf.format(bigIntegerStr);


            if (temp.matches("\\.")) {
                LogUtils.showErrorLog("under .", "under . ");
                String mm[] = temp.split("\\.");
                LogUtils.showErrorLog(" mm[0] .", " mm[0] . " + mm[0]);
                LogUtils.showErrorLog(" mm[1] .", " mm[1] . " + mm[1]);
                if (NumberFormater.Companion.parseDouble(mm[1]) > 0.49) {
                    int RoundNum = Integer.parseInt(mm[1]) + 1;
                    temp = "" + RoundNum;

                    LogUtils.showErrorLog(" temp .", " temp " + temp);

                }
            }

        } catch (Exception ex) {
            return sTeam;
        }

        return temp;
    }

/*
    public static String roundStringValue(String s) {
        BigDecimal roundDateValue;

        try {

            BigDecimal mBigDecimal = new BigDecimal(s);
            roundDateValue = mBigDecimal.setScale(0, RoundingMode.HALF_UP);

        } catch (Exception ex) {
            ex.printStackTrace();
            return "";
        }
        return roundDateValue + "";
    }*/
    public static String roundStringValue(String s) {

        return s;
    }


    public static String roundStringValueSpacialCase(String s) {
        BigDecimal roundDateValue;

        try {
            BigDecimal mBigDecimal = new BigDecimal(s);
            roundDateValue = mBigDecimal.setScale(0, RoundingMode.HALF_DOWN);

        } catch (Exception ex) {
            ex.printStackTrace();
            return "";
        }
        return roundDateValue + "";
    }

    public static String getAppendListDataWithSpacialCharacter(ArrayList<String> mSourceData, String mAppendChar) {
        ArrayList<String> mResultData = new ArrayList<>();

        String mAppendListData = "";
        // String appendCharecter="|";
        for (int i = 0; i < mSourceData.size(); i++) {
            try {
                mAppendListData = mAppendListData + mSourceData.get(i);
                if (i < (mSourceData.size() - 1)) {
                    mAppendListData = mAppendListData + mAppendChar;
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }

        return mAppendListData;
    }

    public static String getUSStyleAmount(String s) {
        String temp = "";
        try {

            BigInteger bigIntegerStr = new BigInteger(s);
            NumberFormat nf = NumberFormat.getInstance(Locale.US);
            temp = nf.format(bigIntegerStr);

        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return temp;
    }

    public static String capitalizeEachWord(String str) {
        if (TextUtils.isEmpty(str)) {
            return "";
        }
        String[] strArray = str.split(" ");
        StringBuilder builder = new StringBuilder();
        for (String s : strArray) {
            String cap = s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase(Locale.getDefault());
            builder.append(cap + " ");
        }
        return builder.toString();
    }

}
