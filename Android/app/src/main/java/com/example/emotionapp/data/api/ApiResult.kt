package com.example.emotionapp.data.api
import java.io.IOException

sealed interface ApiResult<out T> {
    data class Success<T>(val data: T) : ApiResult<T>
    data class HttpError(val code: Int, val message: String?) : ApiResult<Nothing>
    data class NetworkError(val error: IOException) : ApiResult<Nothing>
    data class UnknownError(val error: Throwable) : ApiResult<Nothing>
}
