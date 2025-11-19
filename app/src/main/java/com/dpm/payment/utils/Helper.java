package com.dpm.payment.utils;

import com.dpm.payment.NumberFormater;

import java.util.HashMap;
import java.util.HashSet;

public class Helper {

/*    android:text="ykoroma@svl.com"
    android:text="WardC@2019"
    android:text="76100100"*/


    public static HashMap<String,String> discounted_value_Hashmap=new HashMap<>();
    public static HashMap<String,String> taxable_value_Hashmap=new HashMap<>();

    public static String roundOffDecimals(String value) {
        double a = NumberFormater.Companion.parseDouble(value);
        double roundOff = Math.round(a * 100) / 100;

        int result = (int) roundOff;
        return result + "";
    }


    public static String UppercaseFirstLetters(String str) {
        boolean prevWasWhiteSp = true;
        char[] chars = str.toCharArray();
        for (int i = 0; i < chars.length; i++) {
            if (Character.isLetter(chars[i])) {
                if (prevWasWhiteSp) {
                    chars[i] = Character.toUpperCase(chars[i]);
                }
                prevWasWhiteSp = false;
            } else {
                prevWasWhiteSp = Character.isWhitespace(chars[i]);
            }
        }
        return new String(chars);
    }


    public static String ASSESSED_VALUE = "";
    public static String DISCOUNT_APPLICABLE = "";
    public static String RATE_PAYABLE = "";
    public static String DISCOUNTED_RATE_PAYABLE = "";
}
