//
//  NSPersistentStoreCoordinator+HobjectiveRecord.m
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

#import "NSPersistentStoreCoordinator+HobjectiveRecord.h"
#import "NSURL+HobjectiveRecord.h"

NSString * const HRPersistentStoreCoordinatorWillMigratePersistentStore = @"HRPersistentStoreCoordinatorWillMigratePersistentStore";
NSString * const HRPersistentStoreCoordinatorDidMigratePersistentStore = @"HRPersistentStoreCoordinatorDidMigratePersistentStore";

@implementation NSPersistentStoreCoordinator (HobjectiveRecord)

+ (instancetype)setupDefaultStore
{
    return [self setupDefaultStoreWithModelURL:nil storeURL:nil useInMemoryStore:NO];
}

+ (instancetype)setupDefaultStoreWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL useInMemoryStore:(BOOL)useInMemoryStore
{
    static NSPersistentStoreCoordinator *s_defaultCStoreCoordinator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_defaultCStoreCoordinator = [self createStoreCoordinatorWithModelURL:modelURL storeURL:storeURL useInMemoryStore:useInMemoryStore];
    });
    return s_defaultCStoreCoordinator;
}

+ (instancetype)createStoreCoordinatorWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL useInMemoryStore:(BOOL)useInMemoryStore
{
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:(modelURL ?: [NSURL defaultModelURL])];
    
    NSPersistentStoreCoordinator *storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSError *error = nil;
    NSPersistentStore *store = [storeCoordinator addPersistentStoreWithType:(useInMemoryStore ? NSInMemoryStoreType : NSSQLiteStoreType)
                                                              configuration:nil
                                                                        URL:(storeURL ?: [NSURL defaultStoreURL])
                                                                    options:nil error:&error];
    if (store == nil) {
        NSLog(@"ERROR WHILE CREATING PERSISTENT STORE %@", error);
        
        if (error.code == NSPersistentStoreIncompatibleVersionHashError) {
            [[NSNotificationCenter defaultCenter] postNotificationName:HRPersistentStoreCoordinatorWillMigratePersistentStore object:nil];
            
            NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES};
            
            store = [storeCoordinator addPersistentStoreWithType:(useInMemoryStore ? NSInMemoryStoreType : NSSQLiteStoreType)
                                                   configuration:nil
                                                             URL:(storeURL ?: [NSURL defaultStoreURL])
                                                         options:options error:&error];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:HRPersistentStoreCoordinatorDidMigratePersistentStore object:nil];
            
            if (store == nil) {
                NSLog(@"ERROR WHILE MIGRATING PERSISTENT STORE %@", error);
            }
        }
    }
    
    return storeCoordinator;
}
@end
