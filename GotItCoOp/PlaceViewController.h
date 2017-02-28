//
//  PlaceViewController.h
//  GotItCoOp
//
//  Created by Catherine Zhao on 2017-02-27.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResult.h"

@interface PlaceViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong)PlaceInfo *placeInfo;
@end
