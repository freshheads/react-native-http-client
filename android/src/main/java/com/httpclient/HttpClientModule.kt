package com.httpclient

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import okhttp3.*
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException

class NativeHttpClient(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun get(
      url: String,
      optionsJson: String? = null,
      promise: Promise
  ) {
      val client = OkHttpClient()

      val options = if (optionsJson != null) JSONObject(optionsJson) else JSONObject()
      val headers = options.optJSONObject("headers")?.toMap() as Map<String, String>? ?: mapOf()
      val params = options.optJSONObject("params")?.toMap() as Map<String, String>? ?: mapOf()

      val httpUrl = url.toHttpUrlOrNull()?.newBuilder()
      if (httpUrl != null) {
          for ((key, value) in params) {
              httpUrl.addQueryParameter(key, value)
          }
      }

      val requestBuilder = Request.Builder()

      if (httpUrl != null) {
          requestBuilder.url(httpUrl.build())
      }

      for ((key, value) in headers) {
          requestBuilder.addHeader(key, value)
      }

      client.newCall(requestBuilder.build()).enqueue(object : Callback {
          override fun onFailure(call: Call, e: IOException) {
              promise.reject(e)
          }

          override fun onResponse(call: Call, response: Response) {
              response.body?.use { responseBody ->
                      val requestHeadersMap = call.request().headers.toMultimap().mapValues { it.value.joinToString(",") }
                      val responseHeadersMap = response.headers.toMultimap().mapValues { it.value.joinToString(",") }
                      val jsonResult = JSONObject().apply {
                          put("statusCode", response.code)
                          put("requestHeaders", JSONObject(requestHeadersMap))
                          put("responseHeaders", JSONObject(responseHeadersMap))
                          put("body", responseBody.string().trim('\u0000'))
                      }
                      promise.resolve(jsonResult.toString())
                  }
          }
      })
  }

  private fun JSONObject.toMap(): Map<String, *> = keys().asSequence().associateWith { it ->
    when (val value = this[it])
    {
        is JSONArray ->
        {
            val map = (0 until value.length()).associate { Pair(it.toString(), value[it]) }
            JSONObject(map).toMap().values.toList()
        }
        is JSONObject -> value.toMap()
        JSONObject.NULL -> null
        else            -> value
    }
  }

  companion object {
    const val NAME = "HttpClient"
  }
}
