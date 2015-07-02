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
#import "VSPersistencyManager.h"
#import "VSCitation.h"

static NSUInteger firstPage = 0;
static NSUInteger secondPage = 1;

@interface VSWidgetViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate, UIActionSheetDelegate>

{
    VSHTTPManager* httpManager;
    NSUInteger offset;
}

@property (weak, nonatomic) IBOutlet ZLSwipeableView *swipeableView;
@property (strong, nonatomic) VSCitation* citation;

@end

@implementation VSWidgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.swipeableView.delegate = self;
    httpManager = [[VSHTTPManager alloc] init];
    self.citation = [[VSCitation alloc] init];
    offset = 0;
    
    if (self.pageIndex == secondPage) {
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(self.swipeableView.bounds.size.width/2 - 50,
                                                                  self.swipeableView.bounds.size.height + 180, 180, 50)];
    [button setTitle:@"Начать показ заново" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTintColor:[UIColor blueColor]];
    button.backgroundColor = [UIColor blackColor];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(showCitationAgain:) forControlEvents:UIControlEventTouchUpInside];
    
    }
    
}

- (void)showCitationAgain:(UIButton *)sender {
    
    offset = 0;
}

- (void)viewDidLayoutSubviews {
    
    self.swipeableView.dataSource = self;
}

#pragma mark - ZLSwipeableViewDelegate

- (void)swipeableView:(ZLSwipeableView *)swipeableView
       didCancelSwipe:(UIView *)view {

}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
  didStartSwipingView:(UIView *)view
           atLocation:(CGPoint)location {

}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
          swipingView:(UIView *)view
           atLocation:(CGPoint)location
          translation:(CGPoint)translation {

}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
    didEndSwipingView:(UIView *)view
           atLocation:(CGPoint)location {

}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
         didSwipeView:(UIView *)view
          inDirection:(ZLSwipeableViewDirection)direction {
    
    switch (direction) {
        case 1:
            
            if (self.pageIndex == firstPage) {
                [[VSPersistencyManager sharedManager] setCitationToBlackList:self.citation];
            }
            break;
        case 2:
            
            if (self.pageIndex == firstPage) {
                [[VSPersistencyManager sharedManager] setCitationToData:self.citation];
            }
            break;
        default:
            break;
    }
}

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
    
    VSCitationView* view = [[VSCitationView alloc] initWithFrame:swipeableView.bounds];
    view.backgroundColor = [UIColor blackColor];
    
    __weak typeof(self) weakSelf = self;
    
    if (self.pageIndex == firstPage) {
        
        [httpManager getRandomCitationOnSuccess:^(VSCitation *respCitation) {
    
            [view setCitationText:respCitation.citationText andCitationAuthor:respCitation.citationAuthor];
            
            weakSelf.citation = respCitation;
        }
                                      onFailure:^(NSError *error) {
    
                                      }];
        return view;
    } else {
        
        VSCitation* citation = [[VSPersistencyManager sharedManager] getCitationFromDataWithOffset:offset];

        [view setCitationText:citation.citationText andCitationAuthor:citation.citationAuthor];
        offset++;
        
        NSLog(@"%ld", offset);
        
        return view;
    }
    return nil;
}

@end
