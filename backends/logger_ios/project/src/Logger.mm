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
 
#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#include <hx/CFFI.h>
#include "Logger.h"

// path of the duell log in the device filesystem
static NSString *duellLogPath;

// name of the log file
static NSString *fileName = @"duellkit.log";

// size in characters allowed for the log file
static int logSize = 100 * 1024; // 100 KB

static void redirectOutput()
{
    NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [allPaths objectAtIndex:0];
    duellLogPath = [documentsDirectory stringByAppendingPathComponent:fileName];

    // redirect the stdout to the specified file
    freopen([duellLogPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);

    // disable the buffering
    setbuf(stdout, NULL);

    fprintf(stdout, "\n\n==============================\n");
    fprintf(stdout, "NEW LOG FILE\n");
    fprintf(stdout, "==============================\n");
}

static void truncateLogFile()
{
    NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [allPaths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path])
    {
        NSError* error = nil;
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];

        // truncation
        if ([content length] > logSize)
        {
            NSString *truncated = [content substringFromIndex: [content length] - logSize];

            NSString *newContent = [NSString stringWithFormat: @"... (the file was truncated because it was too long)%@", truncated];

            // delete the old file
            [fileManager removeItemAtPath:path error:&error];

            // redirect the stdout to the specified file
            freopen([duellLogPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);

            // disable the buffering again, just in case
            setbuf(stdout, NULL);

            // append the truncated data to the new file
            BOOL success = [newContent  writeToFile:path
                                        atomically:NO
                                        encoding:NSUTF8StringEncoding
                                        error:nil];

            if (success)
            {
                fprintf(stdout, "Logger: The log was stored successfully\n");
            }
            else
            {
                fprintf(stdout, "Logger: Could not store the log\n");
            }
        }
    }
}

static value logger_initialize()
{
    // redirect only if there is not debug available
    if (!isatty(STDERR_FILENO))
    {
        truncateLogFile();
        redirectOutput();
    }
    else
    {
        NSLog(@"Debug mode, the output will not be redirected");
    }

    return alloc_null();
}
DEFINE_PRIM(logger_initialize, 0);

static value logger_flush()
{
    return alloc_bool([Logger flush]);
}
DEFINE_PRIM(logger_flush, 0);

static value logger_getLogPath()
{
    NSString* logPath = [Logger getLogPath];

    //convert NSString to haxe string
    value haxeString = alloc_string_len((const char *)[logPath UTF8String], [logPath length]);

    return haxeString;
}
DEFINE_PRIM(logger_getLogPath, 0);


@implementation Logger
+ (BOOL)flush
{
    truncateLogFile();
    return true;
}

+ (NSString*)getLogPath
{
    if (duellLogPath)
    {
        return duellLogPath;
    }
    else
    {
        return @"";
    }
}
@end


extern "C" int loggerios_register_prims() { return 0; }
