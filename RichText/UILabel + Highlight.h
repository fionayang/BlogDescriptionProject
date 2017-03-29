//
//  Highlight.h
//
//
//  Created by Fiona on 7/28/15.
//  Copyright (c) 2015 fiona, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Highlight)

/*
 Specific highlight color is blue
 */
- (void)highlightString:(NSString *)str;


/*
 eg: xxxx<em>xxxx</em>xxxxx<em>xxxx</em>xxxxx<em>xxxx</em>xxxxx   ---> originStr
 起始标识: <em>  ---> beginTag
 结束标识: </em> ---> endTag
 目的：高亮在<em>和</em>中间部分的子串
 
 中间关键变量定于：
 1. tagArr: array of NSRange, 用于标识出originStr中所有成对出现的beginTag和endTag讯息
 2. strArr: array of NSRange, 最终画在label上的string
 3. colorArr: array of NSRange, 标识所有高亮位置
 
 关键问题是：如何高效算出tagArr？
 我目前做法是：从originStr的index=0开始成对找第一对的beginTag和endTag信息，然后将index赋值到第一个endTag的位置找第二对，以此类推。
 
 
 TBO: 
 1. .m中定义了TagStructure，这个类可以使上面计算tagArr，代码可读行变高。TagStructure.filterSubstr为最终需要高亮显示的子串
 2. 当前实现用到SCRange，现在再去看有点鸡肋
 */
- (void)highlightWithTagString:(NSString *)str;
+ (NSString *)cleanTag:(NSString *)str;




@end
