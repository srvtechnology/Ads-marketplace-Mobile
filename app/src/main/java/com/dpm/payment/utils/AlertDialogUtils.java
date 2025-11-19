package com.dpm.payment.utils;

import android.content.Context;
import android.view.View;

import androidx.appcompat.app.AlertDialog;

import com.dpm.payment.R;

public class AlertDialogUtils {

    public static void showInternetConnNotAvailableDialog(Context mCtx)
    {
        AlertDialog mAlertDialog;
        AlertDialog.Builder builder = new AlertDialog.Builder(mCtx, R.style.AlertDialogTheme);
        // Set a title for alert dialog
        builder.setTitle("Alert?");

        builder.setCancelable(false);

        // Ask the final question
        builder.setMessage(""+mCtx.getResources().getString(R.string.internet_connection_not_available));

        // Set the alert dialog yes button click listener
        builder.setPositiveButton("OK", (dialog, which) -> {
            // Do something when user clicked the Yes button
            // Set the TextView visibility GONE
            dialog.dismiss();
        });

        /*// Set the alert dialog no button click listener
        builder.setNegativeButton("Cancel", (dialog, which) -> {
            // Do something when No button clicked
            if (dialog != null) {
                dialog.dismiss();
            }
        });*/

        mAlertDialog = builder.create();
        // Display the alert dialog on interface
        mAlertDialog.show();
    }

    public static void showCommonDialog(Context mCtx,String mMsg)
    {
        AlertDialog mAlertDialog;
        AlertDialog.Builder builder = new AlertDialog.Builder(mCtx, R.style.AlertDialogTheme);
        // Set a title for alert dialog
        builder.setTitle("Alert?");

        builder.setCancelable(false);

        // Ask the final question
        builder.setMessage(""+mMsg);

        // Set the alert dialog yes button click listener
        builder.setPositiveButton("OK", (dialog, which) -> {
            // Do something when user clicked the Yes button
            // Set the TextView visibility GONE
            dialog.dismiss();
        });

        /*// Set the alert dialog no button click listener
        builder.setNegativeButton("Cancel", (dialog, which) -> {
            // Do something when No button clicked
            if (dialog != null) {
                dialog.dismiss();
            }
        });*/

        mAlertDialog = builder.create();
        // Display the alert dialog on interface
        mAlertDialog.show();
    }


    public static void showLogoutDialog(Context mCtx)
    {
        AlertDialog mAlertDialog;
        AlertDialog.Builder builder = new AlertDialog.Builder(mCtx, R.style.AlertDialogTheme);
        // Set a title for alert dialog
        builder.setTitle("Alert?");

        builder.setCancelable(false);

        // Ask the final question
        builder.setMessage(""+mCtx.getResources().getString(R.string.do_you_want_to_logout));

        // Set the alert dialog yes button click listener
        builder.setPositiveButton("OK", (dialog, which) -> {
            // Do something when user clicked the Yes button
            // Set the TextView visibility GONE
            dialog.dismiss();
        });

        // Set the alert dialog no button click listener
        builder.setNegativeButton("Cancel", (dialog, which) -> {
            // Do something when No button clicked
            if (dialog != null) {
                dialog.dismiss();
            }
        });

        mAlertDialog = builder.create();
        // Display the alert dialog on interface
        mAlertDialog.show();
    }
}
