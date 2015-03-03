//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "HobjectiveRecord.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NSPersistentStoreCoordinator setupDefaultStore];
    
    // your code here
    
    return YES;
}

@end
