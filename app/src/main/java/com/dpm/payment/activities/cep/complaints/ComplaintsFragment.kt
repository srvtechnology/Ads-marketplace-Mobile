package com.dpm.payment.activities.cep.complaints

import android.annotation.SuppressLint
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
import com.dpm.payment.adapters.ComplaintsAdapter
import com.dpm.payment.models.cep.ComplaintsModel
import kotlin.collections.mutableListOf

class ComplaintsFragment : Fragment() {
    private var rvCep: RecyclerView? = null
    private var complaintsList: MutableList<ComplaintsModel> = mutableListOf()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_complaints, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initToolbar(view)
        initView(view)
    }

    @SuppressLint("SetTextI18n")
    private fun initToolbar(view: View) {
        val tvTitle = view.findViewById<AppCompatTextView>(R.id.toolbar_tv_header)
        val ivHome = view.findViewById<ImageView>(R.id.toolbar_iv_home)

        tvTitle.text = "Complaints"
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
        complaintsList.clear()
        complaintsList!!.add(ComplaintsModel("Demand Note", R.drawable.ic_demand_note,
            information = getString(R.string.demand_note_info),
            reason =arrayListOf("Assessment parameters not correct", "Ownership details not correct", "Address not correct")

        ))
        complaintsList!!.add(ComplaintsModel("Electricity", R.drawable.ic_electricity,
            information = getString(R.string.electricity_info),
            reason =arrayListOf("No Electricity in my Ward", "No Electricity in my Area/Section", "Electricity Hazard")

        ))
        complaintsList!!.add(ComplaintsModel("Water", R.drawable.ic_water,
            information = getString(R.string.water_info),
            reason =arrayListOf("No pipe bourne water in my Ward", "No pipe bourne water in my Area/Section", "Water Hazard/Waste")
        ))
        complaintsList!!.add(
            ComplaintsModel(
                "Motorable Access Road",
                R.drawable.ic_motorable_acess_road,
                information = getString(R.string.motorable_access_road_info),
                reason =arrayListOf("No Motorable Access Road to my house", "No Motorable Access Road in my Area/Section", "Access Road Hazard")

            )
        )
        complaintsList!!.add(ComplaintsModel("Damaged/Flooding Roads", R.drawable.ic_flooded_roads,
            information = getString(R.string.flooding_roads_info),
            reason =arrayListOf("Flooding on my Road", "Flooding in my Area/Section", "Flooding Hazard")
        ))
        complaintsList!!.add(ComplaintsModel("Drainage", R.drawable.ic_drainage,
            information = getString(R.string.drainage_info),
            reason =arrayListOf("No road drainage on my road", "No road drainage in my Area/Section", "Drainage Hazard")
        ))
        complaintsList!!.add(ComplaintsModel("Waste Management", R.drawable.ic_waste_management,
            information = getString(R.string.waste_management_info),
            reason =arrayListOf("No Waste Dump in my Ward", "No Waste Dump in my Area/Section", "Waste Management Hazard")
        ))
        complaintsList!!.add(ComplaintsModel("Garbage Dumping", R.drawable.ic_garbage_dumping,
            information = getString(R.string.garbage_dumping_info),
            reason =arrayListOf("Garbage Dumping in my Road", "Garbage Dumping in my Area/Section", "Garbage Dumping/Littering Hazard")
        ))
        complaintsList!!.add(ComplaintsModel("Market", R.drawable.ic_market,
            information = getString(R.string.market_info),
            reason =arrayListOf("No Market in my Ward", "No Market in my Area/Section")
        ))
        complaintsList!!.add(ComplaintsModel("Sand Mining", R.drawable.ic_sand_mining,
            information = getString(R.string.sand_mining_info),
            reason =arrayListOf("Sand mining activities", "Sand mining hazards")
        ))
        complaintsList!!.add(ComplaintsModel("Logging", R.drawable.ic_logging,
            information = getString(R.string.logging_info),
            reason =arrayListOf("Logging activities", "Logging Hazards/deforestation")))
        setAdapter()
    }

    private fun setAdapter() {
        val adapter =
            ComplaintsAdapter(requireActivity(), complaintsList) { view: View?, position: Int ->

                (requireActivity() as ActivityCep).startFragment(DoComplainFragment(complaintsList[position]))

               /* when (position) {
                    0 -> (requireActivity() as ActivityCep).startFragment(DemandNoteFragment.newInstance())
                    1 -> (requireActivity() as ActivityCep).startFragment(ElectricityFragment.newInstance())
                    2 -> (requireActivity() as ActivityCep).startFragment(WaterFragment.newInstance())
                    3 -> (requireActivity() as ActivityCep).startFragment(
                        MotorableAccessRoadFragment.newInstance()
                    )

                    4 -> (requireActivity() as ActivityCep).startFragment(FloodingRoadFragment.newInstance())
                    5 -> (requireActivity() as ActivityCep).startFragment(DrainageFragment.newInstance())
                    6 -> (requireActivity() as ActivityCep).startFragment(WasteManagementFragment.newInstance())
                    7 -> (requireActivity() as ActivityCep).startFragment(GarbageDumpingFragment.newInstance())
                    8 -> (requireActivity() as ActivityCep).startFragment(MarketFragment.newInstance())
                    9 -> (requireActivity() as ActivityCep).startFragment(SandMiningFragment.newInstance())
                    10 -> (requireActivity() as ActivityCep).startFragment(LoggingFragment.newInstance())
                }*/
            }
        val layoutManager = LinearLayoutManager(requireActivity())
        rvCep!!.layoutManager = layoutManager
        rvCep!!.adapter = adapter
    }

    companion object {
        @JvmStatic
        fun newInstance(): ComplaintsFragment {
            return ComplaintsFragment()
        }
    }
}
