//
//  ViewController.m
//

@import Social;
@import Accounts;

#import "ViewController.h"
#import "TweetViewController.h"
#import "HobjectiveRecord.h"
#import "Tweet.h"
#import "User.h"
#import "User+Mappings.h"

@interface ViewController ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *twitterAccount;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.accountStore = [[ACAccountStore alloc]init];
    
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.accountStore requestAccessToAccountsWithType:twitterAccountType
                                               options:NULL
                                            completion:^(BOOL granted, NSError *error) {
                                                if (granted) {
                                                    NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                                                    self.twitterAccount = [twitterAccounts firstObject];
                                                }
                                                else {
                                                    NSLog(@"%@", [error localizedDescription]);
                                                }
                                            }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"TweetSegue"]) {
        TweetViewController *vc = [segue destinationViewController];
        vc.twitterAccount = self.twitterAccount;
    }
    else if ([[segue identifier] isEqualToString:@"Tweet3LayerSegue"]) {
        TweetViewController *vc = [segue destinationViewController];
        vc.twitterAccount = self.twitterAccount;
        vc.use3Layer = YES;
    }
}

- (IBAction)removeAllData:(id)sender
{
    NSManagedObjectContext *moc = [NSManagedObjectContext defaultContext];
    
    [moc performBlock:^{
        NSLog(@"Before Delete %ld tweets of %ld users", (unsigned long)[Tweet count], (unsigned long)[User count]);
        
        [Tweet deleteAll];
        [User deleteAll];
        [moc save];

        NSLog(@"After Delete %ld tweets of %ld users", (unsigned long)[Tweet count], (unsigned long)[User count]);
    }];
}

- (IBAction)test:(id)sender
{
//    [[NSManagedObjectContext defaultContext] performBlock:^{
//        Tweet *tweet = [Tweet create];
//        tweet.text = @"I am here";
//        [tweet save];
//        [tweet delete];
//        
//        tweet = [Tweet create:@{@"text" : @"hello!!",
//                                @"lang" : @"en"
//                                }];
//        [tweet saveToParent];
//        
//        [Tweet deleteAll];
//    }];
    
//    [[NSManagedObjectContext defaultContext] performBlock:^{
//        NSArray *tweets = [Tweet all];
//        
//        NSArray *tweetsInEnglish = [Tweet find:@"lang == 'en'"];
//        
//        User *hmhv = [User first:@"screenName == 'hmhv'"];
//        
//        NSArray *englishMen = [User find:@{@"lang" : @"en",
//                                           @"timeZone" : @"London"
//                                           }];
//        
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"friendsCount > 100"];
//        NSArray *manyFriendsUsers = [User find:predicate];
//    }];

//    [[NSManagedObjectContext defaultContext] performBlock:^{
//        NSArray *sortedUsers = [User allWithOrder:@"name"];
//        
//        NSArray *allUsers = [User allWithOrder:@"screenName ASC, name DESC"];
//        // or
//        NSArray *allUsers2 = [User allWithOrder:@"screenName A, name D"];
//        // or
//        NSArray *allUsers3 = [User allWithOrder:@"screenName, name d"];
//
//        NSArray *manyFriendsUsers = [User find:@"friendsCount > 100" order:@"screenName DESC"];
//        
//        NSArray *fiveEnglishUsers = [User find:@"lang == 'en'" order:@"screenName ASC" limit:@(5)];
//    }];

//    [[NSManagedObjectContext defaultContext] performBlock:^{
//        NSUInteger allUserCount = [User count];
//        
//        NSUInteger englishUserCount = [User countWithCondition:@"lang == 'en'"];
//    }];

//    [[NSManagedObjectContext defaultContext] performBlock:^{
//        
//        [User batchUpdateWithCondition:@"friendsCount > 10" propertiesToUpdate:@{@"friendsCount": @0}];
//        
//        // update all entities
//        [User batchUpdateWithCondition:nil propertiesToUpdate:@{@"friendsCount": @100}];
//    }];
    
//    [[NSManagedObjectContext defaultContext] performBlock:^{
//        NSFetchedResultsController *frc = [User createFetchedResultsControllerWithCondition:nil order:@"name" sectionNameKeyPath:nil];
//        frc.delegate = self;
//        
//        NSError *error = nil;
//        if ([frc performFetch:&error]) {
//            [self reloadData];
//        }
//    }

//    NSManagedObjectContext *childContext = [[NSManagedObjectContext defaultContext] createChildContext];
//    
//    [childContext performBlock:^{
//        User *john = [User createInContext:childContext];
//        john.name = @"John";
//        [john save];
//        
//        john = [User first:@"name == 'John'" inContext:childContext];
//        
//        NSArray *manyFriendsUsers = [User find:@"friendsCount > 100" order:@"screenName DESC" inContext:childContext];
//        
//        NSArray *allUsers = [User allInContext:childContext];
//    }];

}

@end



