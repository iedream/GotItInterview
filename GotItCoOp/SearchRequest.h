//
//  SearchRequest.h
//  GotItCoOp
//
//  Created by Catherine Zhao on 2017-02-27.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NONE,
    AMUSEMENT_PARK,
    AQUARIUM,
    ART_GALLERY,
    BAKERY,
    BAR,
    CAMPGROUND,
    CASINO,
    JEWELRY_STORE,
    MOVIEW_THEATER,
    MUSEUM,
    NIGHT_CLUB,
    PARK,
    RESTAURANT,
    SHOPPING_MALL,
    SPA,
    ZOO,
    GYM,
    BEAUTY_SALON,
    CLOTHING_STORE,
    ELECTRONICS_STORE,
    STADIUM,
    SHOE_STORE,
    LODGING
}CATEGORY;

typedef enum {
    RANK_BY_PROMINENCE,
    RANK_BY_DISTANCE
}RANK;

typedef struct {
    BOOL hasBoundary;
    int radius;
    BOOL hasType;
    CATEGORY type;
    BOOL wantOpenNow;
    RANK rank;
}SearchRequest;

@interface SearchRequestHelper : NSObject
+ (NSString *)stringForCategoryType:(CATEGORY)type;
+ (NSArray*)referenceArray;
@end
