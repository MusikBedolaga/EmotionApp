package com.example.emotionapp.data.network

import android.content.SharedPreferences
import java.util.Base64
import javax.inject.Inject
import org.json.JSONObject

class TokenStorage @Inject constructor(
    private val prefs: SharedPreferences
) {
    fun save(token: String) = prefs.edit().putString(KEY, token).apply()

    fun get(): String? = prefs.getString(KEY, null)

    fun getUserId(): Long? {
        val payload = get()?.split(".")?.getOrNull(1) ?: return null
        return runCatching {
            val normalized = payload
                .replace('-', '+')
                .replace('_', '/')
                .padEnd((payload.length + 3) / 4 * 4, '=')
            val decoded = String(Base64.getDecoder().decode(normalized))
            JSONObject(decoded).optLong("id").takeIf { it > 0 }
        }.getOrNull()
    }

    fun clear() = prefs.edit().remove(KEY).apply()

    private companion object {
        const val KEY = "jwt_token"
    }
}
