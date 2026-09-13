package com.example.floodwatch.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "reports")
data class ReportEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val type: String,              // "Water level reading" / "Rainfall observation" / "Drainage blockage" / "Other hazard"
    val waterLevelSeverity: String?, // "Below normal" / "Ankle to knee deep" / etc.
    val notes: String,
    val latitude: Double,
    val longitude: Double,
    val timestamp: Long,
    val synced: Boolean = false
)