//
//  SELibrary.h
//  Rhythmus
//
//  Created by Admin on 12/08/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString*const kLibraryFileName = @"LibraryFileName";
static NSString*const kLibraryFileURL = @"LibraryFileURL";

@interface SELibrary : NSObject

@property (nonatomic, strong) NSMutableArray* sampleCache;
@property (nonatomic, strong) NSMutableArray* patternCache;

+ (instancetype)sharedLibrary;

@end
