//
//  TwitterStream.m
//

@import Social;

#import "TwitterStream.h"
#import "HobjectiveRecord.h"
#import "Tweet.h"

@interface TwitterStream ()

@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableString *buffer;
@end

@implementation TwitterStream

- (void)start
{
    NSURL *url = [NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/sample.json"];
    NSDictionary *params = @{@"delimited" : @"length"};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:params];

    [request setAccount:self.twitterAccount];
    
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:request.preparedURLRequest delegate:self startImmediately:NO];
    
    [self.urlConnection setDelegateQueue:[[NSOperationQueue alloc] init]];
    
    [self.urlConnection start];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSLog(@"Start Connection");
}

- (void)stop
{
    [self.urlConnection cancel];
    self.urlConnection = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"Cancel Connection");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@",error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse %@",response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"didReceiveData %@",response);
    
    for (NSString* part in [response componentsSeparatedByString:@"\r\n"]) {
        NSInteger length = [part integerValue];
        if (length > 0) {
            if (self.buffer) {
                //NSLog(@"self.buffer \n\n%@", self.buffer);
                
                id tweetDictionary = [NSJSONSerialization JSONObjectWithData:[self.buffer dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                if ([tweetDictionary isKindOfClass:[NSDictionary class]]) {
                    if (tweetDictionary[@"id_str"]) {
                        [self.moc performBlock:^{
                            [Tweet create:tweetDictionary inContext:self.moc];
                        }];
                    }
                }
            }
            self.buffer = [NSMutableString string];
        }
        else {
            [self.buffer appendString:part];
        }
    }
    
    [self.moc performBlock:^{
        [self.moc saveToStore];
    }];
}

@end
