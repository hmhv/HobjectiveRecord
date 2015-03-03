//
//  NSManagedObject+HobjectiveRecord.h
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

#import <CoreData/CoreData.h>

@interface NSManagedObject (HobjectiveRecord)

#pragma mark - Instance Method

- (void)save;
- (void)saveToStore;
- (void)delete;

- (void)performBlock:(void (^)())block;
- (void)performBlockSynchronously:(void (^)())block;

#pragma mark - Creation / Deletion

+ (instancetype)create;
+ (instancetype)createInContext:(NSManagedObjectContext *)context;

+ (instancetype)create:(NSDictionary *)attributes;
+ (instancetype)create:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context;

+ (void)deleteAll;
+ (void)deleteAllInContext:(NSManagedObjectContext *)context;

#pragma mark - Finders

+ (NSArray *)all;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context;

+ (NSArray *)allWithOrder:(NSString *)order;
+ (NSArray *)allWithOrder:(NSString *)order inContext:(NSManagedObjectContext *)context;

+ (NSArray *)where:(id)condition;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context;

+ (NSArray *)where:(id)condition order:(NSString *)order;
+ (NSArray *)where:(id)condition order:(NSString *)order inContext:(NSManagedObjectContext *)context;

+ (NSArray *)where:(id)condition limit:(NSNumber *)limit;
+ (NSArray *)where:(id)condition limit:(NSNumber *)limit inContext:(NSManagedObjectContext *)context;

+ (NSArray *)where:(id)condition order:(NSString *)order limit:(NSNumber *)limit;
+ (NSArray *)where:(id)condition order:(NSString *)order limit:(NSNumber *)limit inContext:(NSManagedObjectContext *)context;

+ (instancetype)find:(id)condition;
+ (instancetype)find:(id)condition inContext:(NSManagedObjectContext *)context;

+ (instancetype)findOrCreate:(NSDictionary *)condition;
+ (instancetype)findOrCreate:(NSDictionary *)condition inContext:(NSManagedObjectContext *)context;

#pragma mark - Aggregation

+ (NSUInteger)count;
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context;

+ (NSUInteger)countWhere:(id)condition;
+ (NSUInteger)countWhere:(id)condition inContext:(NSManagedObjectContext *)context;

#pragma mark - FetchedResultsController

+ (NSFetchedResultsController *)createFetchedResultsControllerWithCondition:(id)condition order:(NSString *)order sectionNameKeyPath:(NSString *)sectionNameKeyPath;
+ (NSFetchedResultsController *)createFetchedResultsControllerWithCondition:(id)condition order:(NSString *)order sectionNameKeyPath:(NSString *)sectionNameKeyPath inContext:(NSManagedObjectContext *)context;

#pragma mark - Naming

+ (NSString *)entityName;

#pragma mark - Fetching

+ (BOOL)returnsObjectsAsFaults;
+ (NSArray *)relationshipKeyPathsForPrefetching;

#pragma mark - Mappings

+ (NSDictionary *)mappings;
+ (BOOL)useFindOrCreate;

@end
