//
//  ATKLog.m
//  AppToolkit
//
//  Created by Rizwan Sattar on 1/23/15.
//
//

#import "ATKLog.h"

BOOL ATKLOG_ENABLED = NO;

#if DEBUG
// See: http://stackoverflow.com/a/3530807/9849
static inline void ATKLogFormat(NSString *level, NSString *format, va_list arg_list) {
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:arg_list];
    if (level) {
        NSLog(@"[AppToolkit][%@] %@", level, msg);
    } else {
        NSLog(@"[AppToolkit] %@", msg);
    }
}
#endif

void ATKLog(NSString *format, ...)
{
#if DEBUG
    if (ATKLOG_ENABLED) {
        __block va_list arg_list;
        va_start (arg_list, format);
        ATKLogFormat(nil, format, arg_list);
        va_end(arg_list);
    }
#endif
}

void ATKLogWarning(NSString *format, ...)
{
#if DEBUG
    if (ATKLOG_ENABLED) {
        __block va_list arg_list;
        va_start (arg_list, format);
        ATKLogFormat(@"warn", format, arg_list);
        va_end(arg_list);
    }
#endif
}

void ATKLogError(NSString *format, ...)
{
#if DEBUG
    __block va_list arg_list;
    va_start (arg_list, format);
    ATKLogFormat(@"error", format, arg_list);
    va_end(arg_list);
#endif
}
