package com.dpm.payment.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.dpm.payment.models.AssessmentHistory;
import com.dpm.payment.models.TransactionModel;
import com.dpm.payment.utils.DataUtils;
import com.dpm.payment.utils.Helper;
import com.dpm.payment.utils.LogUtils;
import com.dpm.payment.utils.StringUtils;
import com.dpm.payment.R;

import java.math.BigDecimal;
import java.util.List;


public class AssessmentHistoryAdapter extends RecyclerView.Adapter<AssessmentHistoryAdapter.MyViewHolder> {

    private List<AssessmentHistory> listOfNav;


    public AssessmentHistoryAdapter(List<AssessmentHistory> listOfNav) {
        this.listOfNav = listOfNav;

    }

    @Override
    public int getItemViewType(int position) {

        return position;
    }

    @NonNull
    @Override
    public MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.row_assisment_history, parent, false);
        return new MyViewHolder(itemView);
    }


    @Override
    public void onBindViewHolder(@NonNull final MyViewHolder holder, int position) {

    /*    if (position==0){
            ViewGroup.MarginLayoutParams marginLayoutParams = new ViewGroup.MarginLayoutParams(mRecyclerView.getLayoutParams());
            marginLayoutParams.setMargins(0, 10, 0, 10);
            mRecyclerView.setLayoutParams(marginLayoutParams);
        }
*/

        final AssessmentHistory mAssessmentHistory = listOfNav.get(position);


        try {
            holder.txt_assessment_year.setText("Assessed Value " + mAssessmentHistory.getAssessmentYear());
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        try {
            holder.tv_council_adjustment_params.setText(mAssessmentHistory.getCounsilAdjustment());
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        try {
            holder.tv_net_assessed_value.setText(StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(mAssessmentHistory.getAssedValue()))));
        } catch (Exception ex) {
            ex.printStackTrace();
        }


        try {
            holder.tv_rate_payable_2022.setText(StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(mAssessmentHistory.getRatePayable()))));
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        try {
            holder.tv_discount_applicable.setText(StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(mAssessmentHistory.getDiscountApplicable()))));

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        try {
            holder.tv_discounted_rate_payable.setText(StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(mAssessmentHistory.getDiscountRatePayable()))));
            Helper.DISCOUNTED_RATE_PAYABLE=StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(mAssessmentHistory.getDiscountRatePayable())));
        } catch (Exception ex) {
            ex.printStackTrace();
        }







 /*       try {

            holder.tvAssessmentYearValue.setText(Helper.ASSESSED_VALUE);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
          try {

            holder.tv_discount_applicable.setText(Helper.DISCOUNT_APPLICABLE);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
          try {

            holder.tv_rate_payable.setText(Helper.RATE_PAYABLE);
        } catch (Exception ex) {
            ex.printStackTrace();
        }*/


        try {

            //  String mAssessmentYear = (mAssessmentHistory.getAssessmentYear() == null) ? "0" : "" + mAssessmentHistory.getAssessmentYear();

            holder.tvAssessmentYearValue.setText(StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(mAssessmentHistory.getCurrentYearAssessmentAmount()))));
        } catch (Exception ex) {
            ex.printStackTrace();
        }


        try {


            String mCurrentYearAssessmentAmount = (mAssessmentHistory.getCurrentYearAssessmentAmount() == null) ? "0" : "" + getSeparatedByComma(mAssessmentHistory.getCurrentYearAssessmentAmount());
            holder.AssessmentAmount.setText(mCurrentYearAssessmentAmount);

        } catch (Exception ex) {
            ex.printStackTrace();
        }
        try {

            String mArrearDue = (mAssessmentHistory.getArrearDue() == null) ? "0" : "" + getSeparatedByComma(mAssessmentHistory.getArrearDue());
            holder.tvArrearValue.setText(mArrearDue);

        } catch (Exception ex) {
            ex.printStackTrace();
        }

    /*    try {

            String mArrearDue = (mAssessmentHistory.getPropertyRateWithGst() == null) ? "0" : "" + getSeparatedByComma(mAssessmentHistory.getPropertyRateWithGst());
            holder.tv_discounted_rate_payable.setText(mArrearDue);

        } catch (Exception ex) {
            ex.printStackTrace();
        }*/

        try {

            String mPenalty = (mAssessmentHistory.getPenalty() == null) ? "0" : "" + getSeparatedByComma(mAssessmentHistory.getPenalty());
            holder.tvPenaltyValue.setText(mPenalty);

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        try {

            String mPenalty = (mAssessmentHistory.getPenalty() == null) ? "0" : "" + getSeparatedByComma(mAssessmentHistory.getPenalty());
            holder.tvPenaltyValue.setText(mPenalty);

        } catch (Exception ex) {
            ex.printStackTrace();
        }
        try {

            String mAmountPaid = (mAssessmentHistory.getAmountPaid() == null) ? "0" : "" + getSeparatedByComma(mAssessmentHistory.getAmountPaid());
            holder.tvAmountPaid.setText(mAmountPaid);

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        try {

            String mAmountPaid = (mAssessmentHistory.getAmountPaid() == null) ? "0" : "" + getSeparatedByComma(mAssessmentHistory.getAmountPaid());
            holder.tvAmountPaid.setText(mAmountPaid);

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        try {
            // TODO: Amount due Amount Due from balance key  //
            String mDueAmount = (mAssessmentHistory.getBalance() == null) ? "0" : "" + getSeparatedByComma(mAssessmentHistory.getBalance_due_new());

            holder.tvDueValue.setText(mDueAmount);
            LogUtils.showErrorLog(" mDue amount ", " mDue amount " + mDueAmount);

        } catch (Exception ex) {
            ex.printStackTrace();
        }


    }

    @Override
    public int getItemCount() {


        return listOfNav == null ? 0 : listOfNav.size();
    }


    class MyViewHolder extends RecyclerView.ViewHolder {

        TextView tvAssessmentYearValue;
        TextView AssessmentAmount;
        TextView tvArrearValue;
        TextView tvPenaltyValue;
        TextView tvAmountPaid;
        TextView tvDueValue;
        TextView tv_assessed_value;
        TextView tv_discounted_rate_payable;
        TextView tv_discount_applicable;
        TextView txt_assessment_year;
        TextView tv_council_adjustment_params;
        TextView tv_rate_payable_2022;
        TextView tv_net_assessed_value;


        // view create //
        MyViewHolder(View view) {
            super(view);

            tvAssessmentYearValue = view.findViewById(R.id.tvAssessmentYearValue);
            AssessmentAmount = view.findViewById(R.id.AssessmentAmount);
            tvArrearValue = view.findViewById(R.id.tvArrearValue);
            tvPenaltyValue = view.findViewById(R.id.tvPenaltyValue);
            tvAmountPaid = view.findViewById(R.id.tvAmountPaid);
            tvDueValue = view.findViewById(R.id.tvDueValue);
            tv_discounted_rate_payable = view.findViewById(R.id.tvDiscountedRatePayable);


            txt_assessment_year = view.findViewById(R.id.txtAssessmentYear);
            tv_council_adjustment_params = view.findViewById(R.id.tvCouncilAdjustmentParams);
            tv_rate_payable_2022 = view.findViewById(R.id.tvRatePayable);
            tv_discount_applicable = view.findViewById(R.id.tvDiscountApplicable);
            tv_net_assessed_value = view.findViewById(R.id.tvNetAssessedValue);
        /*    tv_assessed_value = view.findViewById(R.id.tv_assessed_value);
            tv_discount_applicable = view.findViewById(R.id.tv_discount_applicable);*/
            //   tv_rate_payable = view.findViewById(R.id.tv_rate_payable);

        }
    }

    public String getSeparatedByComma(String value) {
        return StringUtils.AmountWithComma(StringUtils.roundStringValue("" + new BigDecimal(value)));
    }

}