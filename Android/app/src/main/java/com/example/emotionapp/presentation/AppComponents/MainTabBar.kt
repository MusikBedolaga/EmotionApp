package com.example.emotionapp.presentation.AppComponents

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AddCircleOutline
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.PersonOutline
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.example.emotionapp.di.DaggerViewModelFactory
import com.example.emotionapp.navigation.Route
import com.example.emotionapp.presentation.CreateAlbum.CreateAlbumScreenStateful
import com.example.emotionapp.presentation.CreateAlbum.CreateAlbumViewModel
import com.example.emotionapp.presentation.Main.MainScreen
import com.example.emotionapp.presentation.Main.MainViewModel
import com.example.emotionapp.presentation.Settings.SettingsScreenStateful
import com.example.emotionapp.presentation.Settings.SettingsViewModel

data class BottomTab(
    val route: String,
    val title: String,
    val icon: ImageVector
)

@Composable
fun MainTabBar(
    factory: DaggerViewModelFactory,
    onOpenAlbum: (Long, String) -> Unit,
    onAnalyticsClick: () -> Unit = {},
    onLogout: () -> Unit = {}
) {
    val navController = rememberNavController()
    val tabs = listOf(
        BottomTab(Route.Home.route, "Home", Icons.Outlined.Home),
        BottomTab(Route.Create.route, "Создать", Icons.Outlined.AddCircleOutline),
        BottomTab(Route.Profile.route, "Профиль", Icons.Outlined.PersonOutline)
    )


    Scaffold(
        bottomBar = { BottomTabsBar(tabs, navController) }
    ) { padding ->
        NavHost(
            navController = navController,
            startDestination = Route.Home.route,
            modifier = Modifier.padding(padding)
        ) {
            composable(Route.Home.route) {
                val vm: MainViewModel = viewModel(factory = factory)
                MainScreen(
                    vm = vm,
                    onOpenAlbum = onOpenAlbum,
                    onAnalyticsClick = onAnalyticsClick,
                    onCreateAlbum = {
                        navController.navigate(Route.Create.route) {
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                )
            }
            composable(Route.Create.route) {
                val vm: CreateAlbumViewModel = viewModel(factory = factory)
                CreateAlbumScreenStateful(
                    vm = vm,
                    title = "Создать альбом",
                    onSaved = {
                        navController.navigate(Route.Home.route) {
                            popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                )
            }
            composable(Route.Profile.route) {
                val vm: SettingsViewModel = viewModel(factory = factory)
                SettingsScreenStateful(
                    vm = vm,
                    onLogout = onLogout
                )
            }
        }
    }
}

@Composable
private fun BottomTabsBar(
    tabs: List<BottomTab>,
    navController: NavHostController,
) {
    val backStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = backStackEntry?.destination?.route

    val selected = Color(0xFF2F6BFF)
    val unselected = Color(0xFF9AA3AF)
    val background = Color(0xFFF2F3F5)

    NavigationBar(
        containerColor = background,
        tonalElevation = 0.dp
    ) {
        tabs.forEach { tab ->
            val isSelected = currentRoute == tab.route

            NavigationBarItem(
                selected = isSelected,
                onClick = {
                    navController.navigate(tab.route) {
                        popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                        launchSingleTop = true
                        restoreState = true
                    }
                },
                icon = { Icon(tab.icon, contentDescription = tab.title) },
                label = { Text(tab.title) },
                alwaysShowLabel = true,
                colors = NavigationBarItemDefaults.colors(
                    selectedIconColor = selected,
                    selectedTextColor = selected,
                    unselectedIconColor = unselected,
                    unselectedTextColor = unselected,
                    indicatorColor = Color.Transparent
                )
            )
        }
    }
}
