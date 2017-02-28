//
//  SecondViewController.h
//  GotItCoOp
//
//  Created by Catherine Zhao on 2017-02-27.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchRequest.h"

@protocol PlaceRequestDelegate <NSObject>
- (SearchRequest)getCurrentSearchSetting;
@end

@interface SecondViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, PlaceRequestDelegate, UITextFieldDelegate>
@property (nonatomic, readonly)SearchRequest currentSearchRequest;

@end

