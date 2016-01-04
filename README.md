## Description

This library provides a simple print method. It is basically a replacement to the trace method in order to not append the file name and line number automatically.

## Usage:

Simply call Logger.print("<some string>")

## Release Log

### 1.0.0

Initial release

### 2.0.0

- Added handling for log flushing.
- The size of the log is limited to 100KB.
- Created backends for Android, iOS and html5.
- Cleaned up the logger class and made it extern.
