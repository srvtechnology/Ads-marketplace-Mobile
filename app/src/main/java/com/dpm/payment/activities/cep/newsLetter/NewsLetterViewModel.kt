package com.dpm.payment.activities.cep.newsLetter

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dpm.payment.activities.cep.newsLetter.model.NewsLetterResponse
import com.dpm.payment.retrofit.Utills.ApiClient
import com.dpm.payment.retrofit.interfaces.ApiInterface
import com.dpm.payment.utils.RestApiUrl.GET_NEWS_LETTER
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class NewsLetterViewModel : ViewModel() {

    private val _response = MutableStateFlow(NewsLetterResponse())
    val response = _response.asStateFlow()


    init {
        getNewsList()
    }

    private fun getNewsList() {
        viewModelScope.launch(Dispatchers.IO) {
            //   }
            val apiInterface = ApiClient.getClient().create(ApiInterface::class.java)
            val response = apiInterface[GET_NEWS_LETTER, GET_NEWS_LETTER].execute()
            if (response.isSuccessful ) {
                val res = Gson().fromJson(response.body(), NewsLetterResponse::class.java)
                _response.value=res
            }
        }
    }

}