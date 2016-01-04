/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package backends.logger_html5.logger;

/**
   @author jman
 */
class Logger
{
    public static function initialize(): Void
    {}

    public static function getLogPath(): String
    {
        return "null";
    }

    public static function flush(): Bool
    {
        return false;
    }

    public static function testException(): Void
    {}

    public static dynamic function print(v: Dynamic, ?pos: haxe.PosInfos = null)
    {
        var msg = js.Boot.__string_rec(v,"");
        var d;
        if( __js__("typeof")(document) != "undefined"
        && (d = document.getElementById("haxe:trace")) != null ) {
            msg = msg.split("\n").join("<br/>");
            d.innerHTML += StringTools.htmlEscape(msg)+"<br/>";
        }
        else if (  __js__("typeof process") != "undefined"
        && __js__("process").stdout != null
        && __js__("process").stdout.write != null)
            __js__("process").stdout.write(msg); // node
        else if (  __js__("typeof console") != "undefined"
        && __js__("console").log != null )
            __js__("console").log(msg); // document-less js (which may include a line break)

    }
}
