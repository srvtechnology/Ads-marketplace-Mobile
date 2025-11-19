package com.dpm.payment.activities.cep.garbageCollection

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.app.Activity.RESULT_OK
import android.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.RequiresApi
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.app.ActivityCompat
import androidx.core.content.FileProvider
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import com.dpm.payment.R
import com.dpm.payment.activities.cep.ActivityCep
import com.dpm.payment.activities.cep.MyProfileFragment
import com.dpm.payment.activities.cep.NotificationFragment
import com.dpm.payment.activities.cep.garbageCollection.model.CalendarDay
import com.dpm.payment.activities.cep.garbageCollection.model.getDateResponse.DateItem
import com.dpm.payment.activities.cep.garbageCollection.model.getDateResponse.GetDateResponse
import com.dpm.payment.activities.cep.garbageCollection.model.getDateResponse.SlotItem
import com.dpm.payment.databinding.FragmentGarbageCollectionBinding
import com.dpm.payment.retrofit.Utills.ApiRequest
import com.dpm.payment.retrofit.Utills.PART
import com.dpm.payment.retrofit.Utills.ToastUtils
import com.dpm.payment.retrofit.interfaces.OnCallBackListner
import com.dpm.payment.utils.PrefUtil
import com.dpm.payment.utils.RestApiUrl.ADD_COMPLAIN
import com.dpm.payment.utils.RestApiUrl.ADD_GARBAGE_COLLECTION
import com.dpm.payment.utils.RestApiUrl.GET_AVAILABLE_DATE
import com.dpm.payment.utils.pickTime
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import org.json.JSONObject
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale


class GarbageCollectionFragment : Fragment(), OnCallBackListner {

    val apiRequest by lazy { ApiRequest(requireContext(), this) }

    private var _binding: FragmentGarbageCollectionBinding? = null
    private val binding get() = _binding!!

    private lateinit var calendarAdapter: CalendarAdapter
    private val days = mutableListOf<CalendarDay>()

    private val calendar = Calendar.getInstance()

    private var listOfAvailableDays = listOf<DateItem>()

    val filePaths = mutableListOf<String>("", "")
    lateinit var currentPhotoPath: String

    var selectedCalendarDay: CalendarDay? = null
    var selectedDateId: Int? = null
    var selectedSlotId: Int? = null


    private lateinit var fusedLocationClient: FusedLocationProviderClient

    @RequiresApi(Build.VERSION_CODES.N)
    private val locationPermissionRequest = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        when {
            permissions.getOrDefault(Manifest.permission.ACCESS_FINE_LOCATION, false) -> {
                // Precise location access granted.
               // getLastLocation()
            }

            permissions.getOrDefault(Manifest.permission.ACCESS_COARSE_LOCATION, false) -> {
                // Only approximate location access granted.
               // getLastLocation()
            }

            else -> {
                // No location access granted.
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.N)
    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View {
        _binding = FragmentGarbageCollectionBinding.inflate(inflater, container, false)
        initLocationService()
        return binding.root
    }

    @RequiresApi(Build.VERSION_CODES.N)
    private fun initLocationService() {
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
                ), 100
            )
            return
        }
    }

    @SuppressLint("MissingPermission")
    private fun getLastLocation() {
        fusedLocationClient.lastLocation.addOnSuccessListener { location: Location? ->
            location?.let {
                val latitude = it.latitude
                val longitude = it.longitude

                binding.txtLocation.setText("$latitude , $longitude")
                // Use the latitude and longitude as needed
            }
        }
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initView(view)
        initToolbar(view)
    }

    private fun initView(view: View) {
        getAvailableDate()
        binding.apply {
            /*   calendarView.minDate = cal.timeInMillis
               calendarView.maxDate = cal.timeInMillis*/
            calendarRecyclerView.layoutManager = GridLayoutManager(requireContext(), 7)
            calendarAdapter = CalendarAdapter(days)
            calendarRecyclerView.adapter = calendarAdapter
            calendarAdapter.onDateClickListener { calender: CalendarDay ->
                if (calender.isAvailable && calender.slot.isNullOrEmpty()) {
                    ToastUtils.showShort(
                        requireActivity(), "No slot found"
                    )
                } else {
                    selectedCalendarDay = calender
                    // slot found
                    showRadioButtonDialog(requireContext(), calender.slot!!)
                }
            }

            nextMonthButton.setOnClickListener {
                calendar.add(Calendar.MONTH, 1)
                updateCalendar()
            }
            previousMonthButton.setOnClickListener {
                calendar.add(Calendar.MONTH, -1)
                updateCalendar()
            }

            ivCepImage1.setOnClickListener { dispatchTakePictureIntent(0) }
            ivCepImage2.setOnClickListener { dispatchTakePictureIntent(1) }
            txtSelectedTime.setOnClickListener {
                showRadioButtonDialog(requireContext(), selectedCalendarDay?.slot ?: emptyList())
            }
            txtLocation.setOnClickListener {
                getLastLocation()
            }
        }

    }

    private fun updateCalendar() {
        selectedSlotId = null
        selectedDateId = null
        selectedCalendarDay = null
        binding.txtSelectedTime.text = ""
        days.clear()
        calendarAdapter.selectedDay = -1
        val month = calendar.get(Calendar.MONTH)
        val year = calendar.get(Calendar.YEAR)
        binding.previousMonthButton.isVisible =
            month > Calendar.getInstance().get(Calendar.MONTH) || year > Calendar.getInstance()
                .get(Calendar.YEAR)
        binding.monthYearText.text =
            SimpleDateFormat("MMMM yyyy", Locale.getDefault()).format(calendar.time)

        calendar.set(Calendar.DAY_OF_MONTH, 1)

        val firstDayOfWeek = calendar.get(Calendar.DAY_OF_WEEK) - 1
        val daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH)

        for (i in 0 until firstDayOfWeek) {
            //calendar.set(Calendar.DATE,i)
            days.add(CalendarDay(0, false, calendar)) // Empty days
        }

        for (i in 1..daysInMonth) {
            // here we are adding the date to the calender
            calendar.set(Calendar.DATE, i)
            val availableDate = listOfAvailableDays.find {
                it.date == SimpleDateFormat(
                    "yyyy-MM-dd", Locale.getDefault()
                ).format(calendar.time)
            } // Example logic for available days
            days.add(CalendarDay(i, availableDate != null, calendar, slot = availableDate?.getSlot))
        }

        calendarAdapter.notifyDataSetChanged()
    }


    private fun showRadioButtonDialog(context: Context, list: List<SlotItem>) {
        val options = list.map { it.slots }.toTypedArray()
        var selectedOption = -1
        val builder = AlertDialog.Builder(context)
        builder.setTitle("Select Time")

        builder.setSingleChoiceItems(options, -1) { _, which ->
            selectedOption = which
        }

        builder.setPositiveButton("OK") { dialog, _ ->
            if (selectedOption != -1) {
                // Handle the selected option
                // Example: println("Selected: ${options[selectedOption]}")
                binding.txtSelectedTime.text = options[selectedOption]
                selectedSlotId = list[selectedOption].id
                selectedDateId = list[selectedOption].garbageDateId
                dialog.dismiss()
            } else {
                // Keep the dialog open if no option is selected
                dialog.dismiss()
                showRadioButtonDialog(context, list)
            }
        }

        builder.setNegativeButton("Cancel") { dialog, _ ->
            // Handle cancel button click
            dialog.dismiss()
        }

        val alertDialog = builder.create()

        // Prevent dialog from being dismissed by clicking outside
        alertDialog.setCancelable(false)
        alertDialog.setCanceledOnTouchOutside(false)

        alertDialog.show()
    }


    @SuppressLint("SetTextI18n")
    private fun initToolbar(view: View) {
        val tvTitle = view.findViewById<AppCompatTextView>(R.id.toolbar_tv_header)
        val ivHome = view.findViewById<ImageView>(R.id.toolbar_iv_home)
        tvTitle.setText(R.string.garbage_collection)
        ivHome.setOnClickListener { v: View? ->
            parentFragmentManager.popBackStack()
        }
        val ivProfile = view.findViewById<AppCompatImageView>(R.id.ivProfile)
        val ivNotification = view.findViewById<AppCompatImageView>(R.id.ivNotification)
        ivProfile.setOnClickListener { v: View? ->
            (requireActivity() as ActivityCep).startFragment(MyProfileFragment.newInstance())
        }
        ivNotification.setOnClickListener { v: View? ->
            (requireActivity() as ActivityCep).startFragment(NotificationFragment.newInstance())
        }
        binding.btnSubmit.setOnClickListener { if (validateBeforeSubmitting()) submitRequest() }
    }

    companion object {
        @JvmStatic
        fun newInstance(): GarbageCollectionFragment {
            return GarbageCollectionFragment()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }


    private fun getAvailableDate() {
        apiRequest.callGetRequest(GET_AVAILABLE_DATE, GET_AVAILABLE_DATE)
    }


    private fun validateBeforeSubmitting(): Boolean {
        if (selectedDateId == null) {
            ToastUtils.showShort(requireActivity(), "Please select date")
            return false
        }
        if (selectedSlotId == null) {
            ToastUtils.showShort(requireActivity(), "Please select time slot")
            return false
        }
        if (filePaths[0].isEmpty() && filePaths[1].isEmpty()) {
            ToastUtils.showShort(requireActivity(), "Please upload at least one Image")
            return false
        }



        return true
    }

    private fun submitRequest() {
        val parts: MutableList<PART> = mutableListOf()
        for (i in 0 until filePaths.size) {
            if (filePaths[i].isNotBlank()) {
                parts.add(PART("garbage_image_${i + 1}", File(filePaths[i])))
            }
        }

        val map = hashMapOf(
            "date" to listOfAvailableDays.find { it.id==selectedDateId }?.date,
            "garbage_date_id" to selectedDateId.toString(),
            "garbage_date_slot_id" to selectedSlotId.toString(),
            "slot" to binding.txtSelectedTime.text.toString(),
            "latlng" to binding.txtLocation.text.toString(),
            "user_id" to PrefUtil.getUserId(requireContext()),

            )

        apiRequest.callMultiFileUpload(
            ADD_GARBAGE_COLLECTION, map, parts, "", ADD_GARBAGE_COLLECTION
        )


    }


    override fun OnCallBackSuccess(tag: String, response: String) {
        when (tag) {
            GET_AVAILABLE_DATE -> {
                val responseType = object : TypeToken<List<DateItem>>() {}.type
                val list: List<DateItem> = Gson().fromJson(response, responseType)
                listOfAvailableDays = list


                updateCalendar()
            }
            ADD_GARBAGE_COLLECTION->{
                val obj = JSONObject(response)
                ToastUtils.showShort(requireActivity(), obj.getString("message"))
                if (obj.getString("status") == "success") parentFragmentManager.popBackStack()
            }
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

}