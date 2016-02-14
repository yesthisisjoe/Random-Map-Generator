//
//  ViewController.h
//  MapGenerator
//
//  Created by Joe Peplowski on 2016-02-05.
//  Copyright © 2016 Joseph Peplowski. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAPWIDTH 150
#define MAPHEIGHT 150
#define MAPTILES MAPWIDTH * MAPHEIGHT

@interface ViewController : UIViewController

NSInteger encodeCoordinate(NSInteger xCoordinate, NSInteger yCoordinate);
NSInteger decodeX(NSInteger encodedCoordinate);
NSInteger decodeY(NSInteger encodedCoordinate);
void addAdjacent(NSInteger x, NSInteger y);
- (void)chooseCandidate: (NSInteger)lakeTilesRemaining;

@end