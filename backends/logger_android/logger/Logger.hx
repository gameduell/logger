/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
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

    public static function initialize(): Void
    {
        return initializeNative();
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

            if (v.length > 4000)
                msg = msg.substr(0, 4000);

            androidPrint(msg);
        }
    }
}
