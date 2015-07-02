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
#import <AFNetworking/AFHTTPRequestOperationManager.h>

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
    }
    return self;
}

- (void)getRandomCitationOnSuccess:(void(^)(VSCitation* citation))succeess onFailure:(void(^)(NSError* error))failure {
    
    NSDictionary *params = @{@"method": @"getQuote",
                             @"format": @"json",
                             @"key"   : @"",
                             @"lang"  : @"ru"};
    
    [self.requestOperationManager POST:@"getQuote"
                           parameters:params
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  
                                  VSCitation* citation = [[VSCitation alloc] init];
                                  citation.citationText = [responseObject objectForKey:@"quoteText"];
                                  citation.citationAuthor = [responseObject objectForKey:@"quoteAuthor"];
                                  citation.citationLink = [responseObject objectForKey:@"quoteLink"];
                                  
                                  if (succeess) {
                                      succeess(citation);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              
                                  NSLog(@"Error: %@", error);
                              }];
}

@end
