//
//  VSCitationSecondView.m
//  App_Task
//
//  Created by Владислав Станишевский on 7/5/15.
//  Copyright (c) 2015 Vlad Stanishevskij. All rights reserved.
//

#import "VSCitationSecondView.h"

@interface VSCitationSecondView ()

{
    UITextView* citationView;
    UITextView* authorView;
}

@end

@implementation VSCitationSecondView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.layer.borderWidth = 2;
    self.layer.borderColor = [[UIColor whiteColor] CGColor] ;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.33;
    self.layer.shadowOffset = CGSizeMake(0, 1.5);
    self.layer.shadowRadius = 4.0;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.cornerRadius = 10.0;
    
    citationView = [[UITextView alloc]
                    initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, 3*self.bounds.size.height/4)];
    citationView.textColor = [UIColor whiteColor];
    citationView.backgroundColor = [UIColor blackColor];
    citationView.font = [UIFont italicSystemFontOfSize:16.0];
    [self addSubview:citationView];
    
    authorView = [[UITextView alloc]
                  initWithFrame:CGRectMake(10, self.bounds.size.height/2, self.frame.size.width - 20, self.bounds.size.height/4)];
    authorView.textColor = [UIColor whiteColor];
    authorView.font = [UIFont italicSystemFontOfSize:16.0];
    authorView.backgroundColor = [UIColor blackColor];
    [self addSubview:authorView];
}

- (void)setCitationText:(NSString *)citationText andCitationAuthor:(NSString *)citationAuthor {
    citationView.text = citationText;
    authorView.text = citationAuthor;
}

@end

