//
//  ATKAPIClient.m
//  AppToolkit
//
//  Created by Cluster Labs, Inc. on 1/16/15.
//
//

#import "NSDictionary+ATKFormEncoded.h"


NSString *atk_EncodedValueForObject(NSObject *object) {
    if (![object isKindOfClass:[NSNull class]]) {
        return [[object description] atk_urlencoded];
    }
    return @"";
}


@implementation NSDictionary (ATKFormEncoded)


- (NSString*)atk_toFormEncodedString
{  
    NSMutableArray *array = [NSMutableArray array];
  
    for (NSObject *key in self) {
        NSObject *value = [self objectForKey:key];

        NSString *encodedKey = [[key description] atk_urlencoded];
        if ([value isKindOfClass:[NSArray class]]) {
            for (NSObject *multiValue in (NSArray*)value) {
                [array addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, atk_EncodedValueForObject(multiValue)]];
            }
        } else {
            [array addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, atk_EncodedValueForObject(value)]];
        }
    }

    return [array componentsJoinedByString:@"&"];
}


@end
