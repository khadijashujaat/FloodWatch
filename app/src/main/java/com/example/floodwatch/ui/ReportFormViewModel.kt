package com.example.floodwatch.ui



import android.annotation.SuppressLint
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.floodwatch.data.local.ReportDao
import com.example.floodwatch.data.local.ReportEntity
import com.google.android.gms.location.FusedLocationProviderClient
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import android.content.Context
import androidx.work.*
import com.example.floodwatch.data.remote.SyncWorker

sealed interface SubmitState {
    data object Idle : SubmitState
    data object Saving : SubmitState
    data object Saved : SubmitState
}

class ReportFormViewModel(
    private val reportDao: ReportDao,
    private val locationClient: FusedLocationProviderClient,
    private val appContext: Context
) : ViewModel() {

    private val _submitState = MutableStateFlow<SubmitState>(SubmitState.Idle)
    val submitState: StateFlow<SubmitState> = _submitState.asStateFlow()

    @SuppressLint("MissingPermission") // permission is checked in the UI before calling this
    fun submitReport(
        type: String,
        waterLevelSeverity: String?,
        notes: String
    ) {
        viewModelScope.launch {
            _submitState.value = SubmitState.Saving

            val location = locationClient.lastLocation.await()

            val report = ReportEntity(
                type = type,
                waterLevelSeverity = waterLevelSeverity,
                notes = notes,
                latitude = location?.latitude ?: 0.0,
                longitude = location?.longitude ?: 0.0,
                timestamp = System.currentTimeMillis(),
                synced = false
            )

            reportDao.insert(report)   //local-first
            val oneTimeSync = OneTimeWorkRequestBuilder<SyncWorker>()
                .setConstraints(Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build())
                .build()
            WorkManager.getInstance(appContext).enqueue(oneTimeSync)
            _submitState.value = SubmitState.Saved
        }
    }

    fun resetState() {
        _submitState.value = SubmitState.Idle
    }
}