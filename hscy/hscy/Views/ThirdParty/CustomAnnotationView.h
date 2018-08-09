//
//  CustomAnnotationView.h
//  CustomAnnotationDemo
//
//  Created by songjian on 13-3-11.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
@protocol BtnActionDelegate <NSObject>

- (void)btnAction;

@end


@interface CustomAnnotationView : MAAnnotationView

@property (nonatomic, strong) UILabel *name;

@property (nonatomic, strong) UILabel *subname;

@property (nonatomic, strong) UILabel *time;

@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) UIImage *portrait;

@property (nonatomic, strong) UIView *calloutView;



@end
