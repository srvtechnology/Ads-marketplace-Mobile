package com.dpm.payment.activities.cep.emergencyservice

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.dpm.payment.R
import com.dpm.payment.activities.cep.ActivityCep
import com.dpm.payment.activities.cep.MyProfileFragment
import com.dpm.payment.activities.cep.NotificationFragment
import com.dpm.payment.activities.cep.complaints.doComplain.DoComplainFragment
import com.dpm.payment.adapters.EmergencyServiceAdapter
import com.dpm.payment.interfaces.OnItemClickListener
import com.dpm.payment.models.cep.ComplaintsModel

class EmergencyServicesFragment : Fragment() {
    private var rvCep: RecyclerView? = null
    private var mContext: Context? = null
    private var emergencyServiceList = mutableListOf<ComplaintsModel>()

    override fun onAttach(context: Context) {
        super.onAttach(context)
        mContext = context
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_emergency_service, container, false)
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
        tvTitle.text = "Emergency Services"
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
        rvCep = view.findViewById(R.id.rvCep)
        setData()
    }

    private fun setData() {
        emergencyServiceList.apply {
            clear()

            add(
                ComplaintsModel(
                    complaintsTitle = "Police", complaintsIcon = R.drawable.ic_police,
                    information = getString(R.string.emergency_service_info),
                    reason = arrayListOf(
                        "Fighting",
                        "Assault",
                        "Drug Abuse",
                        "Traffic Violation",
                    ), isEmergencyService = true

                )
            )


            add(
                ComplaintsModel(
                    complaintsTitle = "Fire Force", complaintsIcon = R.drawable.ic_fire_force,
                    information = getString(R.string.emergency_service_info),
                    reason = arrayListOf(
                        "Requesting Fire Force presence",
                        "House(s) on fire",
                    ), isEmergencyService = true

                )
            )

            add(
                ComplaintsModel(
                    complaintsTitle = "NEMS", complaintsIcon = R.drawable.ic_nems,
                    information = getString(R.string.emergency_service_info),
                    reason = arrayListOf(
                        "Requesting Ambulance pickup",
                    ), isEmergencyService = true

                )
            )
        }


        setAdapter()
    }

    private fun setAdapter() {
        val adapter = EmergencyServiceAdapter(
            mContext,
            emergencyServiceList
        ) { view: View?, position: Int ->
            (requireActivity() as ActivityCep).startFragment(
                DoComplainFragment(
                    emergencyServiceList[position]
                )
            )

        }
        val layoutManager = LinearLayoutManager(requireActivity())
        rvCep!!.layoutManager = layoutManager
        rvCep!!.adapter = adapter
    }

    companion object {
        @JvmStatic
        fun newInstance(): EmergencyServicesFragment {
            return EmergencyServicesFragment()
        }
    }
}
