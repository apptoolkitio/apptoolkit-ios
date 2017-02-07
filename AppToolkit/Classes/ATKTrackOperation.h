//
//  ATKTrackOperation.h
//  AppToolkit
//
//  Created by Rizwan Sattar on 12/8/15.
//
//

#import <Foundation/Foundation.h>

#import "ATKAPIClient.h"

@interface ATKTrackOperation : NSOperation

@property (readonly, nonatomic, nullable) NSDictionary *properties;
@property (readonly, nonatomic, nullable) NSDictionary *response;
@property (readonly, nonatomic, nullable) NSError *error;

- (nonnull instancetype)initWithAPIClient:(nonnull ATKAPIClient *)apiClient propertiesToTrack:(nullable NSDictionary *)properties;

@end
