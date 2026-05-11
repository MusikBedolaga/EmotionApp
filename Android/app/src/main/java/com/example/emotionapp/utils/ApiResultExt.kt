package com.example.emotionapp.utils

import com.example.emotionapp.data.api.ApiResult

fun <T : Any, R> ApiResult<T>.toNetworkResult(mapper: (T) -> R): NetworkResult<R> =
    when (this) {
        is ApiResult.Success ->
            NetworkResult.Ok(mapper(this.data))

        is ApiResult.HttpError ->
            NetworkResult.Error.Http(code = this.code, body = this.message)

        is ApiResult.NetworkError ->
            NetworkResult.Error.Network(message = this.error.message)

        is ApiResult.UnknownError ->
            NetworkResult.Error.Unknown(message = this.error.message)
    }