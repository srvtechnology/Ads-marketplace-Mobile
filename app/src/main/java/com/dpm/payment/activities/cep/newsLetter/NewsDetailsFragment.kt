package com.dpm.payment.activities.cep.newsLetter

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.ProgressBar
import androidx.core.view.isVisible
import com.dpm.payment.databinding.FragmentNewsDetailsBinding

class NewsDetailsFragment : Fragment() {

    private var _binding: FragmentNewsDetailsBinding? = null
    private val binding get() = _binding!!

    private val story by lazy {
        arguments?.getString(ARG_STORY) ?: ""
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentNewsDetailsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.apply {

            binding.toolbar.ivProfile.isVisible=false
            binding.toolbar.ivNotification.isVisible=false
            binding.toolbar.toolbarIvHome.setOnClickListener {
                parentFragmentManager.popBackStack()
            }


            webView.settings.javaScriptEnabled = true

            // Set WebView client
            webView.webViewClient = object : WebViewClient() {
                override fun onPageStarted(view: WebView, url: String, favicon: android.graphics.Bitmap?) {
                    super.onPageStarted(view, url, favicon)
                    progressBar.visibility = ProgressBar.VISIBLE
                }

                override fun onPageFinished(view: WebView, url: String) {
                    super.onPageFinished(view, url)
                    progressBar.visibility = ProgressBar.GONE
                }
            }

            // Set WebChromeClient to show progress in the ProgressBar
            webView.webChromeClient = object : WebChromeClient() {
                override fun onProgressChanged(view: WebView, newProgress: Int) {
                    super.onProgressChanged(view, newProgress)
                    progressBar.progress = newProgress
                    if (newProgress == 100) {
                        progressBar.visibility = ProgressBar.GONE
                    } else {
                        progressBar.visibility = ProgressBar.VISIBLE
                    }
                }
            }
            webView.loadUrl(story)
           // webView.loadData(story, "text/html", "UTF-8")

        }
    }


    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }


    companion object {
        private const val ARG_STORY = "story"

        fun newInstance(story: String): NewsDetailsFragment {
            return NewsDetailsFragment().apply {
                arguments = Bundle().apply {
                    putString(ARG_STORY, story)
                }
            }
        }


    }
}