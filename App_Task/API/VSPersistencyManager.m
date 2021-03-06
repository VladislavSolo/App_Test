//
//  VSPersistencyManager.m
//  App_Task
//
//  Created by Владислав Станишевский on 7/2/15.
//  Copyright (c) 2015 Vlad Stanishevskij. All rights reserved.
//

#import "VSPersistencyManager.h"
#import "VSCitationData.h"
#import "VSCitation.h"

@implementation VSPersistencyManager

+ (VSPersistencyManager *)sharedManager {
    
    static VSPersistencyManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[VSPersistencyManager alloc] init];
        
    });
    return _sharedInstance;
}

#pragma mark - Set to Data

- (void)setCitationToData:(VSCitation *)citation {
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"VSCitationData"
                                                   inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"citationURL = %@", citation.citationLink];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:description];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    
    if ([resultArray count] == 0 && citation != nil) {
        
        VSCitationData* citationData = [NSEntityDescription insertNewObjectForEntityForName:@"VSCitationData"
                                                                     inManagedObjectContext:self.managedObjectContext];
        
        citationData.isFavourite = YES;
        citationData.citationText = citation.citationText;
        citationData.citationAuthor = citation.citationAuthor;
        citationData.citationURL = citation.citationLink;
        
        [self saveContext];
    }
}

- (void)setCitationToBlackList:(VSCitation *)citation {
    
    VSCitationData* citationData = [NSEntityDescription insertNewObjectForEntityForName:@"VSCitationData"
                                                                 inManagedObjectContext:self.managedObjectContext];
    citationData.isFavourite = NO;
    citationData.citationURL = citation.citationLink;
    
    [self saveContext];
}

#pragma mark - Get from Data

- (VSCitation *)getCitationFromDataWithOffset:(NSUInteger)offset {
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"VSCitationData"
                                                   inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite = YES"];

    VSCitation* citation = [[VSCitation alloc] init];
    
    [fetchRequest setEntity:description];
    [fetchRequest setPredicate:predicate];
    fetchRequest.fetchOffset = offset;
    fetchRequest.fetchLimit = 1;
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    
    if (requestError) {
        
        NSLog(@"%@", [requestError localizedDescription]);
        return nil;
        
    } else {
        
        for (VSCitationData *citationData in resultArray) {
            
            citation.citationAuthor = citationData.citationAuthor;
            citation.citationText = citationData.citationText;
            citation.citationLink = citationData.citationURL;

        }
        return citation;
    }    
}

- (BOOL)isCitationInBlackList:(VSCitation *)citation {
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"VSCitationData"
                                                   inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *linkPredicate = [NSPredicate predicateWithFormat:@"citationURL = %@", citation.citationLink];
    NSPredicate *favoutitePredicate = [NSPredicate predicateWithFormat:@"isFavourite = %@", NO];
    NSPredicate * predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[linkPredicate, favoutitePredicate]];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:description];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    
    if (requestError) {
        
        NSLog(@"%@", [requestError localizedDescription]);
        return NO;
    } else if ([resultArray count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Core Data Stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving & Delete

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
