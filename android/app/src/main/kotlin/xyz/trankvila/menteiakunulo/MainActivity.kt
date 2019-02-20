package xyz.trankvila.menteiakunulo

import android.os.Bundle
import android.media.MediaPlayer
import android.net.Uri
import android.util.Log
import com.google.firebase.FirebaseApp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.iid.FirebaseInstanceId

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File
import java.io.FileInputStream

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    GeneratedPluginRegistrant.registerWith(this)
    MethodChannel(flutterView, "xyz.trankvila.menteiakunulo/audioplayer").setMethodCallHandler { call, result ->
      android.util.Log.d("TAG", call.method)
      if (call.method == "playAudio") {
        val bytes = call.arguments as ByteArray
        val outputDirectory = applicationContext.cacheDir
        val file = File.createTempFile("temp", "ogg", outputDirectory)
        file.writeBytes(bytes)
        val mediaPlayer = MediaPlayer.create(applicationContext, Uri.fromFile(file))
        mediaPlayer.setOnCompletionListener {
          it.stop()
          it.release()
          file.delete()
        }
        mediaPlayer.start()
        result.success(null)
      } else {
        result.notImplemented()
      }
    }
  }
}
