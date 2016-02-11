/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package logger;

import cpp.Lib;

/**
    @author jman
 */
class Logger
{
    private static var initializeNative = Lib.load("loggerios", "logger_initialize", 0);
    private static var getLogPathNative = Lib.load("loggerios", "logger_getLogPath", 0);
    private static var flushNative = Lib.load("loggerios", "logger_flush", 0);

    public static function initialize(callback: Void->Void): Void
    {
        initializeNative();

        /// not async for ios
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

    public static dynamic function print(v: Dynamic, ?pos: haxe.PosInfos = null) untyped
    {
        cpp.Lib.print(v);
    }
}
