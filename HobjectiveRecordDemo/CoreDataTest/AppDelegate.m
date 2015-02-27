//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "HobjectiveRecord.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NSManagedObjectContext setupStore];
    
    // custom store setup example
    
    // for in-memory store
    // [NSManagedObjectContext setupStoreWithType:NSInMemoryStoreType modelURL:nil storeURL:nil];

    // for custom model url
    // NSURL *modelURL = ...;
    // [NSManagedObjectContext setupStoreWithType:nil modelURL:modelURL storeURL:nil];
    
    // for custom store url
    // NSURL *storeURL = ...;
    //[NSManagedObjectContext setupStoreWithType:nil modelURL:nil storeURL:storeURL];

    
    // your code here
    
    return YES;
}

@end
