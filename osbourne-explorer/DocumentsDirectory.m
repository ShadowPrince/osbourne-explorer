//
//  DocumentsDirectory.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/20/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "DocumentsDirectory.h"

@implementation DocumentsDirectory

+ (NSString *) documentsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    return documentsDirectory;
}

+ (NSString *) pathFor:(NSString *)filename {
    return [[DocumentsDirectory documentsDirectoryPath] stringByAppendingString:filename];
}

@end
