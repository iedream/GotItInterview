//
//  SearchResult.m
//  GotItCoOp
//
//  Created by Catherine Zhao on 2017-02-27.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "SearchResult.h"
#import <GooglePlaces/GooglePlaces.h>

const CGSize photoSize = {150, 150};
const CGSize coverPhotoSize = {80, 80};
NSString *newPhotoData = @"newPhotoData";
NSString *initialPhotoReady = @"initialPhotoReading";

@implementation PlaceInfo

@end

@interface SearchResult()
@property (nonatomic, strong)NSString *placeId;

@property (nonatomic, strong)PlaceInfo *placeDetail;
@property (nonatomic, strong)NSArray *photoMetadatas;
@property (nonatomic, strong)UIImage *coverPhoto;
@property (nonatomic, strong)NSMutableArray *allPhotos;

@property (nonatomic) CLLocationCoordinate2D location;

@property (nonatomic, strong)GMSPlacesClient *placesClient;
@end

@implementation SearchResult
@synthesize coverPhoto = _coverPhoto;

- (instancetype)initWithPlaceId:(NSString *)placeId openNow:(BOOL)openNow distance:(double)distance
{
    self = [super init];
    if (self) {
        _placeId = placeId;
        _coverPhoto = [UIImage imageNamed:@"imageComingSoon.png"];
        _allPhotos = [[NSMutableArray alloc] init];
        _placeDetail = [[PlaceInfo alloc] init];
        _placeDetail.openNow = openNow;
        _placeDetail.distance = distance / 1000;
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
             __typeof__(self) strongSelf = weakSelf;
            [GMSPlacesClient provideAPIKey:@"AIzaSyBOowv0aEr-202j_MYGPIqMXLt4kmRzkJQ"];
            _placesClient = [GMSPlacesClient sharedClient];
            [strongSelf getPlacePhoto];
            [strongSelf getPlaceDetail];
        });
    }
    return self;
}

- (PlaceInfo *)placeInfo {
    [self loadAllPhotos];
    return _placeDetail;
}

- (void)getPlaceDetail {
    [_placesClient lookUpPlaceID:_placeId callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
        if (result) {
            _placeDetail.name = result.name;
            _placeDetail.address = result.formattedAddress;
            _placeDetail.phoneNumber = result.phoneNumber;
            _placeDetail.website = result.website.absoluteString;
            _placeDetail.type = result.types.firstObject;
        }
    }];
}

- (void)getPlacePhoto {
    __weak __typeof__(self) weakSelf = self;
    [_placesClient lookUpPhotosForPlaceID:_placeId callback:^(GMSPlacePhotoMetadataList * _Nullable photos, NSError * _Nullable error) {
        if (!error) {
            _photoMetadatas = photos.results;
            GMSPlacePhotoMetadata *coverPhoto = photos.results.firstObject;
            __typeof__(self) strongSelf = weakSelf;
            [strongSelf loadPhoto:coverPhoto];
        }
    }];
}

- (void)loadPhoto:(GMSPlacePhotoMetadata *)photoMetadata {
    [_placesClient loadPlacePhoto:photoMetadata constrainedToSize:coverPhotoSize scale:1.0f callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
        if (!error) {
            _coverPhoto = photo;
            [[NSNotificationCenter defaultCenter] postNotificationName:initialPhotoReady object:nil];
        }
    }];
}

- (void)loadAllPhotos {
    for (GMSPlacePhotoMetadata *photoMetada in _photoMetadatas) {
        [_placesClient loadPlacePhoto:photoMetada constrainedToSize:photoSize scale:1.0f callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
            if (!error) {
                [_allPhotos addObject:photo];
                [[NSNotificationCenter defaultCenter] postNotificationName:newPhotoData object:nil userInfo:@{@"photos": _allPhotos}];
            }
        }];
    }
}

@end
