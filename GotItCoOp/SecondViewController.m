//
//  SecondViewController.m
//  GotItCoOp
//
//  Created by Catherine Zhao on 2017-02-27.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortingSegmentControl;
@property (weak, nonatomic) IBOutlet UISwitch *openNowSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *cateogryPickerView;
@property (weak, nonatomic) IBOutlet UITextField *distanceTextField;
@property (nonatomic)SearchRequest currentSearchRequest;

@property (strong, nonatomic) NSArray *pickerData;
@end

@implementation SecondViewController
@synthesize currentSearchRequest = _currentSearchRequest;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _cateogryPickerView.delegate = self;
    _cateogryPickerView.dataSource = self;
    _pickerData = [SearchRequestHelper referenceArray];
    
    SearchRequest defaultSearchSetting = {NO, -1, NO, NO, RANK_BY_PROMINENCE};
    _currentSearchRequest = defaultSearchSetting;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _pickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _pickerData[row];
}

- (IBAction)submit:(id)sender {
    CATEGORY type = (int)[_cateogryPickerView selectedRowInComponent:0];
    BOOL nowOpen = _openNowSwitch.on;
    RANK rank = (int)_sortingSegmentControl.selectedSegmentIndex;
    
    NSString *distanceText = _distanceTextField.text;
    distanceText = [distanceText stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL hasBoundary = _distanceTextField.text.length != 0;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [numberFormatter numberFromString:distanceText];
    
    if (hasBoundary && !number) {
        return;
    }
    int radius = [number intValue] * 1000;
        
    BOOL hasType = type != NONE;
    
    SearchRequest currentSearchSetting;
    currentSearchSetting.hasType = hasType;
    currentSearchSetting.type = type;
    currentSearchSetting.hasBoundary = hasBoundary;
    currentSearchSetting.radius = radius;
    currentSearchSetting.rank = rank;
    currentSearchSetting.wantOpenNow = nowOpen;
    _currentSearchRequest = currentSearchSetting;
}

- (SearchRequest)getCurrentSearchSetting {
    return _currentSearchRequest;
}

@end
