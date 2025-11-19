package com.dpm.payment.models.propertydetail;

import com.google.gson.annotations.SerializedName;

public class PaymentsItem{

	@SerializedName("transaction_id")
	private String transactionId;

	@SerializedName("amount")
	private String amount;

	@SerializedName("admin_user_id")
	private String adminUserId;

	@SerializedName("cheque_number")
	private String chequeNumber;

	@SerializedName("penalty")
	private String penalty;

	@SerializedName("created_at")
	private String createdAt;

	@SerializedName("migrate_at")
	private String migrateAt;

	@SerializedName("admin")
	private Admin admin;

	@SerializedName("deleted_at")
	private String deletedAt;

	@SerializedName("property_id")
	private String propertyId;

	@SerializedName("assessment")
	private String assessment;

	@SerializedName("total")
	private String total;

	@SerializedName("payment_type")
	private String paymentType;

	@SerializedName("balance")
	private String balance;

	@SerializedName("updated_at")
	private String updatedAt;

	@SerializedName("payee_name")
	private String payeeName;

	@SerializedName("id")
	private String id;

	public void setTransactionId(String transactionId){
		this.transactionId = transactionId;
	}

	public String getTransactionId(){
		return transactionId;
	}

	public void setAmount(String amount){
		this.amount = amount;
	}

	public String getAmount(){
		return amount;
	}

	public void setAdminUserId(String adminUserId){
		this.adminUserId = adminUserId;
	}

	public String getAdminUserId(){
		return adminUserId;
	}

	public void setChequeNumber(String chequeNumber){
		this.chequeNumber = chequeNumber;
	}

	public String getChequeNumber(){
		return chequeNumber;
	}

	public void setPenalty(String penalty){
		this.penalty = penalty;
	}

	public String getPenalty(){
		return penalty;
	}

	public void setCreatedAt(String createdAt){
		this.createdAt = createdAt;
	}

	public String getCreatedAt(){
		return createdAt;
	}

	public void setMigrateAt(String migrateAt){
		this.migrateAt = migrateAt;
	}

	public String getMigrateAt(){
		return migrateAt;
	}

	public void setAdmin(Admin admin){
		this.admin = admin;
	}

	public Admin getAdmin(){
		return admin;
	}

	public void setDeletedAt(String deletedAt){
		this.deletedAt = deletedAt;
	}

	public String getDeletedAt(){
		return deletedAt;
	}

	public void setPropertyId(String propertyId){
		this.propertyId = propertyId;
	}

	public String getPropertyId(){
		return propertyId;
	}

	public void setAssessment(String assessment){
		this.assessment = assessment;
	}

	public String getAssessment(){
		return assessment;
	}

	public void setTotal(String total){
		this.total = total;
	}

	public String getTotal(){
		return total;
	}

	public void setPaymentType(String paymentType){
		this.paymentType = paymentType;
	}

	public String getPaymentType(){
		return paymentType;
	}

	public void setBalance(String balance){
		this.balance = balance;
	}

	public String getBalance(){
		return balance;
	}

	public void setUpdatedAt(String updatedAt){
		this.updatedAt = updatedAt;
	}

	public String getUpdatedAt(){
		return updatedAt;
	}

	public void setPayeeName(String payeeName){
		this.payeeName = payeeName;
	}

	public String getPayeeName(){
		return payeeName;
	}

	public void setId(String id){
		this.id = id;
	}

	public String getId(){
		return id;
	}

	@Override
 	public String toString(){
		return 
			"PaymentsItem{" + 
			"transaction_id = '" + transactionId + '\'' + 
			",amount = '" + amount + '\'' + 
			",admin_user_id = '" + adminUserId + '\'' + 
			",cheque_number = '" + chequeNumber + '\'' + 
			",penalty = '" + penalty + '\'' + 
			",created_at = '" + createdAt + '\'' + 
			",migrate_at = '" + migrateAt + '\'' + 
			",admin = '" + admin + '\'' + 
			",deleted_at = '" + deletedAt + '\'' + 
			",property_id = '" + propertyId + '\'' + 
			",assessment = '" + assessment + '\'' + 
			",total = '" + total + '\'' + 
			",payment_type = '" + paymentType + '\'' + 
			",balance = '" + balance + '\'' + 
			",updated_at = '" + updatedAt + '\'' + 
			",payee_name = '" + payeeName + '\'' + 
			",id = '" + id + '\'' + 
			"}";
		}
}