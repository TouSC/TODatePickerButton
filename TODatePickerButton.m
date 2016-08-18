//
//  TODatePickerButton.m
//  DatePickerDemo
//
//  Created by 唐绍成 on 16/7/25.
//  Copyright © 2016年 唐绍成. All rights reserved.
//

#import "TODatePickerButton.h"
#import <objc/runtime.h>

@implementation TODatePickerButton

- (id)init
{
    self = [[TODatePickerButton alloc] initWithFrame:CGRectZero];
    return self;
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"dd/MM/yyyy";
        
        [self addTarget:self action:@selector(clickSelf) forControlEvents:UIControlEventTouchUpInside];
        
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-216, [UIScreen mainScreen].bounds.size.width, 216)];
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker addTarget:self action:@selector(datePickerChanged) forControlEvents:UIControlEventValueChanged];
        _bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-250, [UIScreen mainScreen].bounds.size.width, 34)];
        _bar.barStyle = UIBarStyleBlack;
        UIBarButtonItem *cancel_Btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
        _bar.items = @[cancel_Btn];
        [[[UIApplication sharedApplication].delegate window]addSubview:_datePicker];
        [[[UIApplication sharedApplication].delegate window]addSubview:_bar];
        [[[UIApplication sharedApplication].delegate window]sendSubviewToBack:_datePicker];
        [[[UIApplication sharedApplication].delegate window]sendSubviewToBack:_bar];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return self;
}
static const char isObservingKey = '\00';
static const char contentHeightKey = '\01';
static const char scrollViewKey = '\02';
- (void)setViewController:(UIViewController *)viewController;
{
    _viewController = viewController;
    BOOL isObserving = [objc_getAssociatedObject(_viewController, &isObservingKey) boolValue];
    if (!isObserving)
    {
        CGFloat contentHeight = _scrollView.contentSize.height;
        objc_setAssociatedObject(_viewController, &isObservingKey, @(YES), OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(_viewController, &contentHeightKey, @(contentHeight), OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(_viewController, &scrollViewKey, _scrollView, OBJC_ASSOCIATION_RETAIN);
    }
}

- (void)dismiss;
{
    [[[UIApplication sharedApplication].delegate window]sendSubviewToBack:_datePicker];
    [[[UIApplication sharedApplication].delegate window]sendSubviewToBack:_bar];
    [[[UIApplication sharedApplication].delegate window]bringSubviewToFront:[(UIViewController*)_viewController view]];
    if (_scrollView)
    {
        CGFloat contentHeight = [objc_getAssociatedObject(_viewController, &contentHeightKey) floatValue];
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, contentHeight);
        objc_setAssociatedObject(_scrollView, &isContentChanged, @(NO), OBJC_ASSOCIATION_RETAIN);
        if (_scrollView.contentOffset.y>(_scrollView.contentSize.height-_scrollView.frame.size.height))
        {
            if (_scrollView.contentSize.height-_scrollView.frame.size.height>0)
            {
                [_scrollView setContentOffset:CGPointMake(0, _scrollView.contentSize.height-_scrollView.frame.size.height) animated:YES];
            }
        }
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            UIView *superView = [(UIViewController*)_viewController view];
            superView.frame = CGRectMake(superView.frame.origin.x, 0, superView.frame.size.width, superView.frame.size.height);
        }];
    }
}

static const char isContentChanged = '\03';
- (void)clickSelf;
{
    if (_delegate && [_delegate respondsToSelector:@selector(datePickerBegan:)])
    {
        [_delegate datePickerBegan:self];
    }
    [_viewController.view endEditing:YES];
    [self setTitle:[_formatter stringFromDate:_datePicker.date] forState:UIControlStateNormal];
    
    [[[UIApplication sharedApplication].delegate window]bringSubviewToFront:_datePicker];
    [[[UIApplication sharedApplication].delegate window]bringSubviewToFront:_bar];
    
    CGRect rect = [[(UIViewController*)_viewController view] convertRect:self.frame fromView:self.superview];
    CGRect inrect = [_scrollView convertRect:self.frame fromView:self.superview];
    CGFloat bottom = rect.origin.y+rect.size.height;
    CGFloat top = [UIScreen mainScreen].bounds.size.height-283;
    
    if (_scrollView)
    {
        BOOL isChanged = [objc_getAssociatedObject(_scrollView, &isContentChanged) boolValue];
        if (!isChanged)
        {
            CGFloat contentHeight = [objc_getAssociatedObject(_viewController, &contentHeightKey) floatValue];
            _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, contentHeight+283);
            objc_setAssociatedObject(_scrollView, &isContentChanged, @(YES), OBJC_ASSOCIATION_RETAIN);
        }
        if (bottom<top)
        {
            return;
        }
        [UIView animateWithDuration:0.3 animations:^{
            [_scrollView setContentOffset:CGPointMake(0, inrect.origin.y-[UIScreen mainScreen].bounds.size.height+283)];
        }];
    }
    else
    {
        if (bottom<top)
        {
            return;
        }
        [UIView animateWithDuration:0.3 animations:^{
            UIView *superView = [(UIViewController*)_viewController view];
            superView.frame = CGRectMake(superView.frame.origin.x, -(bottom-top), superView.frame.size.width, superView.frame.size.height);
        }];
    }
}

- (void)datePickerChanged;
{
    [self setTitle:[_formatter stringFromDate:_datePicker.date] forState:UIControlStateNormal];
    if (_delegate&&[_delegate respondsToSelector:@selector(datePickerChanged:)])
    {
        [_delegate datePickerChanged:self];
    }
}

- (void)dealloc;
{
    [_datePicker removeFromSuperview];
    [_bar removeFromSuperview];
    _datePicker = nil;
    _bar = nil;
}

@end
