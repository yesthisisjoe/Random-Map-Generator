//
//  MapDrawer.h
//  MapGenerator
//
//  Created by Joe Peplowski on 2016-02-15.
//  Copyright © 2016 Joseph Peplowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapDrawer : UIView
@property (nonatomic) uint8_t (*tileArray)[375];
@end
