//
//  VSHTTPManager.m
//  App_Task
//
//  Created by Владислав Станишевский on 7/1/15.
//  Copyright (c) 2015 Vlad Stanishevskij. All rights reserved.
//

#import "VSHTTPManager.h"
#import "VSCitation.h"
#import "VSPersistencyManager.h"
#import <AFNetworking/AFNetworking.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface VSHTTPManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;

@end

@implementation VSHTTPManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSURL* baseURL = [NSURL URLWithString:@"http://api.forismatic.com/api/1.0/method=getQuote"];
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        [self.requestOperationManager.requestSerializer setCachePolicy:(NSURLRequestReloadIgnoringLocalCacheData)];
    }
    return self;
}

- (void)getRandomCitationOnSuccess:(void(^)(VSCitation* citation))succeess onFailure:(void(^)(NSError* error))failure {
    
    int key = arc4random() % 999999 + 111111;
    
    NSDictionary *params = @{@"method": @"getQuote",
                             @"format": @"json",
                             @"key"   : [[NSString alloc] initWithFormat:@"%d", key],
                             @"lang"  : @"ru"};
    
    [self.requestOperationManager GET:@"getQuote"
                           parameters:params
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  
                                  VSCitation* citation = [[VSCitation alloc] init];
                                  citation.citationText = [responseObject objectForKey:@"quoteText"];
                                  citation.citationAuthor = [responseObject objectForKey:@"quoteAuthor"];
                                  citation.citationLink = [responseObject objectForKey:@"quoteLink"];
                                  
                                  if (![[VSPersistencyManager sharedManager] isCitationInBlackList:citation] && succeess) {
                                      succeess(citation);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              
                                  NSLog(@"Error: %@", error);
                              }];
}

- (BOOL)isNetwork {
    
    NSURL *scriptUrl = [NSURL URLWithString:@"http://google.com"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (data)
        return YES;
    else
        return NO;
}

@end
