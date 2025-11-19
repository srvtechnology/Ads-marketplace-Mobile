package com.dpm.payment.utils

import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.os.Environment

class DownloadManager {

    companion object{
        fun downloadFile(context: Context,url: String) {
            val fileName =  url.substring(url.lastIndexOf('/') + 1)
            val downloadManager = context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
            val request = DownloadManager.Request(Uri.parse(url)).apply {
                setTitle("Downloading $fileName")
                setDescription("Downloading file...")
                setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, fileName)
                setAllowedOverMetered(true)
                setAllowedOverRoaming(true)
            }

            downloadManager.enqueue(request)
        }
    }
}