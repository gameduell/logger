//
//  Created by Julián Mancera.
//  Copyright (c) 2015 GameDuell GmbH. All rights reserved.
//

#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#include <hx/CFFI.h>

#import <Foundation/Foundation.h>

// path of the duell log in the device filesystem
static NSString *duellLogPath;

// name of the log file
static NSString *fileName = @"duell_log.txt";

// size in characters allowed for the log file
static int logSize = 10000;

static NSString* valueToNSString(value haxeString)
{
    const char *cString = val_get_string(haxeString);

    NSString *string = [NSString stringWithUTF8String:cString];
    return string;
}

static void redirectOutput()
{
    NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [allPaths objectAtIndex:0];
    duellLogPath = [documentsDirectory stringByAppendingPathComponent:fileName];

    // redirect the stdout to the specified file
    freopen([duellLogPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);

    // disable the buffering
    setbuf(stdout, NULL);

    fprintf(stdout, "\n\nBeginning of the redirected stdout\n");
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

static void initialize()
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
}
DEFINE_PRIM(initialize, 0);

static value getLogPath()
{
    if (duellLogPath)
    {
        return alloc_string(duellLogPath.UTF8String);
    }
    else
    {
        return alloc_null();
    }
}
DEFINE_PRIM(getLogPath, 0);

static value flush()
{
    truncateLogFile();
    return alloc_bool(YES);
}
DEFINE_PRIM(flush, 0);

extern "C" int loggerios_register_prims() { return 0; }
