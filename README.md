# HobjectiveRecord

[![HobjectiveRecord version](https://img.shields.io/cocoapods/v/HobjectiveRecord.svg?style=plastic)](http://cocoadocs.org/docsets/HobjectiveRecord)[![HobjectiveRecord platform](https://img.shields.io/cocoapods/p/HobjectiveRecord.svg?style=plastic)](http://cocoadocs.org/docsets/HobjectiveRecord)[![HobjectiveRecord license](https://img.shields.io/cocoapods/l/HobjectiveRecord.svg?style=plastic)](http://opensource.org/licenses/MIT)[![Join the chat at https://gitter.im/hmhv/HobjectiveRecord](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/hmhv/HobjectiveRecord?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


HobjectiveRecord is inspired by [ObjectiveRecord](https://github.com/supermarin/ObjectiveRecord) and customized for background `NSManagedObjectContext`.

Before you use, i recommend you read these articles

- [a-real-guide-to-core-data-concurrency](http://quellish.tumblr.com/post/97430076027/a-real-guide-to-core-data-concurrency).
- [Multi-Context CoreData](http://www.cocoanetics.com/2012/07/multi-context-coredata/).

> You can use HobjectiveRecord with swift. check HobjectiveRecordDemo-Swift.
> or use [SobjectiveRecord](https://github.com/hmhv/SobjectiveRecord) written in swift


#### Usage

1. copy all files in folder `HobjectiveRecord` to your project.<br>
   or Install with [CocoaPods](http://cocoapods.org) `pod 'HobjectiveRecord'`
2. `#import "HobjectiveRecord.h"` in your code or .pch file.

#### Initialize

``` objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // before you use CoreData stack, you should setup default store.
    [NSPersistentStoreCoordinator setupDefaultStore];
    
    // your code here
    
    return YES;
}
/*
+ (void)setupDefaultStore;
+ (void)setupDefaultStoreWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL useInMemoryStore:(BOOL)useInMemoryStore;
*/
```

### Basic

use `performBlock:`

``` objc
[[NSManagedObjectContext defaultContext] performBlock:^{
  // your code here
}];

NSManagedObjectContext *childContext = [[NSManagedObjectContext defaultContext] createChildContext];
[childContext performBlock:^{
  // your code here
}];
```


#### Create / Save / Delete

``` objc
[[NSManagedObjectContext defaultContext] performBlock:^{
    Tweet *tweet = [Tweet create];
    tweet.text = @"I am here";
    [tweet save];
    [tweet delete];
    
    tweet = [Tweet create:@{@"text" : @"hello!!",
                            @"lang" : @"en"} ];
    [tweet saveToStore];
    
    [Tweet deleteAll];
}];
/*
+ (instancetype)create;
+ (instancetype)create:(NSDictionary *)attributes;
+ (void)deleteAll;
+ (void)deleteWithCondition:(id)condition;
- (void)save;
- (void)saveToStore;
- (void)delete;
*/
```

#### Finders

``` objc
[[NSManagedObjectContext defaultContext] performBlock:^{
    NSArray *tweets = [Tweet all];
    
    NSArray *tweetsInEnglish = [Tweet find:@"lang == 'en'"];
    
    User *hmhv = [User first:@"screenName == 'hmhv'"];
    
    NSArray *englishMen = [User find:@{@"lang" : @"en",
                                       @"timeZone" : @"London"
                                       }];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"friendsCount > 100"];
    NSArray *manyFriendsUsers = [User find:predicate];
}];
/*
+ (NSArray *)all;
+ (NSArray *)find:(id)condition;
+ (instancetype)first:(id)condition;
+ (instancetype)firstOrCreate:(NSDictionary *)condition;
*/
```

#### Order and Limit

``` objc
[[NSManagedObjectContext defaultContext] performBlock:^{
    NSArray *sortedUsers = [User allWithOrder:@"name"];
    
    NSArray *allUsers = [User allWithOrder:@"screenName ASC, name DESC"];
    // or
    NSArray *allUsers2 = [User allWithOrder:@"screenName A, name D"];
    // or
    NSArray *allUsers3 = [User allWithOrder:@"screenName, name d"];

    NSArray *manyFriendsUsers = [User find:@"friendsCount > 100" order:@"screenName DESC"];
    
    NSArray *fiveEnglishUsers = [User find:@"lang == 'en'" order:@"screenName ASC" limit:@(5)];
}];
/*
+ (NSArray *)allWithOrder:(NSString *)order;
+ (NSArray *)find:(id)condition order:(NSString *)order;
+ (NSArray *)find:(id)condition limit:(NSNumber *)limit;
+ (NSArray *)find:(id)condition order:(NSString *)order limit:(NSNumber *)limit;
*/
```

#### Aggregation

``` objc
[[NSManagedObjectContext defaultContext] performBlock:^{
    NSUInteger allUserCount = [User count];
    
    NSUInteger englishUserCount = [User countWithCondition:@"lang == 'en'"];
}];
/*
+ (NSUInteger)count;
+ (NSUInteger)countWithCondition:(id)condition;
*/
```

#### NSFetchedResultsController

``` objc
    [[NSManagedObjectContext defaultContext] performBlock:^{
        NSFetchedResultsController *frc = [User createFetchedResultsControllerWithCondition:nil order:@"name" sectionNameKeyPath:nil];
        frc.delegate = self;
        
        NSError *error = nil;
        if ([frc performFetch:&error]) {
            [self reloadData];
        }
    }
}];
/*
+ (NSFetchedResultsController *)createFetchedResultsControllerWithCondition:(id)condition order:(NSString *)order sectionNameKeyPath:(NSString *)sectionNameKeyPath;
*/
```

#### Custom ManagedObjectContext

``` objc
NSManagedObjectContext *childContext = [[NSManagedObjectContext defaultContext] createChildContext];

[childContext performBlock:^{
    User *john = [User createInContext:childContext];
    john.name = @"John";
    [john save];
    
    john = [User first:@"name == 'John'" inContext:childContext];
    
    NSArray *manyFriendsUsers = [User find:@"friendsCount > 100" order:@"screenName DESC" inContext:childContext];
    
    NSArray *allUsers = [User allInContext:childContext];
}];
```

#### Custom CoreData model or .sqlite database

If you've added the Core Data manually, you can change the custom model and database name.

``` objc
NSURL *modelURL = [NSURL defaultModelURL:@"model_name"];
[NSPersistentStoreCoordinator setupDefaultStoreWithModelURL:modelURL storeURL:nil useInMemoryStore:NO];
    
// or
NSURL *storeURL = [NSURL defaultStoreURL:@"file_name.sqlite"];
[NSPersistentStoreCoordinator setupDefaultStoreWithModelURL:nil storeURL:storeURL useInMemoryStore:NO];
```



#### Mapping

The most of the time, your JSON web service returns keys like `first_name`, `last_name`, etc. <br/>
Your ObjC implementation has camelCased properties - `firstName`, `lastName`.<br/>

camel case is supported automatically - you don't have to do anything! Otherwise, if you have more complex mapping, here's how you do it:

**!! Date, Transformable Types are not supported !!**

``` objc
// just override +mappings in your NSManagedObject subclass
#import "User+Mappings.h"

@implementation User (Mappings)

+ (NSDictionary *)mappings
{
    return @{@"description" : @"userDescription",
             @"name" : @"fullName"};
}
  // first_name => firstName is automatically handled

@end
/*
+ (NSDictionary *)mappings
+ (BOOL)useFindOrCreate
+ (BOOL)returnsObjectsAsFaults
+ (NSArray *)relationshipKeyPathsForPrefetching
*/
```

#### Testing

HobjectiveRecord supports CoreData's in-memory store. In any place, before your tests start running, it's enough to call

``` objc
[NSPersistentStoreCoordinator setupDefaultStoreWithModelURL:nil storeURL:nil useInMemoryStore:YES];
```


## License

HobjectiveRecord is available under the MIT license. See the LICENSE file
for more information.
