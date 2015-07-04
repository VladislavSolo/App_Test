//
//  VSCitationView.h
//  App_Task
//
//  Created by Владислав Станишевский on 7/1/15.
//  Copyright (c) 2015 Vlad Stanishevskij. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSCitationView : UIView

@property (strong, nonatomic) NSString* citationAuthor;
@property (strong, nonatomic) NSString* citationText;

- (void)setCitationText:(NSString *)citationText andCitationAuthor:(NSString *)citationAuthor;

@end
