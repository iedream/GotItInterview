//
//  FirstViewController.m
//  GotItCoOp
//
//  Created by Catherine Zhao on 2017-02-27.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "FirstViewController.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
#import "SearchRequest.h"
#import "SearchResult.h"
#import "PlaceViewController.h"

const NSString *baseUrl = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?";
NSString *apiKey = @"AIzaSyBOowv0aEr-202j_MYGPIqMXLt4kmRzkJQ";
NSString *collectionCellIdentifier = @"MainTableCell";

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic, strong)NSMutableArray *placeData;
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic) BOOL initialized;
@property (nonatomic, weak)id <PlaceRequestDelegate> delegate;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeCollectionBackground.png"]];
    backgroundImageView.frame = self.view.frame;
    [self.view addSubview:backgroundImageView];
    for (UIView *view in self.view.subviews.copy) {
        if (view != backgroundImageView) {
            [self.view bringSubviewToFront:view];
            
        }
    }
    
    [GMSPlacesClient provideAPIKey:apiKey];
    [GMSServices provideAPIKey:apiKey];
    
    _placeData = [[NSMutableArray alloc] init];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [_locationManager requestLocation];
    }
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionCellIdentifier];
    
    SecondViewController *secondViewController = self.tabBarController.viewControllers.lastObject;
    _delegate = secondViewController;
    
    _searchBar.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh:) name:@"initialPhotoReading" object:nil];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh:(NSNotification *)notif {
    [_collectionView reloadData];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80, 80);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return  1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _placeData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchResult *currentPlaceObject = _placeData[indexPath.row];
    UIImage *backgroundImage = currentPlaceObject.coverPhoto;
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchResult *currentPlaceObject = _placeData[indexPath.row];
    PlaceInfo *placeInfo = [currentPlaceObject placeInfo];
    
    PlaceViewController *placeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlaceViewController"];
    placeViewController.placeInfo = placeInfo;
    [self presentViewController:placeViewController animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocationCoordinate2D currentLocation = locations.firstObject.coordinate;
    self.currentLocation = currentLocation;
    if (!_initialized && currentLocation.latitude != 0 && currentLocation.longitude != 0) {
        _initialized = true;
        SearchRequest initialSearchRequest = {NO, -1, NO, NONE, NO, RANK_BY_PROMINENCE};
        [self searchPlaces:initialSearchRequest searchText:nil];
    }
    self.currentLocation = currentLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

- (IBAction)refreshPlaces:(id)sender {
    SearchRequest searchRequest = [_delegate getCurrentSearchSetting];
    
    NSString *searchText = _searchBar.text;
    searchText = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];

    [self searchPlaces:searchRequest searchText:searchText];
}

- (double)distanceFromCurrentLocation:(CLLocationCoordinate2D)destination {
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:_currentLocation.latitude longitude:_currentLocation.longitude];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destination.latitude longitude:destination.longitude];
    return [destinationLocation distanceFromLocation:currentLocation];
}

- (void)searchPlaces:(SearchRequest)searchRequest searchText:(NSString *)searchText{
    NSString *url = [NSString stringWithFormat:@"%@location=%f,%f&key=%@", baseUrl, _currentLocation.latitude,_currentLocation.longitude, apiKey];
    

    BOOL needSorting = searchRequest.rank == RANK_BY_DISTANCE;
    if(searchRequest.hasType) {
        url = [NSString stringWithFormat:@"%@&type=%@", url, [SearchRequestHelper stringForCategoryType:searchRequest.type]];
        needSorting = NO;
    }
    
    if (searchRequest.wantOpenNow) {
        url = [NSString stringWithFormat:@"%@&opennow=true", url];
    }
    
    if (searchText.length > 0) {
        url = [NSString stringWithFormat:@"%@&keyword=%@", url, searchText];
        needSorting = NO;
    }

    
    if (searchRequest.rank == RANK_BY_PROMINENCE || needSorting) {
        int radius = 50000;
        if (searchRequest.hasBoundary) {
            radius = searchRequest.radius;
        }
        url = [NSString stringWithFormat:@"%@&radius=%i", url, radius];
    } else {
        url = [NSString stringWithFormat:@"%@&rankby=distance", url];
    }
    
    __weak __typeof__(self) weakSelf = self;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:40.0];
    [request setHTTPMethod:@"GET"];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSError *err;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if (httpResponse.statusCode == 200) {
            NSArray *listOfPlaces = json[@"results"];
            __typeof__(self) strongSelf = weakSelf;
            [strongSelf processPlacesResult:listOfPlaces searchRequest:searchRequest needSorting:needSorting];
        }
    }];
    [task resume];
}
                              
- (void)processPlacesResult:(NSArray *)listOfPlaces searchRequest:(SearchRequest)searchRequest needSorting:(BOOL)needSorting{
    [_placeData removeAllObjects];
    for (NSDictionary *placeDict in listOfPlaces) {
        NSDictionary *locationDict = placeDict[@"geometry"][@"location"];
        CLLocationCoordinate2D locationCoord = CLLocationCoordinate2DMake([locationDict[@"lat"] doubleValue], [locationDict[@"lng"] doubleValue]);
        double distance = [self distanceFromCurrentLocation:locationCoord];
        if (searchRequest.hasBoundary  && distance > searchRequest.radius ) {
            break;
        }
        
        BOOL openNow = [placeDict[@"opening_hours"][@"open_now"] boolValue];

        NSString *place_id = placeDict[@"place_id"];
        SearchResult *placeObject = [[SearchResult alloc] initWithPlaceId:place_id openNow:openNow distance:distance coordinate:locationCoord];
        if (needSorting) {
            [self sort:placeObject];
        }else {
            [_placeData addObject:placeObject];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectionView reloadData];
    });
}

- (void)sort:(SearchResult *)currentNode {
    BOOL moveToRight = NO;
    NSMutableArray *newPlaceData = [[NSMutableArray alloc] init];
    for (int i = 0; i <= _placeData.count; i++) {
        if (moveToRight) {
            newPlaceData[i] = _placeData[i-1];
            
        }else if (i < _placeData.count && [currentNode placeInfo].distance < [_placeData[i] placeInfo].distance) {
            moveToRight = YES;
            newPlaceData[i] = currentNode;
        }else if  (i < _placeData.count){
            newPlaceData[i] = _placeData[i];
        }
    }
    if (!moveToRight) {
        [newPlaceData addObject:currentNode];

    }
    _placeData = newPlaceData;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
    [self refreshPlaces:_searchBar];
}

- (void)dismissKeyboard
{
    [_searchBar resignFirstResponder];
}

@end
