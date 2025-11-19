package com.dpm.payment.models.cep

class ComplaintsModel(
    val complaintsTitle: String,
    val complaintsIcon: Int,
    val information: String,
    val reason: List<String>,
    val isEmergencyService: Boolean = false
)
