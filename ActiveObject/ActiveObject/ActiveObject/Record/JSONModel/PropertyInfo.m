//
//  PropertyInfo.m
//  ActiveObject
//
//  Created by Ansel on 2016/10/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "PropertyInfo.h"

@implementation PropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property
{
    self = [super init];
    if (self) {
        [self analyzeProperty:property];
    }
    
    return self;
}

- (void)analyzeProperty:(objc_property_t)property
{
    const char * propertyName = property_getName(property);
    self.propertyName = [NSString stringWithUTF8String:propertyName];
    
    char * type = property_copyAttributeValue(property, "T");
    switch(type[0]) {
        case 'f': //float
        case 'd': {//double
            self.propertyType = @"CGFloat";
            self.databaseType = @"float";
            break;
        }
        case 'c':  // char
        case 's':  //short
        case 'i':  // int
        case 'l':  // long
        case 'q':  // long long
        case 'I':  // unsigned int
        case 'S':  // unsigned short
        case 'L':  // unsigned long
        case 'Q':  // unsigned long long
        case 'B': {// BOOL
            self.propertyType = @"NSInteger";
            self.databaseType = @"integer";
            break;
        }
        case '@': {//ObjC object
            //Handle different clases in here
            NSString *cls = [NSString stringWithUTF8String:type];
            cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
            cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            self.propertyType = cls;
            self.databaseType = @"text";
            break;
        }
        default: {
            self.propertyType = @"NSString";
            self.databaseType = @"text";
        }
    }
}

@end
