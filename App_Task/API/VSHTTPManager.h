//
//  VSHTTPManage.h
//  App_Task
//
//  Created by Владислав Станишевский on 7/2/15.
//  Copyright (c) 2015 Vlad Stanishevskij. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSCitation;

@interface VSHTTPManager : NSObject

- (void)getRandomCitationOnSuccess:(void(^)(VSCitation* citation))succeess onFailure:(void(^)(NSError* error))failure;

@end
