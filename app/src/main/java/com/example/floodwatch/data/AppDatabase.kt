package com.example.floodwatch.data

import androidx.room.Database
import androidx.room.RoomDatabase
import com.example.floodwatch.data.local.ReportDao
import com.example.floodwatch.data.local.ReportEntity

@Database(entities=[ReportEntity::class],version=1, exportSchema = false)
abstract class  AppDatabase: RoomDatabase(){
    abstract fun reportDao(): ReportDao
}