//
//  ATKAPIClient.m
//  AppToolkit
//
//  Created by Cluster Labs, Inc. on 1/16/15.
//
//

#import "NSString+ATKURLEncoded.h"

@implementation NSString (ATKURLEncoded)

- (NSString*)atk_urlencoded
{
    static NSMutableCharacterSet *customURLCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *stringsToDefinitelyEncode = @":/?#[]@!$&’()*+,;=";
        customURLCharacterSet = [[NSMutableCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [customURLCharacterSet removeCharactersInString:stringsToDefinitelyEncode];
    });
    NSString *result = [self stringByAddingPercentEncodingWithAllowedCharacters:customURLCharacterSet];
    return result;
}

@end
