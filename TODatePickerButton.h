//
//  TODatePickerButton.h
//  DatePickerDemo
//
//  Created by 唐绍成 on 16/7/25.
//  Copyright © 2016年 唐绍成. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TODatePickerButton;

@protocol TODatePickerButtonDelegate <NSObject>

@optional
- (void)datePickerBegan:(TODatePickerButton*)button;
- (void)datePickerChanged:(TODatePickerButton*)button;

@end

@interface TODatePickerButton : UIButton

@property(nonatomic,weak)UIViewController* viewController;
@property(nonatomic,weak)UIScrollView* scrollView;

@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic,strong)UIToolbar *bar;

@property(nonatomic,strong)NSDateFormatter *formatter;

@property(nonatomic,weak)id<TODatePickerButtonDelegate>delegate;

- (void)dismiss;

@end
