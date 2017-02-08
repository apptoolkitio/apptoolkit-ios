//
//  ATKLog.h
//  AppToolkit
//
//  Created by Rizwan Sattar on 1/20/15.
//
//

#import <Foundation/Foundation.h>

extern BOOL ATKLOG_ENABLED;

extern void ATKLog(NSString *format, ...);
extern void ATKLogWarning(NSString *format, ...);
extern void ATKLogError(NSString *format, ...);

/*
#ifdef APPTOOLKIT_DEBUG
#define ATKLog(...) ATKLogFormat(nil, __VA_ARGS__)
#else
#define ATKLog(...)
#endif


#ifdef APPTOOLKIT_WARN
#define ATKLogWarning(...) ATKLogFormat(@"warn", __VA_ARGS__)
#else
#define ATKLogWarning(...)
#endif


#ifdef APPTOOLKIT_ERROR
#define ATKLogError(...) ATKLogFormat(@"error", __VA_ARGS__)
#else
#define ATKLogError(...)
#endif

#endif
*/
