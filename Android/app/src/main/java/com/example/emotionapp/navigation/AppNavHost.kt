@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package com.example.emotionapp.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.example.emotionapp.App
import com.example.emotionapp.presentation.Analytics.AnalyticsScreenStateful
import com.example.emotionapp.presentation.Analytics.AnalyticsViewModel
import com.example.emotionapp.presentation.AlbumDetails.AlbumDetailsScreen
import com.example.emotionapp.presentation.AlbumDetails.AlbumDetailsViewModel
import com.example.emotionapp.presentation.AppComponents.MainTabBar
import com.example.emotionapp.presentation.Auth.AuthScreenStateful
import com.example.emotionapp.presentation.Auth.AuthViewModel
import com.example.emotionapp.presentation.CreateNote.CreateNoteScreenStateful
import com.example.emotionapp.presentation.CreateNote.CreateNoteViewModel
import com.example.emotionapp.presentation.NoteDetails.NoteDetailsScreen
import com.example.emotionapp.presentation.NoteDetails.NoteDetailsViewModel
import com.example.emotionapp.presentation.Onboarding.OnboardingScreen
import com.example.emotionapp.presentation.Onboarding.OnboardingViewModel

@Composable
fun AppNavHost(
    navController: NavHostController,
    startDestination: String
) {

    val app = LocalContext.current.applicationContext as App
    val factory = app.appComponent.viewModelFactory()

    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        composable(Route.Onboarding.route) {
            val app = LocalContext.current.applicationContext as App
            val vm: OnboardingViewModel = viewModel(factory = factory)

            OnboardingScreen(
                vm = vm,
                onFinish = {
                    vm.completeOnboarding()
                    navController.navigate(Route.Auth.route) {
                        popUpTo(Route.Onboarding.route) { inclusive = true }
                        launchSingleTop = true
                    }
                }
            )
        }

        composable(Route.Auth.route) {
            val vm: AuthViewModel = viewModel(factory = factory)

            AuthScreenStateful(vm = vm) {
                navController.navigate(Route.Main.route) {
                    popUpTo(Route.Auth.route) { inclusive = true }
                    launchSingleTop = true
                }
            }
        }

        composable(Route.Main.route) {
            MainTabBar(
                factory = factory,
                onOpenAlbum = { albumId, title ->
                    navController.navigate(Route.AlbumDetails.createRoute(albumId, title))
                },
                onAnalyticsClick = {
                    navController.navigate(Route.Analytics.route)
                },
                onLogout = {
                    navController.navigate(Route.Auth.route) {
                        popUpTo(Route.Main.route) { inclusive = true }
                        launchSingleTop = true
                    }
                }
            )
        }

        composable(
            route = Route.AlbumDetails.route,
            arguments = listOf(
                navArgument(Route.AlbumDetails.idArg) { type = NavType.LongType },
                navArgument(Route.AlbumDetails.titleArg) {
                    type = NavType.StringType
                    defaultValue = ""
                }
            )
        ) { backStackEntry ->

                Route.AlbumDetails.idArg
            ) ?: return@composable
            val title = backStackEntry.arguments?.getString(
                Route.AlbumDetails.titleArg
            ).orEmpty()

            val vm: AlbumDetailsViewModel = viewModel(factory = factory)

            AlbumDetailsScreen(
                vm = vm,
                albumId = albumId,
                title = title,
                onOpenNote = { noteId -> navController.navigate(Route.NoteDetails.createRoute(noteId)) },
                onCreateNote = { navController.navigate(Route.CreateNote.createRoute(albumId)) },
                onBack = { navController.popBackStack() }
            )
        }

        composable(Route.Analytics.route) {
            val vm: AnalyticsViewModel = viewModel(factory = factory)
            AnalyticsScreenStateful(
                vm = vm,
                onBack = { navController.popBackStack() }
            )
        }

        composable(
            route = Route.NoteDetails.route,
            arguments = listOf(
                navArgument(Route.NoteDetails.idArg) { type = NavType.LongType }
            )
        ) { backStackEntry ->
            val noteId = backStackEntry.arguments?.getLong(Route.NoteDetails.idArg)
                ?: return@composable
            val vm: NoteDetailsViewModel = viewModel(factory = factory)

            NoteDetailsScreen(
                vm = vm,
                noteId = noteId,
                onBack = { navController.popBackStack() }
            )
        }

        composable(
            route = Route.CreateNote.route,
            arguments = listOf(
                navArgument(Route.CreateNote.albumIdArg) {
                    type = NavType.LongType
                }
            )
        ) { backStackEntry ->
            val albumId = backStackEntry.arguments?.getLong(Route.CreateNote.albumIdArg)
                ?: return@composable
            val vm: CreateNoteViewModel = viewModel(factory = factory)

            CreateNoteScreenStateful(
                vm = vm,
                albumId = albumId,
                onBack = { navController.popBackStack() }
            )
        }
    }
}
