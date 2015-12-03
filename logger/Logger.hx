/*
 * Copyright (c) 2003-2015, GameDuell GmbH
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

#if js
import js.html.Console;
#end

/**
    @author jxav
 */
@:final class Logger
{

///static
#if flash
    private static var tf: flash.text.TextField = null;
#end

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
}
