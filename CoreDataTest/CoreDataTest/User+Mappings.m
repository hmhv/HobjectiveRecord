//
//  User+Mappings.m
//

#import "User+Mappings.h"

@implementation User (Mappings)

+ (NSDictionary *)mappings
{
    return @{@"description" : @"userDescription"};
}

- (void)setCreatedAt:(NSString *)createdAt
{
    [self willChangeValueForKey:@"createdAt"];
    [self setPrimitiveValue:createdAt forKey:@"createdAt"];
    [self didChangeValueForKey:@"createdAt"];
    
    // make NSDate from createAt here
    NSDate *createdDate = [NSDate date];
    
    self.createdDate = createdDate;
}

@end
