package com.mahmoud.flutter_guard

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

/*
 * Unit tests for the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

internal class FlutterGuardPluginTest {
    @Test
    fun enableProtection_withoutActivity_returnsNoActivityError() {
        val guard = ScreenGuard()
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        guard.onMethodCall(MethodCall("enableProtection", null), mockResult)

        Mockito.verify(mockResult).error(
            Mockito.eq("NO_ACTIVITY"), Mockito.anyString(), Mockito.isNull()
        )
    }

    @Test
    fun unknownMethod_returnsNotImplemented() {
        val guard = ScreenGuard()
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        guard.onMethodCall(MethodCall("unknown", null), mockResult)

        Mockito.verify(mockResult).notImplemented()
    }
}
