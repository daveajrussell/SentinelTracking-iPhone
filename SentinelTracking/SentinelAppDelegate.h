//
//  SentinelAppDelegate.h
//  SentinelTracking
//
//  Created by David Russell on 20/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SentinelAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
