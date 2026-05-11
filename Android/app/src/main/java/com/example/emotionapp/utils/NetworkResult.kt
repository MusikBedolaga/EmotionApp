package com.example.emotionapp.utils

sealed interface NetworkResult<out T> {
    data class Ok<T>(val data: T): NetworkResult<T>

    sealed interface Error: NetworkResult<Nothing> {
        data class Http(val code: Int, val body: String?) : Error
        data class Network(val message: String?) : Error
        data class Unknown(val message: String?) : Error
    }
}

fun <T> NetworkResult<T>.asErrorText(what: String): String? = when (this) {
    is NetworkResult.Ok -> null
    is NetworkResult.Error.Http -> "Ошибка HTTP (${code}) при загрузке: $what"
    is NetworkResult.Error.Network -> "Ошибка сети при загрузке: $what"
    is NetworkResult.Error.Unknown -> "Неизвестная ошибка при загрузке: $what"
}
