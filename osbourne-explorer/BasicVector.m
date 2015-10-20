//
//  BasicVector.c
//  osbourne-explorer
//
//  Created by shdwprince on 10/17/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#include "BasicVector.h"

struct Vector makeVector(CLLocationCoordinate2D a, CLLocationCoordinate2D b) {
    struct Vector result;
    result.a = a;
    result.b = b;
    result.length = sqrt(pow(b.longitude - a.longitude, 2) + pow(b.latitude - a.latitude, 2));
    result.value = CLLocationCoordinate2DMake(b.latitude - a.latitude, b.longitude - a.longitude);
    return result;
}

struct Vector rotateVector(struct Vector vec, double rad) {
    CLLocationCoordinate2D b = CLLocationCoordinate2DMake(vec.b.latitude - vec.a.latitude, vec.a.longitude - vec.b.longitude);
    double sa = sin(rad);
    double ca = cos(rad);
    CLLocationCoordinate2D turned_point = CLLocationCoordinate2DMake(ca * b.latitude - sa * b.longitude, sa * b.latitude + ca * b.longitude);

    return makeVector(vec.a, CLLocationCoordinate2DMake(turned_point.latitude + vec.a.latitude, vec.a.longitude - turned_point.longitude));
}

double angleBetweenVectors(struct Vector a, struct Vector b) {
    double dot = a.value.longitude * b.value.longitude + a.value.latitude * b.value.latitude;
    double det = a.value.longitude * b.value.latitude - a.value.latitude * b.value.longitude;
    return atan2(det, dot);
}