//
//  VSCitationView.m
//  App_Task
//
//  Created by Владислав Станишевский on 7/1/15.
//  Copyright (c) 2015 Vlad Stanishevskij. All rights reserved.
//

#import "VSCitationView.h"

@implementation VSCitationView

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
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.33;
    self.layer.shadowOffset = CGSizeMake(0, 1.5);
    self.layer.shadowRadius = 4.0;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.cornerRadius = 10.0;
}

- (void)setCitationText:(NSString *)citationText andCitationAuthor:(NSString *)citationAuthor {
    
    UILabel* citationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 240, 180)];
    citationLabel.lineBreakMode = NSLineBreakByClipping;
    citationLabel.textColor = [UIColor whiteColor];
    citationLabel.text = citationText;
    
    [self addSubview:citationLabel];
    
    UILabel* authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 300, 240, 50)];
    authorLabel.textColor = [UIColor whiteColor];
    authorLabel.text = citationAuthor;
    
    [self addSubview:authorLabel];
}

@end
