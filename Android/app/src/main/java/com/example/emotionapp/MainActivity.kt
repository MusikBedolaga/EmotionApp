package com.example.emotionapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.navigation.compose.rememberNavController
import com.example.emotionapp.navigation.AppRoot
import com.example.emotionapp.ui.theme.EmotionAppTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            EmotionAppTheme {
                val navController = rememberNavController()
                AppRoot(navController = navController)
            }
        }
    }
}
