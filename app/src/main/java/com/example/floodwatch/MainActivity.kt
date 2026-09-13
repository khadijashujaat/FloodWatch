package com.example.floodwatch

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.room.Room
import com.example.floodwatch.data.AppDatabase
import com.example.floodwatch.ui.ReportFormRoute
import com.example.floodwatch.ui.ReportFormViewModel
import com.google.android.gms.location.LocationServices
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.Modifier
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.example.floodwatch.data.remote.SyncWorker
import com.example.floodwatch.ui.MapScreen
import com.example.floodwatch.ui.MapViewModel
import com.example.floodwatch.ui.ReportListScreen
import com.example.floodwatch.ui.ReportListViewModel


import java.util.concurrent.TimeUnit



class MainActivity : ComponentActivity() {

    // built once, here, and handed down
    private val database by lazy {
        Room.databaseBuilder(applicationContext, AppDatabase::class.java, "floodwatch.db").build()
    }
    private val locationClient by lazy {
        LocationServices.getFusedLocationProviderClient(this)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(15, TimeUnit.MINUTES)
            .setConstraints(
                Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build()
            )
            .build()

        WorkManager.getInstance(applicationContext)
            .enqueueUniquePeriodicWork("report_sync", ExistingPeriodicWorkPolicy.KEEP, syncRequest)

//map api onetime config call
        org.osmdroid.config.Configuration.getInstance().userAgentValue =  "FloodWatch/1.0 (student project, com.example.floodwatch)"
        setContent {
            val database = database // already built via `by lazy` earlier
            val formViewModel: ReportFormViewModel = viewModel(
                factory = object : ViewModelProvider.Factory {
                    @Suppress("UNCHECKED_CAST")
                    override fun <T : androidx.lifecycle.ViewModel> create(modelClass: Class<T>): T {
                        return ReportFormViewModel(database.reportDao(), locationClient,applicationContext) as T
                    }
                }
            )
            val listViewModel: ReportListViewModel = viewModel(
                factory = object : ViewModelProvider.Factory {
                    @Suppress("UNCHECKED_CAST")
                    override fun <T : androidx.lifecycle.ViewModel> create(modelClass: Class<T>): T {
                        return ReportListViewModel(database.reportDao()) as T
                    }
                }
            )

            var selectedTab by remember { mutableStateOf(0) }

            Scaffold(
                bottomBar = {
                    NavigationBar {
                        NavigationBarItem(
                            selected = selectedTab == 0,
                            onClick = { selectedTab = 0 },
                            icon = { Icon(Icons.Filled.Add, contentDescription = "Report") },
                            label = { Text("Report") }
                        )
                        NavigationBarItem(
                            selected = selectedTab == 1,
                            onClick = { selectedTab = 1 },
                            icon = { Icon(Icons.Filled.List, contentDescription = "History") },
                            label = { Text("History") }
                        )

                      NavigationBarItem(
                        selected = selectedTab == 2,
                        onClick = { selectedTab = 2 },
                        icon = { Icon(Icons.Filled.LocationOn, contentDescription = "Map") },
                        label = { Text("Map") }
                      )
                    }
                }
            ) { padding ->
                Box(Modifier.padding(padding)) {
                    when (selectedTab ){
                        0->   {
                        ReportFormRoute(viewModel = formViewModel)
                         }
                        1->   {
                        val reports by listViewModel.reports.collectAsState()
                        ReportListScreen(reports = reports)
                        }
                       /** 2 -> {
                            val mapViewModel: MapViewModel = viewModel(
                                factory = object : ViewModelProvider.Factory {
                                    @Suppress("UNCHECKED_CAST")
                                    override fun <T : androidx.lifecycle.ViewModel> create(modelClass: Class<T>): T {
                                        return MapViewModel(database.reportDao()) as T
                                    }
                                }
                            )
                            val syncedReports by mapViewModel.syncedReports.collectAsState()
                            MapScreen(reports = syncedReports)
                        }**/

                    }
                }
            }
        }
    }
}