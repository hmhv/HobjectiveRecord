//
//  TweetViewController.h
//

#import <UIKit/UIKit.h>
@import CoreData;

@class ACAccount;

@interface TweetViewController : UIViewController

@property (nonatomic, strong) ACAccount *twitterAccount;
@property (nonatomic, assign) BOOL use3Layer;

@end
