//
//  SearchResult.h
//  GotItCoOp
//
//  Created by Catherine Zhao on 2017-02-27.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GooglePlaces/GooglePlaces.h>

@interface PlaceInfo : NSObject
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *address;
@property (nonatomic) BOOL openNow;
@property (nonatomic) double distance;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong)NSString *phoneNumber;
@property (nonatomic, strong)NSString *website;
@property (nonatomic, strong)NSString *type;
@end

@interface SearchResult : NSObject
- (instancetype)initWithPlaceId:(NSString *)placeId openNow:(BOOL)openNow distance:(double)distance coordinate:(CLLocationCoordinate2D)coordinate;
- (PlaceInfo *)placeInfo;
@property (nonatomic, strong, readonly)UIImage *coverPhoto;
@end
