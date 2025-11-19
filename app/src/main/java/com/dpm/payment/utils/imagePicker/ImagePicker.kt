package com.dpm.payment.utils.imagePicker

import android.app.Activity
import android.app.Activity.RESULT_OK
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Date

class ImagePicker(private val activity: Activity) {

    private lateinit var currentPhotoPath: String
    private var providedCode: Int? = null
    private var listener: FilePickerListener? = null

    @Throws(IOException::class)
    private fun createImageFile(): File {
        // Create an image file name
        val timeStamp: String = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val storageDir: File = activity.getExternalFilesDir(Environment.DIRECTORY_PICTURES)!!
        return File.createTempFile(
            "JPEG_${timeStamp}_", /* prefix */
            ".jpg", /* suffix */
            storageDir /* directory */
        ).apply {
            // Save a file: path for use with ACTION_VIEW intents
            currentPhotoPath = absolutePath
        }
    }

    fun dispatchTakePictureIntent(code: Int, listener: FilePickerListener) {
        providedCode = code
        this.listener = listener
        Intent(MediaStore.ACTION_IMAGE_CAPTURE).also { takePictureIntent ->
            // Ensure that there's a camera activity to handle the intent
            takePictureIntent.resolveActivity(activity.packageManager)?.also {
                // Create the File where the photo should go
                val photoFile: File? = try {
                    createImageFile()
                } catch (ex: IOException) {
                    // Error occurred while creating the File
                    null
                }
                // Continue only if the File was successfully created
                photoFile?.also {
                    val photoURI: Uri = FileProvider.getUriForFile(
                        activity, "${activity.packageName}.fileprovider", it
                    )
                    takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
                    activity.startActivityForResult(takePictureIntent, code)
                }
            }
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (providedCode == requestCode && resultCode == RESULT_OK) {
            try {
                val outputFile = File(activity.cacheDir, "${System.currentTimeMillis()}.jpg")
                val compressedImagePath = ImageCompressor(activity).compressImage(
                    currentPhotoPath, 80, outputFile
                )
                listener?.getFilePath(compressedImagePath, requestCode)

            } catch (e: IOException) {
                e.printStackTrace()
            }

        }
    }


}