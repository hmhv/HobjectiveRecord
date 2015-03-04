# HobjectiveRecord

[![Join the chat at https://gitter.im/hmhv/HobjectiveRecord](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/hmhv/HobjectiveRecord?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

HobjectiveRecord is inspired by [ObjectiveRecord](https://github.com/supermarin/ObjectiveRecord) and customized for background operation, 
to use `NSManagedObjectContext` of `NSPrivateQueueConcurrencyType` and `performBlock:`

Before you use, i recommend you read this article [a-real-guide-to-core-data-concurrency](http://quellish.tumblr.com/post/97430076027/a-real-guide-to-core-data-concurrency).

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
@end
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
    Person *john = [Person create];
    john.name = @"John";
    [john save];
    [john delete];
    
    [Person create:@{@"name" : @"John",
                     @"age" : @12, 
                     @"member" : @NO 
                     }];
}];

/*
+ (instancetype)create;
+ (instancetype)create:(NSDictionary *)attributes;
+ (void)deleteAll;
- (void)save;
- (void)saveToStore;
- (void)delete;
*/
```

#### Finders

``` objc
[[NSManagedObjectContext defaultContext] performBlock:^{
    // all Person entities from the database
    NSArray *people = [Person all];
    
    // Person entities with name John
    NSArray *johns = [Person where:@"name == 'John'"];
    
    // And of course, John Doe!
    Person *johnDoe = [Person find:@"name == 'John' AND surname == 'Doe'"];
    
    // Members over 18 from NY
    NSArray *people = [Person where:@{
                                      @"age" : @18,
                                      @"member" : @YES,
                                      @"state" : @"NY"
                                      }];
    
    // You can even write your own NSPredicate
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(name like[cd] %@) AND (birthday > %@)",
                              name, birthday];
    NSArray *results = [Person where:predicate];
}];
/*
+ (NSArray *)all;
+ (NSArray *)where:(id)condition;
+ (instancetype)find:(id)condition;
+ (instancetype)findOrCreate:(NSDictionary *)condition;
*/
```

#### Order and Limit

``` objc
[[NSManagedObjectContext defaultContext] performBlock:^{
    // People by their last name ascending
    NSArray *sortedPeople = [Person allWithOrder:@"surname"];
    
    // People named John by their last name Z to A
    NSArray *reversedPeople = [Person where:@{@"name" : @"John"}
                                      order:@"surname DESC"];
    
    // You can use NSSortDescriptor too
    NSArray *people = [Person allWithOrder:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    // And multiple orderings with any of the above
    NSArray *morePeople = [Person allWithOrder:@"surname ASC, name DESC"];
    // or
    //NSArray *morePeople = [Person allWithOrder:@"surname A, name D"];
    // or
    //NSArray *morePeople = [Person allWithOrder:@"surname, name d"];
    
    // Just the first 5 people named John sorted by last name
    NSArray *fivePeople = [Person where:@"name == 'John'"
                                  order:@"surname ASC"
                                  limit:@(5)];
}];
/*
+ (NSArray *)allWithOrder:(NSString *)order;
+ (NSArray *)where:(id)condition order:(NSString *)order;
+ (NSArray *)where:(id)condition limit:(NSNumber *)limit;
+ (NSArray *)where:(id)condition order:(NSString *)order limit:(NSNumber *)limit;
*/
```

#### Aggregation

``` objc
[[NSManagedObjectContext defaultContext] performBlock:^{
    // count all Person entities
    NSUInteger personCount = [Person count];
    
    // count people named John
    NSUInteger johnCount = [Person countWhere:@"name == 'John'"];
}];
/*
+ (NSUInteger)count;
+ (NSUInteger)countWhere:(id)condition;
*/
```

#### NSFetchedResultsController

``` objc
[[NSManagedObjectContext defaultContext] performBlock:^{
	self.fetchedResertController = [Person createFetchedResultsControllerWithCondition:nil order:@"id" sectionNameKeyPath:nil];
	self.fetchedResertController.delegate = self;

	NSError *error = nil;
	if ([self.fetchedResertController performFetch:&error]) {
    	[self reloadData];
	}
}];
```

#### Custom ManagedObjectContext

``` objc
NSManagedObjectContext *childContext = [[NSManagedObjectContext defaultContext] createChildContext];

[childContext performBlock:^{
    Person *john = [Person createInContext:childContext];
    Person *john = [Person find:@"name == 'John'" inContext:childContext];
    NSArray *people = [Person allInContext:childContext];
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
