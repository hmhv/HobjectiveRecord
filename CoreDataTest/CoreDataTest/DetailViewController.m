//
//  DetailViewController.m
//

#import "DetailViewController.h"

#import "HobjectiveRecord.h"
#import "Tweet.h"
#import "User.h"

#define USE_MAIN_QUEUE 0

@interface DetailViewController ()

@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) Tweet *tweet;
@property (weak, nonatomic) IBOutlet UITextField *screenNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if USE_MAIN_QUEUE
    self.moc = [[NSManagedObjectContext defaultMoc] createChildMocForMainQueue];
    
    if (self.objectId) {
        self.tweet = (Tweet *)[self.moc objectWithID:self.objectId];
    }
    else {
        self.tweet = [Tweet createInContext:self.moc];
        self.tweet.idStr = [NSString stringWithFormat:@"%u", arc4random()];
        self.tweet.user = [User createInContext:self.moc];
        self.tweet.user.idStr = [NSString stringWithFormat:@"%u", arc4random()];
    }
    
    self.screenNameTextField.text = self.tweet.user.screenName;
    self.tweetTextView.text = self.tweet.text;
#else
    self.moc = [[NSManagedObjectContext defaultMoc] createChildMocForPrivateQueue];

    [self.moc performBlock:^{
        if (self.objectId) {
            self.tweet = (Tweet *)[self.moc objectWithID:self.objectId];
        }
        else {
            self.tweet = [Tweet createInContext:self.moc];
            self.tweet.idStr = [NSString stringWithFormat:@"%u", arc4random()];
            self.tweet.user = [User createInContext:self.moc];
            self.tweet.user.idStr = [NSString stringWithFormat:@"%u", arc4random()];
        }
        
        NSString *screenName = self.tweet.user.screenName;
        NSString *tweetText = self.tweet.text;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.screenNameTextField.text = screenName;
            self.tweetTextView.text = tweetText;
        });
    }];
#endif
}

- (IBAction)saveData:(id)sender
{
#if USE_MAIN_QUEUE
    self.tweet.user.screenName = self.screenNameTextField.text;
    self.tweet.text = self.tweetTextView.text;
    
    [self.moc save];
    
    if ([self.delegate respondsToSelector:@selector(detailViewControllerFinished:)]) {
        [self.delegate detailViewControllerFinished:self];
    }
#else
    NSString *screenName = self.screenNameTextField.text;
    NSString *tweetText = self.tweetTextView.text;

    [self.moc performBlock:^{
        self.tweet.user.screenName = screenName;
        self.tweet.text = tweetText;
        
        [self.moc save];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(detailViewControllerFinished:)]) {
                [self.delegate detailViewControllerFinished:self];
            }
        });
    }];
#endif
}

@end
