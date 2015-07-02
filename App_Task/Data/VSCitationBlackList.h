//
//  VSCitationBlackList.h
//  App_Task
//
//  Created by Владислав Станишевский on 7/2/15.
//  Copyright (c) 2015 Vlad Stanishevskij. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VSCitationBlackList : NSManagedObject

@property (nonatomic, retain) NSString * citationURL;

@end
