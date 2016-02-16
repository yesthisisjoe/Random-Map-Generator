//
//  ViewController.m
//  MapGenerator
//
//  Created by Joe Peplowski on 2016-02-05.
//  Copyright © 2016 Joseph Peplowski. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import "MapDrawer.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UISlider *numberOfLakesSlider;
@property (strong, nonatomic) IBOutlet UISlider *numberOfLakeTilesSlider;
@property (strong, nonatomic) IBOutlet UISwitch *showIterationsSwitch;

@end

@implementation ViewController

NSInteger numberOfLakes;
NSInteger numberOfLakeTiles;
BOOL showIterations;
uint8_t tileArray[375][375];
MapDrawer *mapDrawer;

NSMutableIndexSet *lakeCandidates = nil;
NSMutableIndexSet *lakeTiles = nil;

- (void)viewDidLoad {
    [super viewDidLoad];

    numberOfLakes = _numberOfLakesSlider.value;
    numberOfLakeTiles = _numberOfLakeTilesSlider.value;
    showIterations = _showIterationsSwitch.on;
}

void createLakeTileWithCandidates(NSInteger x, NSInteger y) {
    //add our coordinate to lake tiles
    NSInteger lakeInteger = encodeCoordinate(x, y);
    if (![lakeTiles containsIndex: lakeInteger]) {
        [lakeTiles addIndex: lakeInteger];
    }
    
    //remove the new lake coordinate from candidates if it's there
    if ([lakeCandidates containsIndex: lakeInteger]) {
        [lakeCandidates removeIndex: lakeInteger];
    }
    
    //calculate adjacent tiles
    NSInteger x0 = (x+1)%mapWidth;
    NSInteger y0 = y;
    NSInteger x1 = (x-1)%mapWidth;
    NSInteger y1 = y;
    NSInteger x2 = x;
    NSInteger y2 = (y+1)%mapHeight;
    NSInteger x3 = x;
    NSInteger y3 = (y-1)%mapHeight;
    
    //protect tiles from negative coordinates
    if (x1 < 0) {
        x1 = mapWidth-1;
    }
    if (y3 < 0) {
        y3 = mapHeight-1;
    }
    
    //encodes coordinate & stores in lake candidates array
    NSInteger encodedCoordinate0 =  encodeCoordinate(x0, y0);
    NSInteger encodedCoordinate1 =  encodeCoordinate(x1, y1);
    NSInteger encodedCoordinate2 =  encodeCoordinate(x2, y2);
    NSInteger encodedCoordinate3 =  encodeCoordinate(x3, y3);
    
    if (![lakeCandidates containsIndex: encodedCoordinate0] && ![lakeTiles containsIndex: encodedCoordinate0]) {
        [lakeCandidates addIndex: encodedCoordinate0];
    }
    if (![lakeCandidates containsIndex: encodedCoordinate1] && ![lakeTiles containsIndex: encodedCoordinate1]) {
        [lakeCandidates addIndex: encodedCoordinate1];
    }
    if (![lakeCandidates containsIndex: encodedCoordinate2] && ![lakeTiles containsIndex: encodedCoordinate2]) {
        [lakeCandidates addIndex: encodedCoordinate2];
    }
    if (![lakeCandidates containsIndex: encodedCoordinate3] && ![lakeTiles containsIndex: encodedCoordinate3]) {
        [lakeCandidates addIndex: encodedCoordinate3];
    }
}

void updateMapDataSource() {
    [lakeTiles enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        tileArray[decodeX(index)][decodeY(index)] = 3;
        [lakeTiles removeIndex: index];
    }];
    
    [lakeCandidates enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        tileArray[decodeX(index)][decodeY(index)] = 2;
        [lakeCandidates removeIndex: index];
    }];
}

NSInteger encodeCoordinate(NSInteger xCoordinate, NSInteger yCoordinate) {
    return xCoordinate*mapWidth + yCoordinate;
}

NSInteger decodeX(NSInteger encodedCoordinate) {
    NSInteger decodedX = encodedCoordinate / mapWidth;
    
    if (decodedX == mapWidth) {
        return 0;
    } else {
        return decodedX;
    }
}

NSInteger decodeY(NSInteger encodedCoordinate) {
    return encodedCoordinate % mapHeight;
}

- (IBAction)generateButton:(id)sender {
    //initialize map with grass (value 1)
    for (NSInteger i = 0; i<mapWidth; i++) {
        for (NSInteger j = 0; j<mapHeight; j++) {
            if (arc4random_uniform(5) == 1) {
                tileArray[i][j] = 4;
            } else {
                tileArray[i][j] = 1;
            }
        }
    }
    
    lakeCandidates = [NSMutableIndexSet indexSet];
    lakeTiles = [NSMutableIndexSet indexSet];
    
    //choose random spots on the map where lakes tiles appear
    for (NSInteger l=0; l<numberOfLakes; l++) {
        NSInteger i = arc4random_uniform((uint32_t) mapWidth);
        NSInteger j = arc4random_uniform((uint32_t) mapWidth);
        tileArray[i][j] = 2;
        
        createLakeTileWithCandidates(i, j);
    }
    
    NSInteger randomNum;
    NSInteger index;
    
    //choose a random index from lakeTileCandidates to transform into a lake tile
    for (NSInteger i=0; i<numberOfLakeTiles; i++) {
        randomNum = arc4random_uniform((uint32_t) [lakeCandidates count] -1);
        index = [lakeCandidates firstIndex];
        
        for (NSUInteger i = 0; i < randomNum; i++) {
            index = [lakeCandidates indexGreaterThanIndex:index];
        }
        
        createLakeTileWithCandidates(decodeX(index), decodeY(index));
        
        if (showIterations && i%100 == 0) {
            updateMapDataSource();
        }
    }
    
    updateMapDataSource();
    [self drawMap];
}

-(void)drawMap{
    mapDrawer = [[MapDrawer alloc] init];
    uint8_t (*tileArrayPtr)[375] = tileArray;
    mapDrawer.tileArray = tileArrayPtr;
    [mapDrawer setFrame:CGRectMake(0, 0, 375, 375)];
    [self.view addSubview: mapDrawer];
}

- (IBAction)numberOfLakesSlider:(id)sender {
    numberOfLakes = _numberOfLakesSlider.value;
}

- (IBAction)numberOfLakeTilesSlider:(id)sender {
    numberOfLakeTiles = _numberOfLakeTilesSlider.value;
}

- (IBAction)showIterationsSwitch:(id)sender {
    showIterations = _showIterationsSwitch.on;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
