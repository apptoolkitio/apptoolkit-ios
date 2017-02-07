//
//  ATKBundleInfo.h
//  AppToolkit
//
//  Created by Rizwan Sattar on 7/24/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ATKResourceVersion) {
    ATKResourceVersionInvalid,
    ATKResourceVersionNewest,
    ATKResourceVersionLocalCache,
    ATKResourceVersionPrepackaged,
};

@interface ATKBundleInfo : NSObject <NSCoding, NSCopying>

@property (readonly, nonatomic) NSDate *createTime;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSURL *url;
@property (readonly, nonatomic) NSString *version;

// Locally synthesized version
@property (readonly, nonatomic) ATKResourceVersion resourceVersion;

- (instancetype) initWithAPIDictionary:(NSDictionary *)dictionary;
- (instancetype) initWithName:(NSString *)name
                      version:(NSString *)version
                          url:(NSURL *)url
                   createTime:(NSDate *)date
              resourceVersion:(ATKResourceVersion)resourceVersion;

@end
