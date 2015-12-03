/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package org.haxe.duell.logger;

import android.content.Intent;
import android.net.Uri;
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
import java.util.Date;

import android.content.Context;

/**
 * @author jman
 */
public final class Logger
{
    private static final String TAG = Logger.class.getSimpleName();

    /** The data lock to write files. */
    public static final Object DATA_LOCK = new Object();

    public static final String FILE_NAME = "duell_log.txt";

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
            String logPath = context.getExternalCacheDir() + "/" + FILE_NAME;
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
        return duellLogPath;
    }

    public static boolean flush()
    {
        StringBuilder log = new StringBuilder();

        try
        {
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

            // retrieve all possible information from logcat
            Process process = Runtime.getRuntime().exec("logcat -d -v long");
            BufferedReader bufferedReader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()));

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
            }

            bufferedReader.close();

            // send only if external media is available, else we can't store the file
            if (isExternalMediaAvailable(true))
            {
                // print the log to a file in cache
                final Context context = ctxReference.get();
                duellLogPath = context.getExternalCacheDir() + "/" + FILE_NAME;
                final File file = new File(duellLogPath);

                writeToFile(
                        new BufferedOutputStream(new FileOutputStream(file)), log.toString());

                // send the log in e-mail
                Intent intent = new Intent(Intent.ACTION_SENDTO,
                        Uri.fromParts("mailto", "julian.mancera@gameduell.de", null));
                intent.putExtra(Intent.EXTRA_SUBJECT, "duell log report: " + new Date().toString());
                intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(file));
                context.startActivity(Intent.createChooser(intent, "Send log"));

                // flush logcat so it doesn't send repeated info
                Runtime.getRuntime().exec("logcat -c");

                return true;
            }
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
     * Writes a string to the given {@link OutputStream}.
     *
     * @param _os   the output stream to write to
     * @param _data the data to write
     * @throws IOException if the writing fails
     */
    private static void writeToFile(final OutputStream _os, final String _data) throws IOException
    {
        synchronized (DATA_LOCK)
        {
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(_os);
            outputStreamWriter.write(_data);
            outputStreamWriter.close();
        }
    }
}