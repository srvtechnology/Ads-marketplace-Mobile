package com.dpm.payment.models;

import com.dpm.payment.utils.Helper;
import com.dpm.payment.utils.StringUtils;

public class DataModel {
    private String key, value;


    public DataModel(String key, String value) {
        this.key = Helper.UppercaseFirstLetters(key.replace("_"," "));
        this.value = value;
    }

    public DataModel() {
    }

    @Override
    public String toString() {
        return "DataModel{" +
                "key='" + key + '\'' +
                ", value='" + value + '\'' +
                '}';
    }

    public String getKey() {
        return key;
    }
    public void setKey(String key) {
        this.key = key;
    }
    public String getValue() {
        return value;
    }
    public void setValue(String value) {
        this.value = value;
    }

}
