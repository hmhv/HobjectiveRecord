//
//  NSManagedObjectContext+HobjectiveRecord.m
//
// Copyright (c) 2015 hmhv <http://hmhv.info/>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
#import "NSManagedObjectContext+HobjectiveRecord.h"

NSString * const HRManagedObjectContextWillMigratePersistentStore = @"HRManagedObjectContextWillMigratePersistentStore";
NSString * const HRManagedObjectContextDidMigratePersistentStore = @"HRManagedObjectContextDidMigratePersistentStore";

static NSString *s_storeType = nil;
static NSURL *s_modelURL = nil;
static NSURL *s_storeURL = nil;

@implementation NSManagedObjectContext (HobjectiveRecord)

+ (instancetype)defaultMoc
{
    static NSManagedObjectContext *s_defaultContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_defaultContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        s_defaultContext.persistentStoreCoordinator = [self storeCoordinatorWithType:nil modelURL:nil storeURL:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:UIApplicationDidEnterBackgroundNotification object:nil];
    });
    return s_defaultContext;
}

+ (void)setupStore
{
    [self setupStoreWithType:nil modelURL:nil storeURL:nil];
}

+ (void)setupStoreWithType:(NSString *)storeType modelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self storeCoordinatorWithType:storeType modelURL:modelURL storeURL:storeURL];
    });
}

+ (NSPersistentStoreCoordinator *)storeCoordinatorWithType:(NSString *)storeType modelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL
{
    static NSPersistentStoreCoordinator *s_defaultCStoreCoordinator;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:(modelURL ?: [self defaultModelURL])];
        
        s_defaultCStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        
        NSError *error = nil;
        NSPersistentStore *store = [s_defaultCStoreCoordinator addPersistentStoreWithType:(storeType ?: NSSQLiteStoreType)
                                                                            configuration:nil
                                                                                      URL:(storeURL ?: [self defaultStoreURL])
                                                                                  options:nil error:&error];
        if (store == nil) {
            NSLog(@"ERROR WHILE CREATING PERSISTENT STORE %@", error);
            
            if (error.code == NSPersistentStoreIncompatibleVersionHashError) {
                [[NSNotificationCenter defaultCenter] postNotificationName:HRManagedObjectContextWillMigratePersistentStore object:nil];
                
                NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES};
                
                store = [s_defaultCStoreCoordinator addPersistentStoreWithType:(storeType ?: NSSQLiteStoreType)
                                                                 configuration:nil
                                                                           URL:(storeURL ?: [self defaultStoreURL])
                                                                       options:options error:&error];

                [[NSNotificationCenter defaultCenter] postNotificationName:HRManagedObjectContextDidMigratePersistentStore object:nil];
                
                if (store == nil) {
                    NSLog(@"ERROR WHILE MIGRATING PERSISTENT STORE %@", error);
                }
            }
        }
    });
    
    return s_defaultCStoreCoordinator;
}

+ (void)save
{
    [[self defaultMoc] performBlock:^{
        [[self defaultMoc] save];
    }];
}

- (void)save
{
    if ([self hasChanges]) {
        NSError *error = nil;
        BOOL saved = [self save:&error];
        if (saved == NO) {
            NSLog(@"ERROR WHILE SAVE %@", error);
        }
    }
}

- (void)saveToStore
{
    if ([self hasChanges]) {
        NSError *error = nil;
        BOOL saved = [self save:&error];
        if (saved == NO) {
            NSLog(@"ERROR WHILE SAVE %@", error);
        }
        else if (self.parentContext) {
            [self.parentContext performBlock:^{
                [self.parentContext saveToStore];
            }];
        }
    }
}

- (instancetype)createChildMocForPrivateQueue
{
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    managedObjectContext.parentContext = self;
    return managedObjectContext;
}

- (instancetype)createChildMocForMainQueue
{
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContext.parentContext = self;
    return managedObjectContext;
}

- (void)performBlockSynchronously:(void (^)())block
{
    if (block) {
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        [self performBlock:^{
            block();
            dispatch_group_leave(group);
        }];
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    }
}

+ (NSString *)appName
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
}

+ (NSURL *)defaultModelURL
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[self appName] withExtension:@"momd"];
    return modelURL;
}

+ (NSURL *)defaultStoreURL
{
    return [[self applicationDefaultDirectory] URLByAppendingPathComponent:[[self appName] stringByAppendingString:@".sqlite"]];
}

#if TARGET_OS_IPHONE
+ (NSURL *)applicationDefaultDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
#else
+ (NSURL *)applicationDefaultDirectory
{
    NSURL *url = [[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:[self appName]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.absoluteString] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return url;
}
#endif

@end
