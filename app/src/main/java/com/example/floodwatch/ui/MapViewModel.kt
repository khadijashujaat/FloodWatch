package com.example.floodwatch.ui


import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.floodwatch.data.local.ReportDao

import com.example.floodwatch.data.local.ReportEntity
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn

class MapViewModel(reportDao: ReportDao) : ViewModel() {
    val syncedReports: StateFlow<List<ReportEntity>> = reportDao.getAll()
        .map { list -> list.filter { it.synced } }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())
}