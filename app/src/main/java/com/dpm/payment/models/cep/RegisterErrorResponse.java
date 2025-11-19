package com.dpm.payment.models.cep;

public class RegisterErrorResponse {
    public Boolean getSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    Boolean success = true;
    String message = "";
}
