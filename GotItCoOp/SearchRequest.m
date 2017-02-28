//
//  SearchRequest.m
//  GotItCoOp
//
//  Created by Catherine Zhao on 2017-02-27.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "SearchRequest.h"

@interface SearchRequestHelper()
@property (nonatomic, strong)NSArray *referenceArray;
@end


@implementation SearchRequestHelper

+ (NSArray*)referenceArray {
    return @[@"none",
             @"amusement_park",
             @"aquarium",
             @"art_gallery",
             @"bakery",
             @"bar",
             @"campground",
             @"casino",
             @"jewelry_store",
             @"movie_theater",
             @"museum",
             @"night_club",
             @"park",
             @"restaurant",
             @"shopping_mall",
             @"spa",
             @"zoo",
             @"gym",
             @"beauty_salon",
             @"clothing_store",
             @"electronics_store",
             @"stadium",
             @"shoe_store",
             @"lodging"];
}

+ (NSString *)stringForCategoryType:(CATEGORY)type {
    if (type > 24) {
        return  nil;
    }else {
        return [[self class] referenceArray][type];
    }
}

@end
