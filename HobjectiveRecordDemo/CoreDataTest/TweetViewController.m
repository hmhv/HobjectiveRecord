//
//  TweetViewController.m
//

#import "TweetViewController.h"
#import "HobjectiveRecord.h"
#import "TwitterStream.h"
#import "Tweet.h"
#import "User+Mappings.h"
#import "DetailViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"

//#define USE_WILL_DISPLAY_CELL

#define USE_PERFORM_BLOCK 1
#define USE_PERFORM_BLOCK_AND_WAIT 0
#define USE_PERFORM_BLOCK_SYNCHRONOUSLY 0

@interface TweetViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, DetailViewControllerDelegate>

@property (strong, nonatomic) TwitterStream *twitterStream;

@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSManagedObjectContext *workMoc;
@property (strong, nonatomic) NSManagedObjectID *selectedObjectId;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResertController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIButton *twitterStreamButton;

@end

@implementation TweetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.use3Layer) {
        self.moc = [[NSManagedObjectContext defaultContext] createChildContextForMainQueue];
    }
    else {
        self.moc = [NSManagedObjectContext defaultContext];
    }
    self.workMoc = [self.moc createChildContext];

    [self.indicator startAnimating];
    
    [self.moc performBlock:^{
        
        self.fetchedResertController = [Tweet createFetchedResultsControllerWithCondition:nil order:@"idStr" sectionNameKeyPath:nil inContext:self.moc];
        self.fetchedResertController.delegate = self;
        
        NSError *error = nil;
        if ([self.fetchedResertController performFetch:&error]) {
            [self reloadData];
        }
        else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopTwitterStream];
    [[SDWebImageManager sharedManager] cancelAll];
}

- (void)reloadData
{
    if (self.use3Layer) {
        [self.tableView reloadData];
        [self.indicator stopAnimating];
        self.navigationItem.title = [NSString stringWithFormat:@"%ld tweets", (unsigned long)[self.fetchedResertController.fetchedObjects count]];
        NSLog(@"reloadData : %@", self.navigationItem.title);
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.indicator stopAnimating];
            self.navigationItem.title = [NSString stringWithFormat:@"%ld tweets", (unsigned long)[self.fetchedResertController.fetchedObjects count]];
            NSLog(@"reloadData : %@", self.navigationItem.title);
        });
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"DetailSegue"]) {
        DetailViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        vc.objectId = self.selectedObjectId;
    }
}

- (IBAction)addTweet:(id)sender
{
    self.selectedObjectId = nil;
    [self performSegueWithIdentifier:@"DetailSegue" sender:self];
}

- (IBAction)addRandomTweet:(id)sender
{
    [self.moc performBlock:^{
        uint tweetCount = (arc4random() % 5) + 1;

        for (uint i = 0; i < tweetCount; i++) {
            [Tweet create:@{@"idStr" : [NSString stringWithFormat:@"%u", arc4random()],
                            @"text" : [NSString stringWithFormat:@"Text : %u", arc4random()],
                            @"" : @"",
                            @"" : @"",
                            @"user" : @{@"idStr" : [NSString stringWithFormat:@"%u", arc4random()],
                                        @"screenName" : [NSString stringWithFormat:@"S:%u", arc4random()]}
                            }];
        }
    }];
}

- (IBAction)switchTwitterStream:(id)sender
{
    if (self.twitterStream) {
        [self stopTwitterStream];
    }
    else {
        [self startTwitterStream];
    }
}

- (void)startTwitterStream
{
    if (self.twitterAccount) {
        self.twitterStream = [TwitterStream new];
        self.twitterStream.twitterAccount = self.twitterAccount;
        self.twitterStream.moc = self.workMoc;
        
        [self.twitterStream start];
        [self.twitterStreamButton setTitle:@"Stop Twitter Stream" forState:UIControlStateNormal];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Twitter Account Error!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)stopTwitterStream
{
    [self.twitterStream stop];
    self.twitterStream = nil;
    [self.twitterStreamButton setTitle:@"Start Twitter Stream" forState:UIControlStateNormal];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fetchedResertController.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }

#ifndef USE_WILL_DISPLAY_CELL

    [self configureCell:cell forRowAtIndexPath:indexPath];
    
#endif
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *t = [self.fetchedResertController objectAtIndexPath:indexPath];

    if (self.use3Layer) {
        
        UILabel *upper = (UILabel *)[cell viewWithTag:1];
        upper.text = [NSString stringWithFormat:@"%ld - %@", (long)indexPath.row, t.user.screenName];
        
        UILabel *lower = (UILabel *)[cell viewWithTag:2];
        lower.text = t.text;

        if ([t.user.profileImageUrl length] > 0) {
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:3];
            [imageView sd_setImageWithURL:[NSURL URLWithString:t.user.profileImageUrl]
                         placeholderImage:nil];
        }

        return;
    }

#if USE_PERFORM_BLOCK
    
    [t performBlock:^{
        NSString *screenName = [NSString stringWithFormat:@"%ld - %@", (long)indexPath.row, t.user.screenName];
        NSString *text = t.text;
        NSString *profileUrl = t.user.profileImageUrl;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UILabel *upper = (UILabel *)[cell viewWithTag:1];
            upper.text = screenName;
            
            UILabel *lower = (UILabel *)[cell viewWithTag:2];
            lower.text = text;
            
            if ([profileUrl length] > 0) {
                UIImageView *imageView = (UIImageView *)[cell viewWithTag:3];
                [imageView sd_setImageWithURL:[NSURL URLWithString:profileUrl]
                             placeholderImage:nil];
            }

        });
    }];
    
#elif USE_PERFORM_BLOCK_AND_WAIT
    
    __block NSString *screenName = nil;
    __block NSString *text = nil;
    __block NSString *profileUrl = nil;
    
    [t.managedObjectContext performBlockAndWait:^{
        screenName = [NSString stringWithFormat:@"%ld - %@", (long)indexPath.row, t.user.screenName];
        text = t.text;
        profileUrl = t.user.profileImageUrl;
    }];
    
    UILabel *upper = (UILabel *)[cell viewWithTag:1];
    upper.text = screenName;
    
    UILabel *lower = (UILabel *)[cell viewWithTag:2];
    lower.text = text;

    if ([profileUrl length] > 0) {
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:3];
        [imageView sd_setImageWithURL:[NSURL URLWithString:profileUrl]
                     placeholderImage:nil];
    }

#elif USE_PERFORM_BLOCK_SYNCHRONOUSLY

    __block NSString *screenName = nil;
    __block NSString *text = nil;
    __block NSString *profileUrl = nil;
    
    [t performBlockSynchronously:^{
        screenName = [NSString stringWithFormat:@"%ld - %@", (long)indexPath.row, t.user.screenName];
        text = t.text;
        profileUrl = t.user.profileImageUrl;
    }];
    
    UILabel *upper = (UILabel *)[cell viewWithTag:1];
    upper.text = screenName;
    
    UILabel *lower = (UILabel *)[cell viewWithTag:2];
    lower.text = text;

    if ([profileUrl length] > 0) {
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:3];
        [imageView sd_setImageWithURL:[NSURL URLWithString:profileUrl]
                     placeholderImage:nil];
    }

#endif
}

#ifdef USE_WILL_DISPLAY_CELL

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:cell forRowAtIndexPath:indexPath];
}

#endif

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Tweet *t = [self.fetchedResertController objectAtIndexPath:indexPath];
    self.selectedObjectId = t.objectID;
    [self performSegueWithIdentifier:@"DetailSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Tweet *t = [self.fetchedResertController objectAtIndexPath:indexPath];
        [t performBlock:^{
            if ([t.user.tweets count] == 1) {
                [t.user delete];
            }
            [t delete];
            [t save];
        }];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self reloadData];
}

- (void)detailViewControllerFinished:(id)sender
{
    [self reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
