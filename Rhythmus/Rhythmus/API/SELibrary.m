//
//  SELibrary.m
//  Rhythmus
//
//  Created by Admin on 14/08/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SELibrary.h"

@interface SELibrary ()

-(NSArray*)nestedContentsOfDirectory:(NSString*)path;

@end



@implementation SELibrary

-(instancetype)init
{
    if(self = [super init]){
        _sampleCache = [[NSMutableArray alloc]init];
        _patternCache = [[NSMutableArray alloc]init];
        
        
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
        NSArray* content = [self nestedContentsOfDirectory:path];
        for(NSString* filePath in content){
            NSString* fileName = [[filePath pathComponents] lastObject];
            NSString* extention = [filePath pathExtension];
            if([extention isEqualToString:@"wav"]){
                [_sampleCache addObject:@{ kLibraryFileName :  fileName,
                                           kLibraryFileURL : [NSURL fileURLWithPath:filePath] }];
            } else if([extention isEqualToString:@"pattern"]){
                [_patternCache addObject:@{ kLibraryFileName :  fileName,
                                            kLibraryFileURL : [NSURL fileURLWithPath:filePath] }];
            }
            
        }
    }
    return self;
    
}

+ (instancetype)sharedLibrary
{
    static SELibrary *instance = nil;
    if (instance == nil) {
        instance = [[self alloc] init];
    }
    
    return instance;
}

-(NSArray*)nestedContentsOfDirectory:(NSString*)directoryPath{
    NSArray* localContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    NSMutableArray* mutableNestedContents = [[NSMutableArray alloc]init];
    
    for(NSString* pathComponent in localContents){
        
        NSString* nestedContent = [directoryPath stringByAppendingPathComponent:pathComponent];
        if([[[NSFileManager defaultManager] attributesOfItemAtPath:nestedContent error:nil] objectForKey:NSFileType] == NSFileTypeDirectory){
            NSArray* subContents = [self nestedContentsOfDirectory:nestedContent];
            for(NSString* subContent in subContents){
                [mutableNestedContents addObject:[nestedContent stringByAppendingString:subContent]];
            }
        } else {
            [mutableNestedContents addObject:nestedContent];
        }
    }
    return [mutableNestedContents copy];
}

@end

