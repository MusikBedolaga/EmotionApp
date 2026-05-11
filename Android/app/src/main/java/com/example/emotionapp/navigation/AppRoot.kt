package com.example.emotionapp.navigation

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.runtime.getValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import com.example.emotionapp.App

@Composable
fun AppRoot(navController: NavHostController) {
    val app = LocalContext.current.applicationContext as App
    val factory = app.appComponent.viewModelFactory()

    val startVm: AppStartViewModel = viewModel(factory = factory)

    val state by startVm.state.collectAsStateWithLifecycle()

    when (val s = state) {
        AppStartState.Loading -> {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text("Loading...")
            }
        }
        is AppStartState.Ready -> {
            AppNavHost(
                navController = navController,
                startDestination = s.startDestination
            )
        }
    }
}
