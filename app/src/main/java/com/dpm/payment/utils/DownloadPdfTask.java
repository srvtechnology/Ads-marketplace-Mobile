package com.dpm.payment.utils;


import android.app.DownloadManager;
import android.content.Context;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Environment;
import android.widget.Toast;

public class DownloadPdfTask extends AsyncTask<Void, Void,Long> {

    private  Context context;
    private String urlString;

    public DownloadPdfTask(Context context, String urlString) {
        this.context = context;
        this.urlString = urlString;
    }

    @Override
    protected Long doInBackground(Void... voids) {
        String title = urlString.substring(urlString.lastIndexOf('/')+1);
        DownloadManager downloadmanager = (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);
        Uri uri = Uri.parse(urlString);
        DownloadManager.Request request = new DownloadManager.Request(uri);
        request.setTitle(title);
        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
        request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, title);
        return downloadmanager.enqueue(request);
    }

    @Override
    public void onPostExecute(Long result) {
        //context.receiveDownloadId(result);
        Toast.makeText(context, "Download completed!", Toast.LENGTH_SHORT).show();
    }

}
