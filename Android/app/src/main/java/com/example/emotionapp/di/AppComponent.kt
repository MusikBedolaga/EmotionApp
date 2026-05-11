package com.example.emotionapp.di

import android.content.Context
import dagger.BindsInstance
import dagger.Component
import javax.inject.Singleton

@Singleton
@Component(
    modules = [
        NetworkModule::class,
        ApiModule::class,
        RepositoryProvideModule::class,
        RepositoryBindsModule::class,
        ViewModelModule::class
    ]
)
interface AppComponent {

    fun viewModelFactory(): DaggerViewModelFactory

    @Component.Factory
    interface Factory {
        fun create(
            @BindsInstance context: Context,
            @BindsInstance @BaseUrl baseUrl: String
        ): AppComponent
    }
}