package com.dpm.payment.activities.user;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.DownloadManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.Settings;
import android.view.View;
import android.webkit.DownloadListener;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import com.dpm.payment.activities.cashier.WebViewPaymentRecipt;
import com.dpm.payment.utils.AlertDialogUtils;
import com.dpm.payment.utils.DataUtils;
import com.dpm.payment.utils.LogUtils;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.MultiplePermissionsReport;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.multi.MultiplePermissionsListener;
import com.dpm.payment.R;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class WebViewPaymentActivity extends AppCompatActivity {

   public static final String KEY_PAYMENT_URL = "payment_url";
    WebView webView;
    ProgressBar progressbar;
    Context mContext;
    ImageView ivBack;
    long lDownloadID;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web_view_payment);
        mContext = this;

        setUI();
        mLoadUrl();
        onClick();

    }

    private void onClick() {
        ivBack.setOnClickListener(view -> ShowDialog());
    }

    private void mLoadUrl() {

        try {

            if (DataUtils.isInternetConnectAvailable(mContext)) {
                progressbar.setVisibility(View.VISIBLE);
                loadUrl();
            } else {

                AlertDialogUtils.showInternetConnNotAvailableDialog(mContext);

            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private void setUI() {

        webView = findViewById(R.id.webView);
        progressbar = findViewById(R.id.progressbar);
        ivBack = findViewById(R.id.ivBack);
    }

    @SuppressLint("SetJavaScriptEnabled")
    public void loadUrl() {
        try {
            String mUrl = this.getIntent().getStringExtra(KEY_PAYMENT_URL);
            //  LogUtils.showErrorLog("URL ","URL "+mUrl);

            // String mUrl  = "https://dpm.sigmaventuressl.com/paypal?property_id=9817&amount=10&mobile_number=%2B919982653053";

            // mUrl="https://www.google.com/";
            if (mUrl != null) {
                webView.loadUrl(mUrl);

                //webView.loadUrl("https://www.google.com/");
                webView.clearCache(true);
                WebSettings webSettings = webView.getSettings();
                webSettings.setJavaScriptEnabled(true);
                //  webSettings.setSupportMultipleWindows(true);
                webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
                // webView.getSettings().setBuiltInZoomControls(true);
                //   webView.setWebChromeClient(new MyWebChromeclient());
               /* webView.setWebViewClient(new WebViewClient() {
                    @Override
                    public boolean shouldOverrideUrlLoading(WebView view, String url) {
                        view.loadUrl(url);
                        return true;
                    }

                    @Override
                    public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
                        handler.proceed(); // Ignore SSL certificate errors
                    }
                });*/

                webView.setWebViewClient(new WebViewClient() {

                    @Override
                    public void onPageStarted(WebView view, String url, Bitmap favicon) {
                        super.onPageStarted(view, url, favicon);
                        progressbar.setVisibility(View.VISIBLE);
                    }

                    @Override
                    public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                        view.loadUrl(request.getUrl().toString());
                        return false;
                    }

                    @Override
                    public void onPageFinished(WebView view, String url) {
                        super.onPageFinished(view, url);
                        progressbar.setVisibility(View.GONE);

                    }

                    @Override
                    public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                        super.onReceivedError(view, request, error);
                        Toast.makeText(mContext, "Page loading error ", Toast.LENGTH_LONG).show();
                    }
                });

                webView.setDownloadListener(new DownloadListener() {

                    @Override
                    public void onDownloadStart(String url, String userAgent,
                                                String contentDisposition, String mimetype,
                                                long contentLength) {

                        LogUtils.showErrorLog("url "," url "+url);
                        ///10144/3642
                        downloadPdfWithPermission(url);

                    }
                });


            } else {
                LogUtils.showErrorLog("TAG ", " TAG URL null");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }


    }

    private void downloadPdfWithPermission(String mUrl){
        Dexter.withContext(this)
                .withPermissions(
                        Manifest.permission.READ_EXTERNAL_STORAGE,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE)
                .withListener(new MultiplePermissionsListener() {
                    @Override
                    public void onPermissionsChecked(MultiplePermissionsReport report) {
                        // check if all permissions are granted
                        if (report.areAllPermissionsGranted()) {
                            // do you work now

                            Toast.makeText(mContext,"Downloading start....",Toast.LENGTH_LONG).show();
                            mDownloadPdf(mUrl);
                        }
                        if (report.isAnyPermissionPermanentlyDenied()) {
                            // show alert dialog navigating to Settings
                            showSettingsDialog();
                        }
                        // check for permanent denial of any permission
                        if (report.isAnyPermissionPermanentlyDenied()) {
                            // permission is denied permenantly, navigate user to app settings
                        }
                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(List<PermissionRequest> permissions, PermissionToken token) {
                        token.continuePermissionRequest();
                    }
                })
                .onSameThread()
                .check();
    }
    private void mDownloadPdf(String URlPdf) {

        //String URlPdf= this.getIntent().getStringExtra(KEY_URL_PDF);
        //"http://maven.apache.org/archives/maven-1.x/maven.pdf"
        //String fileName = new SimpleDateFormat("yyyyMMddHHmm'.txt'").format(new Date());


        DownloadManager.Request request=new DownloadManager.Request(Uri.parse(URlPdf))
                .setMimeType("application/pdf")
                .setTitle("Payment receipt")// Title of the Download Notification
                .setDescription("Downloading")// Description of the Download Notification
                // .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE)// Visibility of the download Notification
                .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                //     .setDestinationUri(Uri.fromFile(filebaseDir))// Uri of the destination file
                // .setRequiresCharging(false)// Set if charging is required to begin the download
                .setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, new SimpleDateFormat("yyyy-MM-dd-HH-mm").format(new Date())+".pdf")
                .setAllowedOverMetered(true)// Set if download is allowed on Mobile network
                .setAllowedOverRoaming(true);// Set if download is allowed on roaming network
        request.allowScanningByMediaScanner();
        DownloadManager downloadManager= (DownloadManager) getSystemService(DOWNLOAD_SERVICE);
        lDownloadID = downloadManager.enqueue(request);
    }
    private void showSettingsDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(WebViewPaymentActivity.this);
        builder.setTitle("Need Permissions");
        builder.setMessage("This app needs permission to use this feature. You can grant them in app settings.");
        builder.setPositiveButton("GOTO SETTINGS", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                openSettings();
            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });
        builder.show();

    }
    // navigating user to app settings
    private void openSettings() {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        Uri uri = Uri.fromParts("package", getPackageName(), null);
        intent.setData(uri);
        startActivityForResult(intent, 101);
    }
    @Override
    public void onBackPressed() {

        ShowDialog();

    }

    private void ShowDialog() {

        try {
            AlertDialog mAlertDialog;
            AlertDialog.Builder builder = new AlertDialog.Builder(this, R.style.AlertDialogTheme);
            // Set a title for alert dialog
            builder.setTitle("Alert");

            builder.setCancelable(false);

            // Ask the final question
            builder.setMessage("" + "Do you want to leave payment page?");

            // Set the alert dialog yes button click listener
            builder.setPositiveButton("Yes", (dialog, which) -> {
                // Do something when user clicked the Yes button
                // Set the TextView visibility GONE
                dialog.dismiss();
                finish();
            });

            // Set the alert dialog no button click listener
            builder.setNegativeButton("No", (dialog, which) -> {
                // Do something when No button clicked
                if (dialog != null) {
                    dialog.dismiss();
                }
            });

            mAlertDialog = builder.create();
            // Display the alert dialog on interface
            mAlertDialog.show();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
