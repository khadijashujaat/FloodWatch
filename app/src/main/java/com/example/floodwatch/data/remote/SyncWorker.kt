package com.example.floodwatch.data.remote



import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import androidx.room.Room
import com.example.floodwatch.data.AppDatabase

class SyncWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        return try {
            val database = Room.databaseBuilder(applicationContext, AppDatabase::class.java, "floodwatch.db").build()
            val dao = database.reportDao()
            val sync = FirestoreReportSync()

            val unsynced = dao.getUnsynced()
            unsynced.forEach { report ->
                sync.uploadReport(report)
                dao.markSynced(report.id)
            }
            Result.success()
        } catch (e: Exception) {
            Result.retry()
        }
    }
}