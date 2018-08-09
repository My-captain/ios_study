//
//  CustomAnnotationView.m
//  CustomAnnotationDemo
//
//  Created by songjian on 13-3-11.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CustomCalloutView.h"

#define kWidth 200.f
#define kHeight 70.f

#define kHoriMargin 5.f
#define kVertMargin 5.f

#define kPortraitWidth  50.f
#define kPortraitHeight 50.f

#define kCalloutWidth   200.0
#define kCalloutHeight  90.0

@interface CustomAnnotationView ()

@property (nonatomic, strong) UIImageView *portraitImageView;


@end

@implementation CustomAnnotationView
@synthesize name=_name;
@synthesize calloutView;
@synthesize portraitImageView   = _portraitImageView;
#pragma mark - Handle Action

- (void)btnAction
{
    
    CLLocationCoordinate2D coorinate = [self.annotation coordinate];
    
    NSLog(@"coordinate = {%f, %f}", coorinate.latitude, coorinate.longitude);
}

#pragma mark - Override

- (UIImage *)portrait
{
    return self.portraitImageView.image;
}
- (void)setPortrait:(UIImage *)portrait
{
    self.portraitImageView.image = portrait;
}
//- (UILabel *)name
//{
//    return self.name.text;
//}
//
//- (void)setName:(UILabel *)name{
//    self.name.text =name;
//}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        if (self.calloutView == nil)
        {
            /* Construct custom callout. */
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            // [btn addTarget:<#(nullable id)#> action:@selector(@"lookuUpinfo:") forControlEvents:<#(UIControlEvents)#>];
            btn.frame = CGRectMake(160, 0, 30, 30);
            [btn setBackgroundImage:[UIImage imageNamed:@"ic_keyboard_arrow_right_black_24dp"] forState:UIControlStateNormal];
            
            //            [btn setTitle:@"Test" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
            
            [self.calloutView addSubview:btn];
            
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 0,160, 30)];
            name.backgroundColor = [UIColor clearColor];
            name.textColor = [UIColor blackColor];
            name.adjustsFontSizeToFitWidth=YES;
            NSString* nameStr=[NSUserDefaults.standardUserDefaults stringForKey:@"cnName"];
            NSString* timeStr=[NSUserDefaults.standardUserDefaults stringForKey:@"time"];
            float speed = [NSUserDefaults.standardUserDefaults floatForKey:@"speed"];
            NSString* cbsbhStr=[NSUserDefaults.standardUserDefaults stringForKey:@"cbsbh"];
            UILabel *subname = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 200, 15)];
            subname.backgroundColor = [UIColor clearColor];
            subname.textColor = [UIColor blackColor];
            subname.font=[UIFont systemFontOfSize:11];
            
            subname.text=[NSString stringWithFormat:@"船舶识别号：%@",cbsbhStr];
            
            
            UILabel *speedLB = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 200, 15)];
            speedLB.backgroundColor = [UIColor clearColor];
            speedLB.textColor = [UIColor blackColor];
            speedLB.text=[NSString stringWithFormat:@"航行速度：%.2fkm/h", speed];
            speedLB.font=[UIFont systemFontOfSize:11];
            
            
            UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(10, 55, 200, 15)];
            time.backgroundColor = [UIColor clearColor];
            time.textColor = [UIColor blackColor];
            time.text=[NSString stringWithFormat:@"时间：%@",timeStr];
            time.font=[UIFont systemFontOfSize:11];
            
            name.text = nameStr;
            [self.calloutView addSubview:name];
            [self.calloutView addSubview:subname];
            [self.calloutView addSubview:time];
            [self.calloutView addSubview:speedLB];
            
        }
        
        [self addSubview:self.calloutView];
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside:point withEvent:event];
    /* Points that lie outside the receiver’s bounds are never reported as hits,
     even if they actually lie within one of the receiver’s subviews.
     This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
     */
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    
    return inside;
}
- (void)clickBtn{
    [self.delegate btnAction];
}
#pragma mark - Life Cycle


- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        //self.bounds = CGRectMake(0.f, 0.f, kWidth, kHeight);
        
        //self.backgroundColor = [UIColor clearColor];
        
        /* Create portrait image view and add to view hierarchy. */
        //self.portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kHoriMargin, kVertMargin, kPortraitWidth, kPortraitHeight)];
        [self addSubview:self.portraitImageView];
        
    }
    
    return self;
}

@end
