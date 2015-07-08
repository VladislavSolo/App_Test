//
//  VSCitationView.h
//  App_Task
//
//  Created by Владислав Станишевский on 7/1/15.
//  Copyright (c) 2015 Vlad Stanishevskij. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSCitationView : UIView

@property (strong, nonatomic) UIButton *favouriteButton;
@property (strong, nonatomic) UIButton *deleteButton;

- (void)setCitationText:(NSString *)citationText andCitationAuthor:(NSString *)citationAuthor;

@end

@interface VSCitationView (ViewWithButton)

- (instancetype)initWithButtonAndFrame:(CGRect)frame;

@end
