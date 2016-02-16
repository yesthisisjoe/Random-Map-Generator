//
//  ViewController.h
//  MapGenerator
//
//  Created by Joe Peplowski on 2016-02-05.
//  Copyright © 2016 Joseph Peplowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ViewController : UIViewController
NSInteger encodeCoordinate(NSInteger xCoordinate, NSInteger yCoordinate);
NSInteger decodeX(NSInteger encodedCoordinate);
NSInteger decodeY(NSInteger encodedCoordinate);
void addAdjacent(NSInteger x, NSInteger y);

@end