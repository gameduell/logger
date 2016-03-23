/*
 * Copyright (c) 2003-2016, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package logger;

import hxjni.JNI;

@:headerCode("
	#include <android/log.h>
")

/**
   @author jman
 */
class Logger
{
    private static var initializeNative = JNI.createStaticMethod("org/haxe/duell/logger/Logger", "initialize", "()V");
    private static var getLogPathNative = JNI.createStaticMethod("org/haxe/duell/logger/Logger", "getLogPath", "()Ljava/lang/String;");
    private static var flushNative = JNI.createStaticMethod("org/haxe/duell/logger/Logger", "flush", "()Z");

    public static function initialize(callback: Void->Void): Void
    {
        initializeNative();

		/// not async for android
		callback();
    }

    public static function getLogPath(): String
    {
        return getLogPathNative();
    }

    public static function flush(): Bool
    {
        return flushNative();
    }

    @:functionCode("
		if (((v == null()))){
			__android_log_print(ANDROID_LOG_INFO, HX_CSTRING(\"duell\"), HX_CSTRING(\"\"));
		}
		else{
			__android_log_print(ANDROID_LOG_INFO, HX_CSTRING(\"duell\"), v->toString());
		}
		return null();
    ")
    private static function androidPrint(v: Dynamic)
    {}

    public static dynamic function print(v: Dynamic)
    {
        if (v == null)
        {
            androidPrint("null");
        }
        else
        {
            var msg: String = Std.string(v);
			/// logcat doesn't play well with big lines
            if (v.length > 4000)
                msg = msg.substr(0, 4000);

            androidPrint(msg);
        }
    }
}
