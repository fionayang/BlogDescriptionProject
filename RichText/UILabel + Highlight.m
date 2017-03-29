//
//  Highlight.m
//  
//
//  Created by Fiona on 7/28/15.
//  Copyright (c) 2015 fiona, Inc. All rights reserved.
//

#import "UILabel + Highlight.h"

@interface SCRange : NSObject

@property (nonatomic, assign) NSUInteger location;
@property (nonatomic, assign) NSUInteger length;

+ (instancetype)location:(NSUInteger)location length:(NSUInteger)length;

@end

@implementation SCRange

+ (instancetype)location:(NSUInteger)location length:(NSUInteger)length
{
    SCRange *range = [[SCRange alloc] init];
    range.location = location;
    range.length = length-location;
    return range;
}

@end

@interface TagStructure : NSObject

@property (nonatomic, strong) NSString *beginTag;
@property (nonatomic, strong) NSString *endTage;
@property (nonatomic, strong) NSString *filterSubstr;

@end

@implementation TagStructure


@end

@implementation UILabel (Highlight)

- (void)highlightString:(NSString *)str
{
    if (self.text.length <= 0 || str.length <= 0) {
        return;
    }
    
    NSString *scopeStr = self.text;
    NSRange range = [scopeStr rangeOfString:str options:NSCaseInsensitiveSearch];
    
    //color
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:scopeStr];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
    
    [self setAttributedText:attributedStr];
}


- (void)highlightWithTagString:(NSString *)str
{
    if (![str isKindOfClass:[NSString class]] || str.length <= 0) {
        self.text = @"";
        return;
    }
    
    NSString *beginTag = @"<em>";
    NSString *endTag = @"</em>";
    NSInteger beginLocation = 0;
    NSInteger strLength = str.length;
    NSInteger searchLength = strLength - beginLocation;
    NSUInteger location1 = NSNotFound;
    NSUInteger location2 = NSNotFound;
    BOOL flag = NO;
    NSMutableArray *tagArray = [NSMutableArray arrayWithCapacity:0];
    
    //找到标签所在位置
    do {
        
        location1 = [str rangeOfString:beginTag options:NSLiteralSearch range:NSMakeRange(beginLocation, searchLength)].location;
        location2 = [str rangeOfString:endTag options:NSLiteralSearch range:NSMakeRange(beginLocation, searchLength)].location;
        
        if (location1 != NSNotFound && location2 != NSNotFound) {
            
            [tagArray addObject:@(location1)];
            [tagArray addObject:@(location2)];
        }
        
        beginLocation = location2 + endTag.length;
        searchLength = strLength - beginLocation;;
        flag = location1 != NSNotFound && location2 != NSNotFound && searchLength > 0;
        
    } while (flag);
    
    if (tagArray.count <= 0) {
        self.text = str;
        return;
    }
    
    NSMutableArray *stringArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:0];
    
    SCRange *range = [SCRange location:0 length:[tagArray[0] unsignedIntegerValue]];
    [stringArray addObject:range];
    
    for (NSUInteger i=0; i<tagArray.count-1; ++i) {
        
        NSUInteger beforeLoc = [tagArray[i] unsignedIntegerValue];
        NSUInteger afterLoc = [tagArray[i+1] unsignedIntegerValue];
        
        if (i % 2 == 0) {
            SCRange *stringRange = [SCRange location:beforeLoc+beginTag.length length:afterLoc];
            [stringArray addObject:stringRange];
        } else {
            SCRange *stringRange = [SCRange location:beforeLoc+endTag.length length:afterLoc];
            [stringArray addObject:stringRange];
        }
    }
    
    if ([[tagArray lastObject] unsignedIntegerValue]+endTag.length < strLength) {//最后一串
        NSUInteger beforeLoc = [[tagArray lastObject] unsignedIntegerValue];
        SCRange *stringRange = [SCRange location:beforeLoc+endTag.length length:strLength];
        [stringArray addObject:stringRange];
    }
    
    for (NSUInteger i=1; i<stringArray.count; i+=2) {
        
        SCRange *stringRange = stringArray[i];
        
        SCRange *colorRange = [[SCRange alloc] init];
        colorRange.location = stringRange.location - beginTag.length - (i-1)*(beginTag.length + endTag.length)/2;
        colorRange.length = stringRange.length;
        [colorArray addObject:colorRange];
    }
    
    //去标签
    NSMutableString *mStr = [NSMutableString stringWithCapacity:0];
    for (SCRange *temp in stringArray) {
        [mStr appendString:[str substringWithRange:NSMakeRange(temp.location, temp.length)]];
    }
    
    //上色
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:mStr];
    for (SCRange *temp in colorArray) {
        NSRange range = NSMakeRange(temp.location, temp.length);
        [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
    }
    
    [self setAttributedText:attributedStr];
}


+ (NSString *)cleanTag:(NSString *)str
{
    if (![str isKindOfClass:[NSString class]] || str.length <= 0) {
        return str;
    }
    
    NSString *beginTag = @"<em>";
    NSString *endTag = @"</em>";
    NSInteger beginLocation = 0;
    NSInteger strLength = str.length;
    NSInteger searchLength = strLength - beginLocation;
    NSUInteger location1 = NSNotFound;
    NSUInteger location2 = NSNotFound;
    BOOL flag = NO;
    NSMutableArray *tagArray = [NSMutableArray arrayWithCapacity:0];
    
    //找到标签所在位置
    do {
        
        location1 = [str rangeOfString:beginTag options:NSLiteralSearch range:NSMakeRange(beginLocation, searchLength)].location;
        location2 = [str rangeOfString:endTag options:NSLiteralSearch range:NSMakeRange(beginLocation, searchLength)].location;
        
        if (location1 != NSNotFound && location2 != NSNotFound) {
            
            [tagArray addObject:@(location1)];
            [tagArray addObject:@(location2)];
        }
        
        beginLocation = location2 + endTag.length;
        searchLength = strLength - beginLocation;;
        flag = location1 != NSNotFound && location2 != NSNotFound && searchLength > 0;
        
    } while (flag);
    
    if (tagArray.count <= 0) {
        return str;
    }
    
    NSMutableArray *stringArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:0];
    
    SCRange *range = [SCRange location:0 length:[tagArray[0] unsignedIntegerValue]];
    [stringArray addObject:range];
    
    for (NSUInteger i=0; i<tagArray.count-1; ++i) {
        
        NSUInteger beforeLoc = [tagArray[i] unsignedIntegerValue];
        NSUInteger afterLoc = [tagArray[i+1] unsignedIntegerValue];
        
        if (i % 2 == 0) {
            SCRange *stringRange = [SCRange location:beforeLoc+beginTag.length length:afterLoc];
            [stringArray addObject:stringRange];
        } else {
            SCRange *stringRange = [SCRange location:beforeLoc+endTag.length length:afterLoc];
            [stringArray addObject:stringRange];
        }
    }
    
    if ([[tagArray lastObject] unsignedIntegerValue]+endTag.length < strLength) {//最后一串
        NSUInteger beforeLoc = [[tagArray lastObject] unsignedIntegerValue];
        SCRange *stringRange = [SCRange location:beforeLoc+endTag.length length:strLength];
        [stringArray addObject:stringRange];
    }
    
    for (NSUInteger i=1; i<stringArray.count; i+=2) {
        
        SCRange *stringRange = stringArray[i];
        
        SCRange *colorRange = [[SCRange alloc] init];
        colorRange.location = stringRange.location - beginTag.length - (i-1)*(beginTag.length + endTag.length)/2;
        colorRange.length = stringRange.length;
        [colorArray addObject:colorRange];
    }
    
    //去标签
    NSMutableString *mStr = [NSMutableString stringWithCapacity:0];
    for (SCRange *temp in stringArray) {
        [mStr appendString:[str substringWithRange:NSMakeRange(temp.location, temp.length)]];
    }
    return mStr;
}

@end
