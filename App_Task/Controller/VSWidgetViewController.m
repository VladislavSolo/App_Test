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

@interface VSWidgetViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet ZLSwipeableView *swipeableView;

@end

@implementation VSWidgetViewController

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self.swipeableView discardAllSwipeableViews];
    [self.swipeableView loadNextSwipeableViewsIfNeeded];
}

#pragma mark - ZLSwipeableViewDelegate

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.swipeableView.delegate = self;
}

- (void)viewDidLayoutSubviews {
    
    self.swipeableView.dataSource = self;
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView didSwipeView:(UIView *)view inDirection:(ZLSwipeableViewDirection)direction {
    
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView didCancelSwipe:(UIView *)view {
    
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView didStartSwipingView:(UIView *)view atLocation:(CGPoint)location {
    
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView swipingView:(UIView *)view atLocation:(CGPoint)location translation:(CGPoint)translation {
    
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView didEndSwipingView:(UIView *)view atLocation:(CGPoint)location {
    
    
}

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
    
    VSCitationView* view = [[VSCitationView alloc] initWithFrame:swipeableView.bounds];
    view.backgroundColor = [UIColor blackColor];

    UIView *contentView = [[[NSBundle mainBundle] loadNibNamed:@"CardContentView"
                                                         owner:self
                                                       options:nil] objectAtIndex:0];
    
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:contentView];

    NSDictionary *metrics = @{@"height" : @(view.bounds.size.height),
                              @"width" : @(view.bounds.size.width)};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
    
    [view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(width)]"
                                                                  options:0
                                                                  metrics:metrics
                                                                    views:views]];
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:|[contentView(height)]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    return view;
}

@end
