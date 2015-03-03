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


@end
