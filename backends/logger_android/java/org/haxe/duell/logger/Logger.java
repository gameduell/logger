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
package org.haxe.duell.logger;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.lang.ref.WeakReference;

import android.os.Build;
import android.os.Environment;
import android.content.Context;

import org.haxe.duell.DuellActivity;

/**
 * @author jman
 */
public final class Logger
{
    public static final String LOG_FILE_NAME = "duellkit.log";

    private static WeakReference<Context> ctxReference = new WeakReference<Context>(DuellActivity.getInstance());

    private Logger()
    {
        // can't be instantiated
    }

    public static String getLogPath()
    {
        if (isExternalMediaAvailable(true))
        {
            // check if there exists a previous log file
            String logPath = String.format("%s/%s", ctxReference.get().getExternalCacheDir(), LOG_FILE_NAME);
            if (new File(logPath).exists())
            {
                return logPath;
            }
        }

        return null;
    }

    public static boolean flush()
    {
        if (!isExternalMediaAvailable(true)) return false;

        try
        {
            final File file = new File(String.format("%s/%s", ctxReference.get().getExternalCacheDir(), LOG_FILE_NAME));
            final BufferedOutputStream bufferedOutput = new BufferedOutputStream(new FileOutputStream(file));
            final OutputStreamWriter output = new OutputStreamWriter(bufferedOutput);

            // provide useful device information
            output.write(System.getProperty("os.version"));
            output.write('\n');
            output.write(Build.DEVICE);
            output.write('\n');
            output.write(Build.MODEL);
            output.write('\n');
            output.write(Build.PRODUCT);
            output.write('\n');
            output.write(Build.VERSION.RELEASE);
            output.write('\n');

            // retrieve all possible information from logcat
            // the max size of the logcat is around 256Kb by "adb logcat -g"
            Process process = Runtime.getRuntime().exec("logcat -d -v long");
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));

            String line;
            while ((line = bufferedReader.readLine()) != null)
            {
                // ignore blank lines
                if (line.trim().length() == 0)
                {
                    continue;
                }

                output.write(line);
                output.write(line.charAt(line.length() - 1) == ']' ? ' ' : '\n');
            }
            bufferedReader.close();

            output.write("--------- log end");
            output.close();

            // flush logcat so it doesn't store repeated info
            new Thread(new Runnable() {
                @Override
                public void run() {
                    android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_BACKGROUND);
                    try
                    {
                        Runtime.getRuntime().exec("logcat -c");
                    }
                    catch (IOException e)
                    {
                        // ignore
                    }
                }
            }).start();
        }
        catch (IOException e)
        {
            // ignore
        }

        return false;
    }

    //
    // External
    //

    /**
     * Whether the external media is available. Return value depends on whether write permissions are required or not.
     *
     * @param _needsWritePermissions true if write permission is required, false otherwise
     * @return true if it is available for the requested permission
     */
    private static boolean isExternalMediaAvailable(final boolean _needsWritePermissions)
    {
        String state = Environment.getExternalStorageState();

        if (Environment.MEDIA_MOUNTED.equals(state))
        {
            return true;
        }
        else if (Environment.MEDIA_MOUNTED_READ_ONLY.equals(state))
        {
            return !_needsWritePermissions;
        }

        return false;
    }
}