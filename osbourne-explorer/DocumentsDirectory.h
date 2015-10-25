//
//  DocumentsDirectory.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/20/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentsDirectory : NSObject

+ (NSString *) pathFor:(NSString *) filename;
+ (NSString *) documentsDirectoryPath;

@end
