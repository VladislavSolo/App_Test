//
//  VSWidgetViewController.m
//  App_Task
//
//  Created by Владислав Станишевский on 7/1/15.
//  Copyright (c) 2015 Vlad Stanishevskij. All rights reserved.
//

#import "VSWidgetViewController.h"
#import "ZLSwipeableView.h"
#import "VSCitationFirstView.h"
#import "VSCitationSecondView.h"
#import "VSHTTPManager.h"
#import "VSPersistencyManager.h"
#import "VSCitation.h"
#import <Social/Social.h>
#import "RKDropdownAlert.h"

static NSUInteger firstPage = 0;

NSString* const VSCitationDidChangeNotification = @"VSCitationDidChangeNotification";

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
    
    offset = 0;
    self.swipeableView.delegate = self;
    httpManager = [[VSHTTPManager alloc] init];
    self.citation = [[VSCitation alloc] init];
    
    [self getCitationFromServer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(citationNotification:)
                                                 name:VSCitationDidChangeNotification
                                               object:nil];
    [self setNavigationBar];
    
    if (![httpManager isNetwork]) {
        [RKDropdownAlert title:@"Нет подключения к интернету"
               backgroundColor:[UIColor whiteColor]
                     textColor:[UIColor blackColor]
                          time:3.0];
    }

}

- (void)viewDidLayoutSubviews {

    self.swipeableView.dataSource = self;
}

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setNavigationBar {

    if (self.pageIndex == firstPage) {
        
        UIImageView* favouriteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list.png"]];
        favouriteView.frame = CGRectMake(self.view.frame.size.width/2 - 20, 15, 40, 40);
        [self.view addSubview:favouriteView];
        
        UIImage* imageFacebook = [UIImage imageNamed:@"twitter.png"];
        CGRect facebookFrame = CGRectMake(self.swipeableView.frame.origin.x, 5*self.swipeableView.frame.size.height/4 + 10, 50, 40);
        
        UIButton *facebookButton = [[UIButton alloc] initWithFrame:facebookFrame];
        [facebookButton setBackgroundImage:imageFacebook forState:UIControlStateNormal];
        [facebookButton addTarget:self action:@selector(actionTwitterShare:) forControlEvents:UIControlEventTouchUpInside];
        [facebookButton setShowsTouchWhenHighlighted:YES];
        [self.view addSubview:facebookButton];
        
        UIImage* imageTwitter = [UIImage imageNamed:@"facebook.png"];
        CGRect twitterFrame = CGRectMake(self.swipeableView.frame.size.width - 10, 5*self.swipeableView.frame.size.height/4, 60, 60);
        
        UIButton *twitterButton = [[UIButton alloc] initWithFrame:twitterFrame];
        [twitterButton setBackgroundImage:imageTwitter forState:UIControlStateNormal];
        [twitterButton addTarget:self action:@selector(actionFacebookShare:) forControlEvents:UIControlEventTouchUpInside];
        [twitterButton setShowsTouchWhenHighlighted:YES];
        [self.view addSubview:twitterButton];
        
    } else {
        
        UIImageView* favouriteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favourite.png"]];
        favouriteView.frame = CGRectMake(self.view.frame.size.width/2 - 22, 11, 44, 44);
        [self.view addSubview:favouriteView];

        UIImage* reverseImage = [UIImage imageNamed:@"reverse.png"];
        CGRect reverseFrame = CGRectMake(self.view.frame.size.width/2 - 30, 5*self.swipeableView.frame.size.height/4, 60, 60);
        
        UIButton* button = [[UIButton alloc] initWithFrame:reverseFrame];
        button.backgroundColor = [UIColor blackColor];
        [button setBackgroundImage:reverseImage forState:UIControlStateNormal];
        [button setShowsTouchWhenHighlighted:YES];
        [button addTarget:self action:@selector(actionShowCitationAgain:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
    }
}

- (void)setCitation:(VSCitation *)citation {
    
    _citation = citation;
    
    NSDictionary* dictionary = [NSDictionary dictionaryWithObject:citation forKey:VSCitationDidChangeNotification];
    [[NSNotificationCenter defaultCenter] postNotificationName:VSCitationDidChangeNotification
                                                        object:nil
                                                      userInfo:dictionary];
}

#pragma mark - Actions

- (void)actionShowCitationAgain:(UIButton *)sender {
    
    offset = 0;
    [self.swipeableView discardAllSwipeableViews];
    [self.swipeableView loadNextSwipeableViewsIfNeeded];
}

- (void)actionFacebookShare:(UIButton *)sender {
    
    if (self.citation.citationText == nil) {
        
        [RKDropdownAlert title:@"Нет подключения к интернету"
               backgroundColor:[UIColor whiteColor]
                     textColor:[UIColor blackColor]
                          time:3.0];
        
    } else {
    
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        if ([self.citation.citationAuthor isEqual:@""]) {
            
            [controller setInitialText:[NSString stringWithFormat:@"%@\n", self.citation.citationText]];
        } else {
            
            [controller setInitialText:[NSString stringWithFormat:@"%@\n\n%@.", self.citation.citationText, self.citation.citationAuthor]];
        }
        [controller addURL:[NSURL URLWithString:self.citation.citationLink]];
        [self presentViewController:controller animated:YES completion:Nil];
    }
}

- (void)actionTwitterShare:(UIButton *)sender {
    
    if (self.citation.citationText == nil) {
        
        [RKDropdownAlert title:@"Нет подключения к интернету"
               backgroundColor:[UIColor whiteColor]
                     textColor:[UIColor blackColor]
                          time:3.0];
        
    } else {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];

        if ([self.citation.citationAuthor isEqual:@""]) {
            
            [controller setInitialText:[NSString stringWithFormat:@"%@\nvia @forismatic\n", self.citation.citationText]];
        } else {
            
            [controller setInitialText:[NSString stringWithFormat:@"%@\n\n%@.\nvia @forismatic\n",
                                        self.citation.citationText, self.citation.citationAuthor]];
        }
        [controller addURL:[NSURL URLWithString:self.citation.citationLink]];
        [self presentViewController:controller animated:YES completion:Nil];
    }
}

- (void)citationNotification:(NSNotification*) notification {
    
    if (self.pageIndex == firstPage) {
        [[self.swipeableView topSwipeableView] setCitationText:self.citation.citationText andCitationAuthor:self.citation.citationAuthor];
    }
}

- (void)actionSwipeRight {
    [self.swipeableView swipeTopViewToRight];
}

- (void)actionSwipeLeft {
    [self.swipeableView swipeTopViewToLeft];
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

    if (self.pageIndex == firstPage) {
        
        VSCitationFirstView* view = [[VSCitationFirstView alloc] initWithFrame:self.swipeableView.bounds];
        view.backgroundColor = [UIColor blackColor];
        [view.favouriteButton addTarget:self action:@selector(actionSwipeRight) forControlEvents:UIControlEventTouchUpInside];
        [view.deleteButton addTarget:self action:@selector(actionSwipeLeft) forControlEvents:UIControlEventTouchUpInside];
        return view;
    } else {
        
        VSCitationSecondView* view = [[VSCitationSecondView alloc] initWithFrame:self.swipeableView.bounds];
        
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
        
        [self getAndCheckCitation];
    }

}

@end
