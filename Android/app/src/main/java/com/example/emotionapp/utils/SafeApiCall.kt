package com.example.emotionapp.utils

import com.example.emotionapp.data.api.ApiResult
import java.io.IOException
import retrofit2.Response

suspend fun <T : Any> safeApiCall(
    call: suspend () -> Response<T>
): ApiResult<T> {
    return try {
        val response = call()

        if (response.isSuccessful) {
            val body = response.body()
            if (body != null) ApiResult.Success(body)
            else ApiResult.HttpError(response.code(), "Empty body")
        } else {
            ApiResult.HttpError(
                code = response.code(),
                message = response.errorBody()?.string()
            )
        }
    } catch (e: IOException) {
        ApiResult.NetworkError(e)
    } catch (t: Throwable) {
        ApiResult.UnknownError(t)
    }
}