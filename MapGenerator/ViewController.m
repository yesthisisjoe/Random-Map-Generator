//
//  ViewController.m
//  MapGenerator
//
//  Created by Joe Peplowski on 2016-02-05.
//  Copyright © 2016 Joseph Peplowski. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *mapCollectionView;
@property (strong, nonatomic) IBOutlet UISlider *numberOfLakesSlider;
@property (strong, nonatomic) IBOutlet UISlider *numberOfLakeTilesSlider;
@property (strong, nonatomic) IBOutlet UISwitch *showIterationsSwitch;

@end

@implementation ViewController

NSInteger tileArray[MAPWIDTH][MAPHEIGHT];
NSInteger numberOfLakes;
NSInteger numberOfLakeTiles;
BOOL showIterations;

NSMutableIndexSet *lakeCandidates = nil;
NSMutableIndexSet *lakeTiles = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mapCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MapTile"];
    
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
    NSInteger x0 = (x+1)%MAPWIDTH;
    NSInteger y0 = y;
    NSInteger x1 = (x-1)%MAPWIDTH;
    NSInteger y1 = y;
    NSInteger x2 = x;
    NSInteger y2 = (y+1)%MAPHEIGHT;
    NSInteger x3 = x;
    NSInteger y3 = (y-1)%MAPHEIGHT;
    
    //protect tiles from negative coordinates
    if (x1 < 0) {
        x1 = MAPWIDTH-1;
    }
    if (y3 < 0) {
        y3 = MAPHEIGHT-1;
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
    return xCoordinate*MAPWIDTH + yCoordinate;
}

NSInteger decodeX(NSInteger encodedCoordinate) {
    NSInteger decodedX = encodedCoordinate / MAPWIDTH;
    
    if (decodedX == MAPWIDTH) {
        return 0;
    } else {
        return decodedX;
    }
}

NSInteger decodeY(NSInteger encodedCoordinate) {
    return encodedCoordinate % MAPHEIGHT;
}

//- (void)chooseCandidate: (NSInteger)lakeTilesRemaining {
//    if (lakeTilesRemaining == 0) {
//        return;
//    }
//    
//    NSInteger randomNum = arc4random_uniform([lakeCandidates count]-1);
//    NSInteger index = [lakeCandidates firstIndex];
//    
//    for (NSUInteger i = 0; i < randomNum; i++) {
//        index = [lakeCandidates indexGreaterThanIndex:index];
//    }
//    
//    createLakeTileWithCandidates(decodeX(index), decodeY(index));
//    
//    if (showIterations) {
//        updateMapDataSource();
//        [[self mapCollectionView] reloadData];
//    }
//    
//    [[self chooseCandidate] lakeTilesRemaining-1];
//}

- (IBAction)generateButton:(id)sender {
    //initialize map with grass (value 1)
    for (NSInteger i = 0; i<MAPWIDTH; i++) {
        for (NSInteger j = 0; j<MAPHEIGHT; j++) {
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
        NSInteger i = arc4random_uniform(MAPWIDTH);
        NSInteger j = arc4random_uniform(MAPWIDTH);
        tileArray[i][j] = 2;
        
        createLakeTileWithCandidates(i, j);
    }
    
    NSInteger randomNum;
    NSInteger index;
    
    //choose a random index from lakeTileCandidates to transform into a lake tile
    for (NSInteger i=0; i<numberOfLakeTiles; i++) {
        randomNum = arc4random_uniform([lakeCandidates count] -1);
        index = [lakeCandidates firstIndex];
        
        for (NSUInteger i = 0; i < randomNum; i++) {
            index = [lakeCandidates indexGreaterThanIndex:index];
        }
        
        createLakeTileWithCandidates(decodeX(index), decodeY(index));
        
        if (showIterations && i%100 == 0) {
            updateMapDataSource();
            [[self mapCollectionView] reloadData];
        }
    }
    
    updateMapDataSource();
    [self.mapCollectionView reloadData];
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

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MAPTILES;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MapTile" forIndexPath:indexPath];
    NSInteger index = indexPath.item;
    
    NSInteger i = index / MAPWIDTH;
    NSInteger j = index % MAPHEIGHT;
    
    switch (tileArray[i][j]) {
        case 1:
            cell.backgroundColor = [UIColor greenColor];
            break;
        case 2:
            cell.backgroundColor = [UIColor cyanColor];
            break;
        case 3:
            cell.backgroundColor = [UIColor blueColor];
            break;
        case 4:
            cell.backgroundColor = [UIColor brownColor];
            break;
        default:
            cell.backgroundColor = [UIColor redColor];
            break;
    }
    
    return cell;
}

@end
