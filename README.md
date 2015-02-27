# HobjectiveRecord

Hobjective Record is forked from [ObjectiveRecord](https://github.com/supermarin/ObjectiveRecord) and customized for using `NSManagedObjectContext` of ` NSPrivateQueueConcurrencyType` and `performBlock:`

I recommend you read this article [a-real-guide-to-core-data-concurrency](http://quellish.tumblr.com/post/97430076027/a-real-guide-to-core-data-concurrency).

#### Usage

1. copy all files in folder `HobjectiveRecord` to your project.<br>
   or Install with [CocoaPods](http://cocoapods.org) `pod 'HobjectiveRecord'`
2. `#import "HobjectiveRecord.h"` in your code or .pch file.

#### Initialize

``` objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // before you use CoreData
    [NSManagedObjectContext setupStore];
    
    // your code here
    
    return YES;
}
@end
```

#### Create / Save / Delete

``` objc
[[NSManagedObjectContext defaultMoc] performBlock:^{
    Person *john = [Person create];
    john.name = @"John";
    [john save];
    [john delete];
    
    [Person create:@{
                     @"name" : @"John",
                     @"age" : @12, 
                     @"member" : @NO 
                     }];
}];
```

#### Finders

``` objc
[[NSManagedObjectContext defaultMoc] performBlock:^{
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
```

#### Order and Limit

``` objc
[[NSManagedObjectContext defaultMoc] performBlock:^{
    // People by their last name ascending
    NSArray *sortedPeople = [Person allWithOrder:@"surname"];
    
    // People named John by their last name Z to A
    NSArray *reversedPeople = [Person where:@{@"name" : @"John"}
                                      order:@{@"surname" : @"DESC"}];
    
    // You can use NSSortDescriptor too
    NSArray *people = [Person allWithOrder:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    // And multiple orderings with any of the above
    NSArray *morePeople = [Person allWithOrder:@"surname ASC, name DESC"];
    
    // Just the first 5 people named John sorted by last name
    NSArray *fivePeople = [Person where:@"name == 'John'"
                                  order:@{@"surname" : @"ASC"}
                                  limit:@(5)];
}];
```

#### Aggregation

``` objc
[[NSManagedObjectContext defaultMoc] performBlock:^{
    // count all Person entities
    NSUInteger personCount = [Person count];
    
    // count people named John
    NSUInteger johnCount = [Person countWhere:@"name == 'John'"];
}];
```

#### Custom ManagedObjectContext

``` objc
NSManagedObjectContext *childContext = [[NSManagedObjectContext defaultMoc] createChildMocForPrivateQueue];

[childContext performBlock:^{
    Person *john = [Person createInContext:childContext];
    Person *john = [Person find:@"name == 'John'" inContext:childContext];
    NSArray *people = [Person allInContext:childContext];
}];
```

#### Custom CoreData model or .sqlite database
If you've added the Core Data manually, you can change the custom model and database name.

``` objc
NSURL *modelURL = ...;
[NSManagedObjectContext setupStoreWithType:nil modelURL:modelURL storeURL:nil];
    
// or
NSURL *storeURL = ...;
[NSManagedObjectContext setupStoreWithType:nil modelURL:nil storeURL:storeURL];
```



#### Mapping

The most of the time, your JSON web service returns keys like `first_name`, `last_name`, etc. <br/>
Your ObjC implementation has camelCased properties - `firstName`, `lastName`.<br/>

camel case is supported automatically - you don't have to do anything! Otherwise, if you have more complex mapping, here's how you do it:

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
```

#### Testing

HobjectiveRecord supports CoreData's in-memory store. In any place, before your tests start running, it's enough to call

``` objc
[NSManagedObjectContext setupStoreWithType:NSInMemoryStoreType modelURL:nil storeURL:nil];
```


## License

HobjectiveRecord is available under the MIT license. See the LICENSE file
for more information.
