package com.example.floodwatch.data.remote



import com.example.floodwatch.data.local.ReportEntity
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await

data class RemoteReport(
    val type: String = "",
    val waterLevelSeverity: String? = null,
    val notes: String = "",
    val latitude: Double = 0.0,
    val longitude: Double = 0.0,
    val timestamp: Long = 0
)

class FirestoreReportSync(
    private val db: FirebaseFirestore = FirebaseFirestore.getInstance()
) {
    suspend fun uploadReport(report: ReportEntity) {
        val remote = RemoteReport(
            type = report.type,
            waterLevelSeverity = report.waterLevelSeverity,
            notes = report.notes,
            latitude = report.latitude,
            longitude = report.longitude,
            timestamp = report.timestamp
        )
        db.collection("reports").add(remote).await()
    }
}