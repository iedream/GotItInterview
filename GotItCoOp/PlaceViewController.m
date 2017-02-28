//
//  PlaceViewController.m
//  GotItCoOp
//
//  Created by Catherine Zhao on 2017-02-27.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "PlaceViewController.h"
#import <GoogleMaps/GoogleMaps.h>

NSString *photoCellIdentifier = @"PhotoCollectionCell";

@interface PlaceViewController ()
@property (weak, nonatomic) IBOutlet UITextView *dataView;
@property (weak, nonatomic) IBOutlet UICollectionView *photoView;
@property (weak, nonatomic) IBOutlet UIView *mapView;

@property (strong, nonatomic) NSArray *photoData;

@end

@implementation PlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _photoView.delegate = self;
    _photoView.dataSource = self;
    [_photoView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:photoCellIdentifier];
    [_photoView reloadData];
    
    [_dataView setText:@"No Data Available"];
    [self formatText];
    [self loadMapView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh:) name:@"newPhotoData" object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)formatText {
    NSString *resultString = @"";
    if (_placeInfo.name) {
        resultString = [NSString stringWithFormat:@"%@Name: %@\n\n", resultString, _placeInfo.name];
    }
    if (_placeInfo.address) {
        resultString = [NSString stringWithFormat:@"%@Address: %@\n\n", resultString, _placeInfo.address];
    }
    resultString = [NSString stringWithFormat:@"%@Distance: %.2f km\n\n", resultString, _placeInfo.distance];
    if (_placeInfo.type) {
        resultString = [NSString stringWithFormat:@"%@Type: %@\n\n", resultString, _placeInfo.type];
    }
    if (_placeInfo.website) {
        resultString = [NSString stringWithFormat:@"%@Website: %@\n\n", resultString, _placeInfo.website];
    }
    if (_placeInfo.phoneNumber) {
        resultString = [NSString stringWithFormat:@"%@Phone Number: %@\n\n", resultString, _placeInfo.phoneNumber];
    }
    if (_placeInfo.openNow) {
        resultString = [NSString stringWithFormat:@"%@Currently Open\n\n", resultString];
    }else if (_placeInfo.openNow) {
        resultString = [NSString stringWithFormat:@"%@Currently Close\n\n", resultString];
    }
    [_dataView setText:resultString];
}

- (void)loadMapView {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:_placeInfo.coordinate zoom:17];
    GMSMapView *mapView = [GMSMapView mapWithFrame:_mapView.bounds camera:camera];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:_placeInfo.coordinate];
    marker.icon = [UIImage imageNamed:@"mark.png"];
    marker.map = mapView;
    [_mapView addSubview:mapView];
}

- (void)refresh:(NSNotification *)notif {
    _photoData = (NSArray *)notif.userInfo[@"photos"] ;
    [_photoView reloadData];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(150, 150);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return  1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *backgroundImage = _photoData[indexPath.row];
    UICollectionViewCell *cell = [_photoView dequeueReusableCellWithReuseIdentifier:photoCellIdentifier forIndexPath:indexPath];
    if (!backgroundImage) {
        backgroundImage = [UIImage imageNamed:@"imageComingSoon"];
    }
    cell.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    return cell;
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
