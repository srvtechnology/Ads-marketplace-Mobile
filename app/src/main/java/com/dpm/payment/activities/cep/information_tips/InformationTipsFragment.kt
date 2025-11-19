package com.dpm.payment.activities.cep.information_tips

import android.annotation.SuppressLint
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import com.dpm.payment.R
import com.dpm.payment.activities.cep.ActivityCep
import com.dpm.payment.activities.cep.MyProfileFragment
import com.dpm.payment.activities.cep.NotificationFragment
import com.dpm.payment.databinding.FragmentInformationTipsBinding
import com.dpm.payment.retrofit.Utills.ApiRequest
import com.dpm.payment.retrofit.Utills.ToastUtils
import com.dpm.payment.retrofit.interfaces.OnCallBackListner
import com.dpm.payment.utils.RestApiUrl.BASE_URL
import com.dpm.payment.utils.RestApiUrl.GET_TIP
import org.json.JSONObject

class InformationTipsFragment : Fragment(), OnCallBackListner {

    private var _binding: FragmentInformationTipsBinding? = null
    private val binding get() = _binding!!

    val apiRequest by lazy { ApiRequest(requireContext(),this) }
    val adapter by lazy { InformationTipsAdapter() }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentInformationTipsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initToolbar(view)
        binding.rvFormsResources.adapter = adapter

        /*calling the api*/
        apiRequest.callGetRequest(GET_TIP,GET_TIP)

    }

    private fun initToolbar(view: View) {
        val tvTitle = view.findViewById<AppCompatTextView>(R.id.toolbar_tv_header)
        val ivHome = view.findViewById<ImageView>(R.id.toolbar_iv_home)
        tvTitle.text = "Information & Tips"
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

    @SuppressLint("SuspiciousIndentation")
    override fun OnCallBackSuccess(tag: String?, response: String) {

        if (tag==GET_TIP){
        val jsonObject = JSONObject(response)
            if (jsonObject.getString("status").equals("success")){
                val tip = mutableListOf<String>()
                for (i in 0 until jsonObject.getJSONArray("data").length()){
                    tip.add(jsonObject.getJSONArray("data").getJSONObject(i).getString("tip"))
                }
                adapter.submitList(tip)


            }
            ToastUtils.showShort(requireActivity(),jsonObject.getString("message"))


        }

    }

    override fun OnCallBackError(tag: String?, error: String?, i: Int) {
        ToastUtils.showShort(requireActivity(),error)
    }

}