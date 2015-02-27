//
//  DetailViewController.h
//

#import <UIKit/UIKit.h>

@import CoreData;

@protocol DetailViewControllerDelegate <NSObject>

- (void)detailViewControllerFinished:(id)sender;

@end


@interface DetailViewController : UIViewController

@property (weak, nonatomic) id<DetailViewControllerDelegate> delegate;

@property (nonatomic, strong) NSManagedObjectID *objectId;

@end
