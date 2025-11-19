package com.dpm.payment.utils;

import android.util.Log;

public class LogUtils {
    public static final boolean LOG_STAT = true;//BuildConfig.LOG_STAT;

    // public static final boolean LOG_STAT=true;
    public static void showPrintln(String text) {
        if (LOG_STAT) {
            System.out.println("" + text);
        }
    }

    public static void showErrorLog(String tag, String text) {
        try {
            if (LOG_STAT) {
                int maxLogSize = 2000;
                for (int i = 0; i <= text.length() / maxLogSize; i++) {
                    int start = i * maxLogSize;
                    int end = (i + 1) * maxLogSize;
                    end = Math.min(end, text.length());
                    Log.e("" + tag, "" + text);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void showErrorLog(String tag, String text, Throwable throwable) {
        try {
            if (LOG_STAT) {
                int maxLogSize = 2000;
                for (int i = 0; i <= text.length() / maxLogSize; i++) {
                    int start = i * maxLogSize;
                    int end = (i + 1) * maxLogSize;
                    end = Math.min(end, text.length());
                    Log.e("" + tag, "" + text, throwable);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void showInfoLog(String tag, String text) {
        try {
            if (LOG_STAT) {
                int maxLogSize = 2000;
                for (int i = 0; i <= text.length() / maxLogSize; i++) {
                    int start = i * maxLogSize;
                    int end = (i + 1) * maxLogSize;
                    end = Math.min(end, text.length());
                    Log.i("" + tag, "" + text);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public static void showDebugLog(String tag, String text) {
        try {
            if (LOG_STAT) {
                int maxLogSize = 2000;
                for (int i = 0; i <= text.length() / maxLogSize; i++) {
                    int start = i * maxLogSize;
                    int end = (i + 1) * maxLogSize;
                    end = Math.min(end, text.length());
                    Log.d("" + tag, "" + text);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void printf(String message) {

        System.out.println(message);
    }
}
