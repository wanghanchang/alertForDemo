//
//  NSString+Trim.m
//  Project61
//
//  Created by hzpnc on 15/11/27.
//  Copyright © 2015年 hzpnc. All rights reserved.
//

#import "NSString+Trim.h"

@implementation NSString (Trim)

- (NSString*)trim {
    return [[self trimHeader] trimFooter];
}

- (NSString*)trimHeader {
    if(self.length == 0) {
        return self;
    }
    for(NSInteger indexOfFirstNonSpace = 0; indexOfFirstNonSpace < self.length - 1; indexOfFirstNonSpace++) {
        char c = [self characterAtIndex:indexOfFirstNonSpace];
        if(c != ' ') {
            return [self substringFromIndex:indexOfFirstNonSpace];
        }
    }
    return self;
}

- (NSString*)trimFooter {
    if(self.length == 0) {
        return self;
    }
    for(NSInteger indexOfFirstNonSpace = self.length - 1; indexOfFirstNonSpace > 0; indexOfFirstNonSpace--) {
        char c = [self characterAtIndex:indexOfFirstNonSpace];
        if(c != ' ') {
            return [self substringToIndex:indexOfFirstNonSpace + 1];
        }
    }
    return self;
}

- (NSString*)trimAll {
    if(self.length == 0) {
        return self;
    }
    NSString *strUrl = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    return strUrl;
}

@end
