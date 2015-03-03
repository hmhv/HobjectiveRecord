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
#import "NSPersistentStoreCoordinator+HobjectiveRecord.h"

@implementation NSManagedObjectContext (HobjectiveRecord)

+ (instancetype)defaultContext
{
    static NSManagedObjectContext *s_defaultContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_defaultContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        s_defaultContext.persistentStoreCoordinator = [NSPersistentStoreCoordinator createStoreCoordinatorWithModelURL:nil storeURL:nil useInMemoryStore:NO];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:UIApplicationDidEnterBackgroundNotification object:nil];
    });
    return s_defaultContext;
}

+ (void)save
{
    [[self defaultContext] performBlock:^{
        [[self defaultContext] save];
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

- (instancetype)createChildContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = self;
    return context;
}

- (instancetype)createChildContextForMainQueue
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    context.parentContext = self;
    return context;
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

// Do not use if you don't know what you do.
+ (instancetype)createContextWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL useInMemoryStore:(BOOL)useInMemoryStore
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = [NSPersistentStoreCoordinator createStoreCoordinatorWithModelURL:modelURL storeURL:storeURL useInMemoryStore:useInMemoryStore];
    return context;
}

// Do not use if you don't know what you do.
+ (instancetype)createContextForMainQueueWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL useInMemoryStore:(BOOL)useInMemoryStore
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    context.persistentStoreCoordinator = [NSPersistentStoreCoordinator createStoreCoordinatorWithModelURL:modelURL storeURL:storeURL useInMemoryStore:useInMemoryStore];
    return context;
}

@end

