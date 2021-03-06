//
//  ViewController.m
//  App_Task
//
//  Created by Владислав Станишевский on 7/1/15.
//  Copyright (c) 2015 Vlad Stanishevskij. All rights reserved.
//

#import "ViewController.h"
#import "VSWidgetViewController.h"
#import "VSHTTPManager.h"

@interface ViewController () <UIPageViewControllerDataSource>

{
    BOOL isNetwork;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    VSHTTPManager* httpManager = [[VSHTTPManager alloc] init];
    
    isNetwork = [httpManager isNetwork];
    
    _pageTitles = @[@"first", @"second"];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    VSWidgetViewController* startingViewController = [self viewControllerAtIndex:(!isNetwork)];

    NSArray* viewControllers = @[startingViewController];
    
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
    
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 50);
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((VSWidgetViewController *)viewController).pageIndex;
    
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((VSWidgetViewController *)viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index ++;
    
    if (index == [self.pageTitles count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (VSWidgetViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    if ([self.pageTitles count] == 0 || index >= [self.pageTitles count]) {
        
        return nil;
    }
    
    VSWidgetViewController* pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    
    pageContentViewController.pageIndex = index;
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    if (!isNetwork) {
        return 0;
    }
    return 1;
    
}

@end
