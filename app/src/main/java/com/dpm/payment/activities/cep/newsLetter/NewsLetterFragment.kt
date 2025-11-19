package com.dpm.payment.activities.cep.newsLetter

import android.annotation.SuppressLint
import android.app.ProgressDialog
import android.content.Context
import android.os.Bundle
import android.os.Parcelable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.dpm.payment.R
import com.dpm.payment.activities.cep.ActivityCep
import com.dpm.payment.activities.cep.MyProfileFragment
import com.dpm.payment.activities.cep.NotificationFragment
import com.dpm.payment.activities.cep.information_tips.InformationTipsAdapter
import com.dpm.payment.activities.cep.newsLetter.model.NewsDataItem
import com.dpm.payment.activities.cep.newsLetter.model.NewsLetterResponse
import com.dpm.payment.adapters.NewsLetterAdapter
import com.dpm.payment.databinding.FragmentNewsLetterBinding
import com.dpm.payment.retrofit.Utills.ApiRequest
import com.dpm.payment.retrofit.Utills.ToastUtils
import com.dpm.payment.retrofit.interfaces.OnCallBackListner
import com.dpm.payment.utils.RestApiUrl.GET_NEWS_LETTER
import com.dpm.payment.utils.RestApiUrl.GET_TIP
import com.dpm.payment.utils.circularProgressIndicator
import com.google.gson.Gson
import com.squareup.picasso.Picasso
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import org.json.JSONObject

class NewsLetterFragment : Fragment() {


    lateinit var viewModel: NewsLetterViewModel


    private var _binding: FragmentNewsLetterBinding? = null
    private val binding get() = _binding!!


    val dialog by lazy { ProgressDialog(requireContext()) }

    val adapter by lazy { com.dpm.payment.activities.cep.newsLetter.NewsLetterAdapter() }

    var scrollState : Parcelable? =null


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View {
        _binding = FragmentNewsLetterBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = ViewModelProvider(this)[NewsLetterViewModel::class.java]
        initToolbar(view)
        savedInstanceState?.let {
            scrollState = savedInstanceState.getParcelable("scroll_state")
        }

        binding.rvNewsLetter.adapter = adapter

        binding.rvNewsLetter.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
               // viewModel._scrollingState.value=newState
            }
        })

        adapter.setOnItemClickListener { newsDetails ->
            (requireActivity() as ActivityCep).startFragment(
                NewsDetailsFragment.newInstance(
                    newsDetails.toString()
                )
            )

        }

        lifecycleScope.launch {
           launch {  viewModel.response.collect {
               if (it.data == null) {
                   dialog.show()
               } else {

                   //  ToastUtils.showShort(requireActivity(), it.message)
                   if (it.data.isNotEmpty()) {
                       setHighlightedNews(it.data[0]!!)
                   }


                   
                   adapter.submitList(it.data.subList(1, it.data.size))
                   dialog.dismiss()
               }
           } }

        }

        scrollState?.let {
            binding.rvNewsLetter.layoutManager?.onRestoreInstanceState(it)
        }


        /*calling the api*/
        //    apiRequest.callGetRequest(GET_NEWS_LETTER, GET_NEWS_LETTER)
    }

    @SuppressLint("SetTextI18n")
    private fun initToolbar(view: View) {
        // view.findViewById<ImageView>(R.id.ivProfile).isVisible=false
        val tvTitle = view.findViewById<AppCompatTextView>(R.id.toolbar_tv_header)
        val ivHome = view.findViewById<ImageView>(R.id.toolbar_iv_home)
        tvTitle.text = "Newsletter"
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

    fun setHighlightedNews(dataItem: NewsDataItem) {
        binding.apply {
            newsHeadLine.text = dataItem.headline
            Picasso.get().load(dataItem.headlineImg())
                .placeholder(requireContext().circularProgressIndicator())
                .error(R.drawable.image_loading_failed).into(ivVideo)
            tvDate.text = dataItem.getCreatedDate()
            txtDescription.text = dataItem.headline_description
            tvTimeAgo.text = dataItem.timeAgo()
            dataItem.editor?.let {
                tvEditor.text = it
            }
            ivVideo.setOnClickListener {
                (requireActivity() as ActivityCep).startFragment(
                    NewsDetailsFragment.newInstance(
                        dataItem.news_detail.toString()
                    )
                )

            }
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putParcelable("scroll_state",binding.rvNewsLetter.layoutManager?.onSaveInstanceState())
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}

