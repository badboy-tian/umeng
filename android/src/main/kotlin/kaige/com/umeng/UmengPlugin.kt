package kaige.com.umeng

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.umeng.analytics.MobclickAgent
import com.umeng.cconfig.RemoteConfigSettings
import com.umeng.cconfig.UMRemoteConfig
import com.umeng.commonsdk.UMConfigure
import com.umeng.umcrash.UMCrash
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** UmengPlugin */
class UmengPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "kaige.com/umeng_analytics")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when(call.method){
      "init" -> init(call, result)
      "pageStart" -> pageStart(call, result)
      "pageEnd" -> pageEnd(call, result)
      "onEvent" -> onEvent(call, result)
      "uploadLog" -> uploadLog(call, result)
      "onProfileSignIn" -> onProfileSignIn(call, result)
      "onProfileSignOff" -> onProfileSignOff(call, result)
      "getOnlineParam" -> getOnlineParam(call, result)
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      else -> result.notImplemented()
    }
  }
  private fun init(@NonNull call: MethodCall, @NonNull result: Result){
    val logEnabled = call.argument<Boolean>("logEnabled")
    UMConfigure.setLogEnabled(logEnabled ?: false)

    val encryptEnabled = call.argument<Boolean>("encryptEnabled")
    UMConfigure.setEncryptEnabled(encryptEnabled ?: false)

    val onlineParamEnabled = call.argument<Boolean>("onlineParamEnabled")
    if(onlineParamEnabled == true){
      UMRemoteConfig.getInstance().setConfigSettings(RemoteConfigSettings.Builder().setAutoUpdateModeEnabled(true).build())
    }

    val processEventEnabled = call.argument<Boolean>("processEventEnabled")
    UMConfigure.setProcessEvent(processEventEnabled ?: true)

    val androidKey = call.argument<String>("androidKey");
    val channel = call.argument<String>("channel");
    UMConfigure.init(context, androidKey, channel, UMConfigure.DEVICE_TYPE_PHONE, null)

    val sessionContinueMillis = call.argument<Int>("sessionContinueMillis")
    MobclickAgent.setSessionContinueMillis(sessionContinueMillis?.toLong() ?: 30000)

    val catchUncaughtExceptionsEnabled = call.argument<Boolean>("catchUncaughtExceptionsEnabled")
    MobclickAgent.setCatchUncaughtExceptions(catchUncaughtExceptionsEnabled ?: true)

    val pageCollectMode = call.argument<String>("pageCollectMode")
    if("MANUAL" == pageCollectMode){
      MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.MANUAL)
    }else{
      MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.AUTO)
    }

    result.success(true)
  }
  private fun pageStart(call: MethodCall, result: Result) {
    val widget = call.argument<String>("widget")
    MobclickAgent.onPageStart(widget)
    result.success(true)
  }

  private fun pageEnd(call: MethodCall, result: Result) {
    val widget = call.argument<String>("widget")
    MobclickAgent.onPageEnd(widget)
    result.success(true)
  }

  private fun onEvent(call: MethodCall, result: Result) {
    val eventId = call.argument<String>("eventId")
    val properties = call.argument<Map<String, Object>>("properties")
    MobclickAgent.onEventObject(context, eventId, properties)
    result.success(true)
  }

  private fun uploadLog(call: MethodCall, result: Result) {
    val error = call.argument<String>("error")
    val type = call.argument<String>("type")
    UMCrash.generateCustomLog(error, type)
    result.success(true)
  }

  private fun onProfileSignIn(call: MethodCall, result: Result){
    val id = call.argument<String>("id")
    val provider = call.argument<String>("provider")
    MobclickAgent.onProfileSignIn(provider, id)
    result.success(true)
  }
  private fun onProfileSignOff(call: MethodCall, result: Result){
    MobclickAgent.onProfileSignOff()
    result.success(true)
  }

  private fun getOnlineParam(call: MethodCall, result: Result){
    val key = call.argument<String>("key")
    val onlineParam: String? = UMRemoteConfig.getInstance().getConfigValue(key)
    result.success(onlineParam)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
