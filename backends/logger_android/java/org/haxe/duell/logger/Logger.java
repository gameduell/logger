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

import android.os.Build;
import android.os.Environment;
import org.haxe.duell.DuellActivity;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.lang.ref.WeakReference;

import android.content.Context;

/**
 * @author jman
 */
public final class Logger
{
    /** The data lock to write files. */
    public static final Object DATA_LOCK = new Object();

    public static final String LOG_FILE_NAME = "duellkit.log";

    private static WeakReference<Context> ctxReference = new WeakReference<Context>(DuellActivity.getInstance());

    private static String duellLogPath;

    private Logger()
    {
        // can't be instantiated
    }

    public static void initialize()
    {
        if (isExternalMediaAvailable(true))
        {
            // check if there exists a previous log file
            final Context context = ctxReference.get();
            String logPath = context.getExternalCacheDir() + "/" + LOG_FILE_NAME;
            final File file = new File(logPath);

            if (file.exists())
            {
                duellLogPath = logPath;
            }
            else
            {
                duellLogPath = "";
            }
        }
    }

    public static String getLogPath()
    {
        if (isExternalMediaAvailable(true))
        {
            // check if there exists a previous log file
            final Context context = ctxReference.get();
            String logPath = context.getExternalCacheDir() + "/" + LOG_FILE_NAME;
            final File file = new File(logPath);

            if (file.exists())
            {
                duellLogPath = logPath;
            }
            else
            {
                duellLogPath = "";
            }
        }

        return duellLogPath;
    }

    public static boolean flush()
    {
        StringBuilder log = new StringBuilder();

        try
        {
            final Context context = ctxReference.get();
            duellLogPath = context.getExternalCacheDir() + "/" + LOG_FILE_NAME;
            final File file = new File(duellLogPath);
            BufferedOutputStream bufferedOutput = new BufferedOutputStream(new FileOutputStream(file));
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(bufferedOutput);

            // provide useful device information
            log.append(System.getProperty("os.version")); // OS version
            log.append("\n");
            log.append(Build.DEVICE); // Device
            log.append("\n");
            log.append(Build.MODEL); // Model
            log.append("\n");
            log.append(Build.PRODUCT); // Product
            log.append("\n");
            log.append(Build.VERSION.RELEASE); // Version
            log.append("\n");

            writeToFile(outputStreamWriter, log.toString());

            // retrieve all possible information from logcat
            // the max size of the logcat is around 256Kb by "adb logcat -g"
            Process process = Runtime.getRuntime().exec("logcat -d -v long");
            BufferedReader bufferedReader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()));

            log.setLength(0);
            String line;
            while ((line = bufferedReader.readLine()) != null)
            {
                // ignore blank lines
                if (line.trim().equals(""))
                {
                    continue;
                }

                log.append(line);

                if (line.endsWith("]"))
                {
                    log.append(" ");
                }
                else
                {
                    log.append("\n");
                }

                writeToFile(outputStreamWriter, log.toString());
                log.setLength(0);
            }

            bufferedReader.close();

            // flush logcat so it doesn't store repeated info
            Runtime.getRuntime().exec("logcat -c");

            outputStreamWriter.close();
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

    //
    // R&W
    //

    /**
     * Writes a string to the given {@link OutputStreamWriter}.
     *
     * @param _os   the output stream to write to
     * @param _data the data to write
     * @throws IOException if the writing fails
     */
    private static void writeToFile(final OutputStreamWriter _outputStreamWriter, final String _data) throws IOException
    {
        synchronized (DATA_LOCK)
        {
            // store only if external media is available
            if (isExternalMediaAvailable(true))
            {
                // print the log to a file in cache
                _outputStreamWriter.write(_data);
            }
        }
    }
}