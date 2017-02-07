//
//  ATKConfig.h
//  AppToolkit
//
//  Created by Rizwan Sattar on 8/21/15.
//
//

#import <Foundation/Foundation.h>

extern NSString *const __nonnull ATKConfigUpdatedNotificationName;
extern NSString *const __nonnull ATKConfigOldParametersKey;
extern NSString *const __nonnull ATKConfigNewParametersKey;

typedef void (^ATKConfigReadyHandler)();
typedef void (^ATKConfigRefreshHandler)(NSDictionary * __nonnull oldParameters, NSDictionary * __nonnull newParameters);

@class ATKConfig;
/**
 * ATKConfigDelegate is an internal implementation detail.
 */
@protocol ATKConfigDelegate <NSObject>

@optional
- (void) configIsReady:(nonnull ATKConfig *)config;
- (void) configWasRefreshed:(nonnull ATKConfig *)config;

@end


@interface ATKConfig : NSObject

/**
 * The parameters dictionary, directly accessible, if needed.
 */
@property (readonly, strong, nonatomic, nonnull) NSDictionary *parameters;


/**
 * An optional block you can pass in, which will get called on the very first
 * update to the configuration (whether or not the configuration is different
 * from the previous configuration). This is an easy place to do some "set once"
 * tasks for your app.
 */
@property (copy, nonatomic, nullable) ATKConfigReadyHandler readyHandler;
/**
 * Returns YES if config has been updated at least once this app session.
 * @see readyHandler
 */
@property (readonly, nonatomic) BOOL isReady;

/**
 * An optional block you can pass in, which will be called whenever the config has changed.
 * Additionally, it will be called the *first* time config is updated from the server, even if the
 * config values were the same as cached.
 */
@property (copy, nonatomic, nullable) ATKConfigRefreshHandler refreshHandler;

- (nonnull instancetype)initWithParameters:(nullable NSDictionary *)configParameters;

#pragma mark - Casted getters
- (BOOL) boolForKey:(NSString * __nonnull)key defaultValue:(BOOL)defaultValue;
- (NSInteger) integerForKey:(NSString * __nonnull)key defaultValue:(NSInteger)defaultValue;
- (double) doubleForKey:(NSString * __nonnull)key defaultValue:(double)defaultValue;
- (nullable NSString *) stringForKey:(NSString * __nonnull)key defaultValue:(nullable NSString *)defaultValue;

@end
