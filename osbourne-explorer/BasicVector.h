//
//  BasicVector.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/17/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef BasicVector_h
#define BasicVector_h

#include <stdio.h>
@import GoogleMaps;

struct Vector {
    CLLocationCoordinate2D a, b, value;
    double length;
};

struct Vector makeVector(CLLocationCoordinate2D a, CLLocationCoordinate2D b);
struct Vector rotateVector(struct Vector a, double rad);
double angleBetweenVectors(struct Vector a, struct Vector b);


#endif /* BasicVector_h */
