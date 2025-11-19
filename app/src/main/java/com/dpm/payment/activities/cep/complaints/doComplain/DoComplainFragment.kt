package com.dpm.payment.activities.cep.complaints.doComplain

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity.RESULT_OK
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.location.Location
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.util.Base64
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.FileProvider
import androidx.fragment.app.Fragment
import com.dpm.payment.activities.cep.ActivityCep
import com.dpm.payment.activities.cep.MyProfileFragment
import com.dpm.payment.activities.cep.NotificationFragment
import com.dpm.payment.databinding.FragmentDoComplainBinding
import com.dpm.payment.models.cep.ComplaintsModel
import com.dpm.payment.retrofit.Utills.ApiRequest
import com.dpm.payment.retrofit.Utills.PART
import com.dpm.payment.retrofit.Utills.ToastUtils
import com.dpm.payment.retrofit.interfaces.OnCallBackListner
import com.dpm.payment.utils.PrefUtil
import com.dpm.payment.utils.RestApiUrl.ADD_COMPLAIN
import com.dpm.payment.utils.RestApiUrl.ADD_EMERGENCY
import com.github.dhaval2404.imagepicker.ImagePicker
import com.github.dhaval2404.imagepicker.ImagePicker.Companion.with
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import okhttp3.MultipartBody
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Date

class DoComplainFragment(private val model: ComplaintsModel) : Fragment(), OnCallBackListner {

    private var _binding: FragmentDoComplainBinding? = null
    private val binding get() = _binding!!

    private val reasonAdapter by lazy { ReasonAdapter() }

    val filePaths = mutableListOf<String>("", "")

    val apiRequest by lazy { ApiRequest(requireContext(), this) }

    private lateinit var fusedLocationClient: FusedLocationProviderClient

    lateinit var currentPhotoPath: String


    @RequiresApi(Build.VERSION_CODES.N)
    private val locationPermissionRequest = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        when {
            permissions.getOrDefault(Manifest.permission.ACCESS_FINE_LOCATION, false) -> {
                // Precise location access granted.
                getLastLocation()
            }

            permissions.getOrDefault(Manifest.permission.ACCESS_COARSE_LOCATION, false) -> {
                // Only approximate location access granted.
                getLastLocation()
            }

            else -> {
                // No location access granted.
            }
        }
    }


    companion object {
        private const val LOCATION_PERMISSION_REQUEST_CODE = 1
    }


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View {
        _binding = FragmentDoComplainBinding.inflate(inflater, container, false)
        return binding.root
    }

    @RequiresApi(Build.VERSION_CODES.N)
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.apply {
            toolBarLayout.toolbarTvHeader.text = model.complaintsTitle
            tvInfo.text = model.information
            toolBarLayout.toolbarIvHome.setOnClickListener { parentFragmentManager.popBackStack() }
            toolBarLayout.ivProfile.setOnClickListener {
                (requireActivity() as ActivityCep).startFragment(MyProfileFragment.newInstance())

            }
            toolBarLayout.ivNotification.setOnClickListener {
                (requireActivity() as ActivityCep).startFragment(NotificationFragment.newInstance())

            }
            ivCepImage1.setOnClickListener { dispatchTakePictureIntent(0) }
            ivCepImage2.setOnClickListener { dispatchTakePictureIntent(1) }
            btnSubmit.setOnClickListener {
                if (validateBeforeSubmitting()) submitRequest()
            }

            /* setup data */
            rvDemandNote.adapter = reasonAdapter
            reasonAdapter.submitList(model.reason)

            /* check either to show property id or tag location */

            if (model.complaintsTitle == "Demand Note") {
                tvPropertyIdLabel.text = "Property Id"
                edtPropertyId.isEnabled = true

            } else {
                tvPropertyIdLabel.text = "Tag Location"
                edtPropertyId.isEnabled = false

                tvPropertyIdLabel.setOnClickListener {
                    getLastLocation()

                }

                // Request location permissions
                locationPermissionRequest.launch(
                    arrayOf(
                        Manifest.permission.ACCESS_FINE_LOCATION,
                        Manifest.permission.ACCESS_COARSE_LOCATION
                    )
                )

                fusedLocationClient =
                    LocationServices.getFusedLocationProviderClient(requireActivity())
                // Check for location permissions
                if (ActivityCompat.checkSelfPermission(
                        requireContext(), Manifest.permission.ACCESS_FINE_LOCATION
                    ) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(
                        requireContext(), Manifest.permission.ACCESS_COARSE_LOCATION
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    // Request location permissions if not already granted
                    ActivityCompat.requestPermissions(
                        requireActivity(), arrayOf(
                            Manifest.permission.ACCESS_FINE_LOCATION,
                            Manifest.permission.ACCESS_COARSE_LOCATION
                        ), LOCATION_PERMISSION_REQUEST_CODE
                    )
                    return
                }

            }

        }
    }

    @SuppressLint("MissingPermission")
    private fun getLastLocation() {
        fusedLocationClient.lastLocation.addOnSuccessListener { location: Location? ->
                location?.let {
                    val latitude = it.latitude
                    val longitude = it.longitude

                    binding.edtPropertyId.setText("$latitude , $longitude")
                    // Use the latitude and longitude as needed
                }
            }
    }

    private fun openCamera(code: Int) {
        with(this).crop() //Crop image(Optional), Check Customization for more option
            .compress(1024) //Final image size will be less than 1 MB(Optional)
            .maxResultSize(
                1080, 1080
            ) //Final image resolution will be less than 1080 x 1080(Optional)
            .cameraOnly().start(code)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)/* if (resultCode == RESULT_OK) {
             if (ImagePicker.Companion.getFile(data)?.isFile == true) {
                 filePaths[requestCode] = ImagePicker.getFile(data)?.path!!

                 if (filePaths[0].isNotBlank()) {
                     binding.ivCepImage1.setImageURI(Uri.parse(filePaths[0]))
                 }
                 if (filePaths[1].isNotBlank()) {
                     binding.ivCepImage2.setImageURI(Uri.parse(filePaths[1]))
                 }
             }

         }*/
        if (resultCode == RESULT_OK) {
            filePaths[requestCode] = currentPhotoPath


            if (filePaths[0].isNotBlank()) {
                binding.ivCepImage1.setImageURI(Uri.parse(filePaths[0]))
            }
            if (filePaths[1].isNotBlank()) {
                binding.ivCepImage2.setImageURI(Uri.parse(filePaths[1]))
            }

           /* if (filePaths[0].isNotBlank()) {
                binding.ivCepImage1.setImageBitmap(base64ToBitmap(filePaths[0]))
            }
            if (filePaths[1].isNotBlank()) {
                binding.ivCepImage2.setImageBitmap(base64ToBitmap(filePaths[0]))
            }*/
        }


    }

    private fun validateBeforeSubmitting(): Boolean {
        if (reasonAdapter.selectedPos == -1) {
            ToastUtils.showShort(requireActivity(), "Please choose reason")
            return false
        }/* if (filePaths[0].isEmpty() && filePaths[1].isEmpty()) {
             ToastUtils.showShort(requireActivity(), "Please upload at least one Image")
             return false
         }*/



        return true
    }

    private fun submitRequest() {
        val parts: MutableList<PART> = mutableListOf()
        for (i in 0 until filePaths.size) {
            if (filePaths[i].isNotBlank()) {
                parts.add(PART("complain_image[$i]", File(filePaths[i])))
            }
        }

        val map = hashMapOf(
            "information" to model.information,
            "reason" to model.reason[reasonAdapter.selectedPos],
            "additional_information" to binding.edtAdditionalInfo.text.toString(),
            "tag" to binding.edtPropertyId.text.toString(),
            "user_id" to PrefUtil.getUserId(requireContext()),
            "type" to model.complaintsTitle,
        )

        apiRequest.callMultiFileUpload(
           if (model.isEmergencyService) ADD_EMERGENCY else ADD_COMPLAIN, map, parts, "",  if (model.isEmergencyService) ADD_EMERGENCY else ADD_COMPLAIN
        )


    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    override fun OnCallBackSuccess(tag: String?, response: String) {
        if (tag == ADD_COMPLAIN || tag == ADD_EMERGENCY) {

            val obj = JSONObject(response)
            ToastUtils.showShort(requireActivity(), obj.getString("message"))

            if (obj.getString("status") == "success") parentFragmentManager.popBackStack()


        }
    }

    override fun OnCallBackError(tag: String?, error: String?, i: Int) {
        ToastUtils.showShort(requireActivity(), error)

    }


    @Throws(IOException::class)
    private fun createImageFile(): File {
        // Create an image file name
        val timeStamp: String = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val storageDir: File =
            requireActivity().getExternalFilesDir(Environment.DIRECTORY_PICTURES)!!
        return File.createTempFile(
            "JPEG_${timeStamp}_", /* prefix */
            ".jpg", /* suffix */
            storageDir /* directory */
        ).apply {
            // Save a file: path for use with ACTION_VIEW intents
            currentPhotoPath = absolutePath
        }
    }

    private fun dispatchTakePictureIntent(code: Int) {
        Intent(MediaStore.ACTION_IMAGE_CAPTURE).also { takePictureIntent ->
            // Ensure that there's a camera activity to handle the intent
            takePictureIntent.resolveActivity(requireActivity().packageManager)?.also {
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
                        requireContext(), "${requireActivity().packageName}.fileprovider", it
                    )
                    takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
                    startActivityForResult(takePictureIntent, code)
                }
            }
        }
    }


}