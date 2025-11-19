package com.dpm.payment.utils.imagePicker

import android.content.ContentResolver
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException

class ImageCompressor(private val context: Context) {

    /**
     * Compresses an image from the given URI and returns the path to the compressed image file.
     * @param imageUri URI of the image to be compressed.
     * @param quality Compression quality (0-100).
     * @param outputFile File where the compressed image will be saved.
     * @return The path to the compressed image file.
     * @throws IOException If an error occurs during compression.
     */
    @Throws(IOException::class)
    fun compressImage(imagePath: String, quality: Int, outputFile: File): String {
        val inputFile = File(imagePath)
        if (!inputFile.exists()) {
            throw IOException("Image file does not exist at path: $imagePath")
        }

        val inputStream = FileInputStream(inputFile)

        val bitmap = BitmapFactory.decodeStream(inputStream)
        inputStream.close()

        val outputStream = FileOutputStream(outputFile)
        val success = bitmap.compress(Bitmap.CompressFormat.JPEG, quality, outputStream)
        outputStream.close()

        if (!success) {
            throw IOException("Failed to compress image.")
        }

        return outputFile.absolutePath
    }
}
