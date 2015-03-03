//
//  TwitterStream.h
//

#import <Foundation/Foundation.h>

@class ACAccount;
@class NSManagedObjectContext;

@interface TwitterStream : NSObject

@property (nonatomic, strong) ACAccount *twitterAccount;
@property (nonatomic, weak) NSManagedObjectContext *moc;

- (void)start;
- (void)stop;

@end
