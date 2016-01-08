/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package logger;

/**
   @author jman
 */
class Logger
{
    public static function initialize(callback: Void->Void): Void
    {
        /// not needed in html5
        callback();
    }

    public static function getLogPath(): String
    {
        return "null";
    }

    public static function flush(): Bool
    {
        return false;
    }

    public static dynamic function print(v: Dynamic, ?pos: haxe.PosInfos = null)
    {
        untyped js.Boot.__trace(v, pos);
    }
}
