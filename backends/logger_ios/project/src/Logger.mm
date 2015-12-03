//
//  Created by Julián Mancera.
//  Copyright (c) 2015 GameDuell GmbH. All rights reserved.
//

#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#include <hx/CFFI.h>

#import <Foundation/Foundation.h>

static NSString *duellLogPath;
static NSString *fileName = @"duell_log.txt";

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

    fprintf(stdout, "\n\nBeginning of the redirected stdout\n");
}

static void removeLog()
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

  NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
  NSError *error;
  BOOL success = [fileManager removeItemAtPath:filePath error:&error];
  if (success) {
      NSLog(@"The log was deleted successfully");
  }
  else
  {
      NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
  }
}

static void initialize()
{
    // redirect only if there is not debug available
    if (!isatty(STDERR_FILENO))
    {
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
    fflush(stdout);
    return alloc_bool(YES);
}
DEFINE_PRIM(flush, 0);

extern "C" int loggerios_register_prims() { return 0; }
