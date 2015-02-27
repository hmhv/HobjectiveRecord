//
//  Tweet.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * createdAt;
@property (nonatomic, retain) NSNumber * favoriteCount;
@property (nonatomic, retain) NSString * idStr;
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) NSNumber * retweetCount;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDecimalNumber * timestampMs;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) User *user;

@end
