package com.example.emotionapp.di

import androidx.lifecycle.ViewModel
import com.example.emotionapp.navigation.AppStartViewModel
import com.example.emotionapp.presentation.Analytics.AnalyticsViewModel
import com.example.emotionapp.presentation.AlbumDetails.AlbumDetailsViewModel
import com.example.emotionapp.presentation.Auth.AuthViewModel
import com.example.emotionapp.presentation.CreateAlbum.CreateAlbumViewModel
import com.example.emotionapp.presentation.CreateNote.CreateNoteViewModel
import com.example.emotionapp.presentation.Main.MainViewModel
import com.example.emotionapp.presentation.NoteDetails.NoteDetailsViewModel
import com.example.emotionapp.presentation.Onboarding.OnboardingViewModel
import com.example.emotionapp.presentation.Settings.SettingsViewModel
import dagger.Binds
import dagger.Module
import dagger.multibindings.IntoMap

@Module
interface ViewModelModule {

    @Binds
    @IntoMap @ViewModelKey(OnboardingViewModel::class)
    fun bindOnboardingViewModel(vm: OnboardingViewModel): ViewModel

    @Binds
    @IntoMap @ViewModelKey(AuthViewModel::class)
    fun bindAuthViewModel(vm: AuthViewModel): ViewModel

    @Binds
    @IntoMap @ViewModelKey(AppStartViewModel::class)
    fun bindAppStartViewModel(vm: AppStartViewModel): ViewModel

    @Binds
    @IntoMap @ViewModelKey(MainViewModel::class)
    fun bindMainViewModel(vm: MainViewModel): ViewModel

    @Binds
    @IntoMap @ViewModelKey(AlbumDetailsViewModel::class)
    fun bindAlbumDetailsViewModel(vm: AlbumDetailsViewModel): ViewModel

    @Binds
    @IntoMap @ViewModelKey(NoteDetailsViewModel::class)
    fun bindNoteDetailsViewModel(vm: NoteDetailsViewModel): ViewModel

    @Binds
    @IntoMap @ViewModelKey(AnalyticsViewModel::class)
    fun bindAnalyticsViewModel(vm: AnalyticsViewModel): ViewModel

    @Binds
    @IntoMap @ViewModelKey(SettingsViewModel::class)
    fun bindSettingsViewModel(vm: SettingsViewModel): ViewModel

    @Binds
    @IntoMap @ViewModelKey(CreateAlbumViewModel::class)
    fun bindCreateAlbumViewModel(vm: CreateAlbumViewModel): ViewModel

    @Binds
    @IntoMap @ViewModelKey(CreateNoteViewModel::class)
    fun bindCreateNoteViewModel(vm: CreateNoteViewModel): ViewModel
}