package com.example.floodwatch.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface ReportDao {

    @Insert
    suspend fun insert(report: ReportEntity)

    @Query("SELECT * FROM reports ORDER BY timestamp DESC")
    fun getAll(): Flow<List<ReportEntity>>

    @Query("SELECT * FROM reports WHERE synced = 0")
    suspend fun getUnsynced(): List<ReportEntity>

    @Query("UPDATE reports SET synced = 1 WHERE id = :id")
    suspend fun markSynced(id: Long)
}