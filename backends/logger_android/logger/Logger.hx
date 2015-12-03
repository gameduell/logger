/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package logger;

import hxjni.JNI;

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
}
