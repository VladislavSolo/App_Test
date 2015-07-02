//
//  VSPersistencyManager.h
//  App_Task
//
//  Created by Владислав Станишевский on 7/2/15.
//  Copyright (c) 2015 Vlad Stanishevskij. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MagicalRecord/MagicalRecord.h>

@class VSCitation;

@interface VSPersistencyManager : NSObject

//Core Data manager
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (VSPersistencyManager *)sharedManager;
- (void)setCitationURLToData:(NSString *)url;
- (VSCitation *)getCitationFromDataWithOffset:(NSUInteger)offset;

@end
