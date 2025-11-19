package com.dpm.payment.models.cep;

public class CepModel {

    private String cepTitle;
    private int cepIcon;

    public CepModel(String cepTitle, int cepIcon) {
        this.cepTitle = cepTitle;
        this.cepIcon = cepIcon;
    }

    public String getCepTitle() {
        return cepTitle;
    }

    public void setCepTitle(String cepTitle) {
        this.cepTitle = cepTitle;
    }

    public int getCepIcon() {
        return cepIcon;
    }

    public void setCepIcon(int cepIcon) {
        this.cepIcon = cepIcon;
    }
}
