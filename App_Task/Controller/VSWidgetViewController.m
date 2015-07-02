//
//  VSWidgetViewController.m
//  App_Task
//
//  Created by Владислав Станишевский on 7/1/15.
//  Copyright (c) 2015 Vlad Stanishevskij. All rights reserved.
//

#import "VSWidgetViewController.h"
#import "ZLSwipeableView.h"
#import "VSCitationView.h"
#import "VSHTTPManager.h"
#import "VSCitation.h"

static NSUInteger fisrtPage = 0;

@interface VSWidgetViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate, UIActionSheetDelegate>

{
    VSHTTPManager* httpManager;
    NSUInteger offset;
}

@property (weak, nonatomic) IBOutlet ZLSwipeableView *swipeableView;

@end

@implementation VSWidgetViewController

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self.swipeableView discardAllSwipeableViews];
    [self.swipeableView loadNextSwipeableViewsIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.swipeableView.delegate = self;
    httpManager = [[VSHTTPManager alloc] init];
    offset = 0;
}

- (void)viewDidLayoutSubviews {
    
    self.swipeableView.dataSource = self;
}

-(void)slideToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer{
    [UIView animateWithDuration:0.5 animations:^{
        
        NSLog(@"Right");
        
    }];
}

-(void)slideToLeftWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer{
    [UIView animateWithDuration:0.5 animations:^{
        
        NSLog(@"Left");
        
    }];
}

#pragma mark - ZLSwipeableViewDelegate

- (void)swipeableView:(ZLSwipeableView *)swipeableView
         didSwipeView:(UIView *)view
          inDirection:(ZLSwipeableViewDirection)direction {
    //NSLog(@"did swipe in direction: %zd", direction);
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
       didCancelSwipe:(UIView *)view {
    //NSLog(@"did cancel swipe");
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
  didStartSwipingView:(UIView *)view
           atLocation:(CGPoint)location {
    //NSLog(@"did start swiping at location: x %f, y %f", location.x, location.y);
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
          swipingView:(UIView *)view
           atLocation:(CGPoint)location
          translation:(CGPoint)translation {
//    NSLog(@"swiping at location: x %f, y %f, translation: x %f, y %f",
//          location.x, location.y, translation.x, translation.y);
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
    didEndSwipingView:(UIView *)view
           atLocation:(CGPoint)location {
    //NSLog(@"did end swiping at location: x %f, y %f", location.x, location.y);
}

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
    
    VSCitationView* view = [[VSCitationView alloc] initWithFrame:swipeableView.bounds];
    view.backgroundColor = [UIColor blackColor];
    
    if (self.pageIndex == fisrtPage) {
        
        [httpManager getRandomCitationOnSuccess:^(VSCitation *respCitation) {
    
            [view setCitationText:respCitation.citationText andCitationAuthor:respCitation.citationAuthor];
            
        }
                                      onFailure:^(NSError *error) {
    
                                      }];
        
    } else {
        
        NSLog(@"%ld", offset);
        offset++;
    }
    
    return view;
}

@end
