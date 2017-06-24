//
//  NSDictionary+Extension.m
//
//
//  Created by Andy on 2016/11/7.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)

-(NSString *)getString:(NSString *)key {
    NSString *string = [self objectForKey:key];
    if ([string isKindOfClass:[NSString class]]) {
        return string;
    }
    else if([string isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%@",string];
    }
    return @"";
}

-(NSInteger)getInteger:(NSString *)key {
    id obj = [self objectForKey:key];
    
    if ([obj respondsToSelector:@selector(integerValue)]) {
        return [obj integerValue];
    }
    return NSNotFound;
}

-(CGFloat)getDouble:(NSString *)key {
    id obj = [self objectForKey:key];
    
    if ([obj respondsToSelector:@selector(doubleValue)]) {
        return [obj doubleValue];
    }
    return MAXFLOAT;
}

-(BOOL)getBool:(NSString *)key {
    id obj = [self objectForKey:key];
    
    if ([obj respondsToSelector:@selector(boolValue)]) {
        return [obj boolValue];
    }
    return NO;
}

-(NSArray *)getArray:(NSString *)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }
    return [NSArray array];
}

-(NSDictionary *)getDictionary:(NSString *)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return obj;
    }
    return [NSDictionary dictionary];
}

@end


@implementation NSMutableDictionary (setObjectWithType)

-(void)setString:(NSString *)str forKey:(id<NSCopying>)key {
    if (![str isKindOfClass:[NSString class]]) {
        str = @"";
    }
    [self setObject:str forKey:key];
}

-(void)setInteger:(NSInteger)num forKey:(id<NSCopying>)key {
    [self setObject:@(num) forKey:key];
}

-(void)setDouble:(CGFloat)num forKey:(id<NSCopying>)key {
    [self setObject:@(num) forKey:key];
}

@end

@implementation NSDictionary (headDictionary)

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSMutableDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
