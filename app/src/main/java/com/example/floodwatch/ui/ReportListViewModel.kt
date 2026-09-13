package com.example.floodwatch.ui


import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.floodwatch.data.local.ReportDao
import com.example.floodwatch.data.local.ReportEntity
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

class ReportListViewModel(
    reportDao: ReportDao
) : ViewModel() {

    val reports: StateFlow<List<ReportEntity>> = reportDao.getAll()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )
}