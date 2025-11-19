package com.dpm.payment.activities.cep.formsResources

import android.annotation.SuppressLint
import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.dpm.payment.R
import com.dpm.payment.activities.cep.ActivityCep
import com.dpm.payment.activities.cep.MyProfileFragment
import com.dpm.payment.activities.cep.NotificationFragment
import com.dpm.payment.adapters.FormResourceAdapter
import com.dpm.payment.databinding.FragmentFormsResourcesBinding
import com.dpm.payment.models.cep.formResources.FormResourceResponse
import com.dpm.payment.retrofit.Utills.ApiRequest
import com.dpm.payment.retrofit.Utills.ToastUtils
import com.dpm.payment.retrofit.interfaces.OnCallBackListner
import com.dpm.payment.utils.RestApiUrl.GET_FORM_RESOURCES
import com.google.gson.Gson

class FormsResourcesFragment : Fragment(), OnCallBackListner {
    private var rvFormsResources: RecyclerView? = null
    private var mContext: Context? = null
    private var mformsList: ArrayList<String>? = null

    lateinit var binding: FragmentFormsResourcesBinding

    val apiRequest by lazy { ApiRequest(requireContext(), this) }
    val adapter by lazy { FormResourceAdapter() }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        mContext = context
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = FragmentFormsResourcesBinding.inflate(layoutInflater)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initView(view)
        initToolbar(view)
    }

    @SuppressLint("SetTextI18n")
    private fun initToolbar(view: View) {
        val tvTitle = view.findViewById<AppCompatTextView>(R.id.toolbar_tv_header)
        val ivHome = view.findViewById<ImageView>(R.id.toolbar_iv_home)
        tvTitle.text = "Forms/Resources"
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
    }

    private fun initView(view: View) {
        rvFormsResources = view.findViewById(R.id.rvFormsResources)
        apiRequest.callGetRequest(GET_FORM_RESOURCES, "get_form_resources")
        setAdapter()
    }



    private fun setAdapter() {
        val layoutManager = GridLayoutManager(mContext, 2)
        rvFormsResources!!.layoutManager = layoutManager
        rvFormsResources!!.adapter = adapter

        adapter.setOnItemClickListener { dataItem ->
        if (!dataItem.formImage.isNullOrEmpty()){
            downloadFile(dataItem.formImage)
        }
        }
    }

    companion object {
        @JvmStatic
        fun newInstance(): FormsResourcesFragment {
            return FormsResourcesFragment()
        }
    }

   fun downloadFile(url: String) {
        val fileName =  url.substring(url.lastIndexOf('/') + 1)
        val downloadManager = requireContext().getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
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

    override fun OnCallBackSuccess(tag: String, response: String?) {
        when (tag) {
            "get_form_resources" -> {
                Log.d("FormsResourcesFragment", "OnCallBackSuccess: $response")
                val resModel = Gson().fromJson(response!!, FormResourceResponse::class.java)
                adapter.submitList(resModel.data)
            }
        }


    }

    override fun OnCallBackError(tag: String?, error: String?, i: Int) {
        ToastUtils.showShort(requireActivity(), error)
    }
}
