package com.dpm.payment.models;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class SearchResponseModel {

    @SerializedName("discounted_value")
    @Expose
    private String discounted_value;

     @SerializedName("property")
    @Expose
    private SearchPropertyModel property;
    @SerializedName("paymentInQuarter")
    @Expose
    private SearchPaymentInQuarterModel paymentInQuarter;

    @SerializedName("history")
    @Expose
    private List<Object> history = null;

    public String getDiscounted_value() {
        return discounted_value;
    }

    public SearchPropertyModel getProperty() {
        return property;
    }

    public void setProperty(SearchPropertyModel property) {
        this.property = property;
    }

    public SearchPaymentInQuarterModel getPaymentInQuarter() {
        return paymentInQuarter;
    }

    public void setPaymentInQuarter(SearchPaymentInQuarterModel paymentInQuarter) {
        this.paymentInQuarter = paymentInQuarter;
    }

    public List<Object> getHistory() {
        return history;
    }

    public void setHistory(List<Object> history) {
        this.history = history;
    }
}
