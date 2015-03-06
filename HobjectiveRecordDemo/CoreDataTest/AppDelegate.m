//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "HobjectiveRecord.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([NSPersistentStoreCoordinator needMigration]) {
        NSLog(@"!! NEED Migration !!");
    }
    
    [NSPersistentStoreCoordinator setupDefaultStore];
    
    // your code here
    
    return YES;
}

@end
