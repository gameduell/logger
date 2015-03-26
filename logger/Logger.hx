/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package logger;

#if js
import js.html.Console;
#end

/**   
    @author jxav
 */
#if android
@:headerCode("
	#include <android/log.h>
")
#end
@:final class Logger
{

///static
#if flash
    private static var tf: flash.text.TextField = null;
#end

#if android
    @:functionCode("
		if (((v == null()))){
			__android_log_print(ANDROID_LOG_INFO, HX_CSTRING(\"duell\"), HX_CSTRING(\"\"));
		}
		else{
			__android_log_print(ANDROID_LOG_INFO, HX_CSTRING(\"duell\"), v->toString());
		}
		return null();
    ")
    public static function print(v: Dynamic, ?pos: haxe.PosInfos = null)
    {}
#else
    public static dynamic function print(v: Dynamic, ?pos: haxe.PosInfos = null) untyped
    {
#if flash
        tf = flash.Boot.getTrace();
        var s = flash.Boot.__string_rec(v,"");
        tf.text +=s;
#elseif neko
        __dollar__print(v);
#elseif php
        php.Lib.print(v);
#elseif cpp
        cpp.Lib.print(v);
#elseif js
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

#elseif cs
        cs.system.Console.Write(v);
#elseif java
        var str:String = v;
        untyped __java__("java.lang.System.out.print(str)");
#end
    }
#end ///not android
}
