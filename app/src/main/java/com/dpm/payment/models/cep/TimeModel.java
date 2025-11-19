package com.dpm.payment.models.cep;

public class TimeModel {

    private String timeRange;

    public TimeModel(String timeRange, Boolean isSelected) {
        this.timeRange = timeRange;
        this.isSelected = isSelected;
    }

    private Boolean isSelected=false;

    public String getTimeRange() {
        return timeRange;
    }

    public void setTimeRange(String timeRange) {
        this.timeRange = timeRange;
    }

    public Boolean getSelected() {
        return isSelected;
    }

    public void setSelected(Boolean selected) {
        isSelected = selected;
    }
}
