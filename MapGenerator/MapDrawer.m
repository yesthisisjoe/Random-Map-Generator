//
//  MapDrawer.m
//  MapGenerator
//
//  Created by Joe Peplowski on 2016-02-15.
//  Copyright © 2016 Joseph Peplowski. All rights reserved.
//

#import "MapDrawer.h"
#import "Constants.h"

@implementation MapDrawer

- (void)drawRect:(CGRect)rect {
    for (int i=0; i<mapWidth; i++) {
        for (int j=0; j<mapHeight; j++) {
            CGRect rectangle = CGRectMake(i, j, 1, 1);
            CGContextRef context = UIGraphicsGetCurrentContext();

                switch (_tileArray[i][j]) {
                    case 1:
                        CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 1.0);
                        break;
                    case 2:
                        CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
                        break;
                    case 3:
                        CGContextSetRGBFillColor(context, 0.0, 1.0, 1.0, 1.0);
                        break;
                    case 4:
                        CGContextSetRGBFillColor(context, 20.0/255.0, 51.0/255.0, 6.0/255.0, 1.0);
                        break;
                    default:
                        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
                        break;
                }
            
            //CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
            CGContextFillRect(context, rectangle);
        }
    }
}

@end
