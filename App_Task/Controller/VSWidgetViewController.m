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
#import <Social/Social.h>
#import "RKDropdownAlert.h"

static NSUInteger firstPage = 0;
static NSUInteger secondPage = 1;

NSString* const VSCitationDidChangeNotification = @"VSCitationDidChangeNotification";

@interface VSWidgetViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate, UIActionSheetDelegate>

{
    VSHTTPManager* httpManager;
    NSUInteger offset;
}

@property (weak, nonatomic) IBOutlet ZLSwipeableView *swipeableView;
@property (strong, nonatomic) VSCitation* citation;

- (IBAction)actionFacebookShare:(UIButton *)sender;
- (IBAction)actionTwitterShare:(UIButton *)sender;

@end

@implementation VSWidgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    offset = 0;
    
    self.swipeableView.delegate = self;
    httpManager = [[VSHTTPManager alloc] init];
    self.citation = [[VSCitation alloc] init];
    
    [self getCitationFromServer];
    
    if (self.pageIndex == secondPage) {
    
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(self.swipeableView.bounds.size.width/2 - 50,
                                                                      self.swipeableView.bounds.size.height + 150, 180, 50)];
        [button setTitle:@"Начать показ заново" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTintColor:[UIColor blueColor]];
        button.backgroundColor = [UIColor blackColor];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(showCitationAgain:) forControlEvents:UIControlEventTouchUpInside];
    
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(citationNotification:)
                                                 name:VSCitationDidChangeNotification
                                               object:nil];
    if (![httpManager isNetwork]) {
        [RKDropdownAlert title:@"No internet connection" backgroundColor:[UIColor whiteColor] textColor:[UIColor blackColor] time:3.0];
    }

}

- (void)viewDidLayoutSubviews {

    self.swipeableView.dataSource = self;
}

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setCitation:(VSCitation *)citation {
    
    _citation = citation;
    
    NSDictionary* dictionary = [NSDictionary dictionaryWithObject:citation forKey:VSCitationDidChangeNotification];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VSCitationDidChangeNotification
                                                        object:nil
                                                      userInfo:dictionary];
}

#pragma mark Action

- (void)showCitationAgain:(UIButton *)sender {
    
    offset = 0;
    [self.swipeableView discardAllSwipeableViews];
    [self.swipeableView loadNextSwipeableViewsIfNeeded];
}

- (void)actionFacebookShare:(UIButton *)sender {
    
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    if ([self.citation.citationAuthor isEqual:@""]) {
        
        [controller setInitialText:[NSString stringWithFormat:@"%@\nvia @forismatic\n", self.citation.citationText]];
    } else {
        
        [controller setInitialText:[NSString stringWithFormat:@"%@\n\n%@.", self.citation.citationText, self.citation.citationAuthor]];
    }
    [controller addURL:[NSURL URLWithString:self.citation.citationLink]];
    [self presentViewController:controller animated:YES completion:Nil];
}

- (IBAction)actionTwitterShare:(UIButton *)sender {
    
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    if ([self.citation.citationAuthor isEqual:@""]) {
        
        [controller setInitialText:[NSString stringWithFormat:@"%@\n", self.citation.citationText]];
    } else {
        
        [controller setInitialText:[NSString stringWithFormat:@"%@\n\n%@.\nvia @forismatic\n",
                                    self.citation.citationText, self.citation.citationAuthor]];
    }
    [controller addURL:[NSURL URLWithString:self.citation.citationLink]];
    [self presentViewController:controller animated:YES completion:Nil];
}

- (void)citationNotification:(NSNotification*) notification {
    

    if (self.pageIndex == firstPage) {
        [[self.swipeableView topSwipeableView] setCitationText:self.citation.citationText andCitationAuthor:self.citation.citationAuthor];
    }
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
    [self getCitationFromServer];

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
    
    VSCitationView* view = [[VSCitationView alloc] initWithFrame:self.swipeableView.bounds];
    view.backgroundColor = [UIColor blackColor];

    if (self.pageIndex == firstPage) {
        
        return view;
    } else {
        
        VSCitation* citation = [[VSPersistencyManager sharedManager] getCitationFromDataWithOffset:offset];
        
        [view setCitationText:citation.citationText andCitationAuthor:citation.citationAuthor];
        offset++;
        
        return view;
    }
    return nil;
}

#pragma mark - HTTP Manager

- (BOOL)getAndCheckCitation {
    
    __weak typeof(self) weakSelf = self;
    
    [httpManager getRandomCitationOnSuccess:^(VSCitation *respCitation) {

        weakSelf.citation = respCitation;
    }
                                  onFailure:^(NSError *error) {
                                      
                                  }];
    if (self.citation == nil) {
        return NO;
    }
    return YES;
}

- (void) getCitationFromServer {
    
    if (![self getAndCheckCitation]) {
        
        [self getCitationFromServer];
    }
}

@end
