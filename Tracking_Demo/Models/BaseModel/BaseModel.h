//
//  BaseModel.h
//  所有的数据模型都继承此类，这是一个基类。
//  解析json给数据模型赋值时可以直接调用 initWithDictionary: 方法
//
//  Created by Andy on 15/6/8.
//  Copyright © 2015年 FL-Smart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseStrongModel.h"

//模型基类，自带一个使用字典创建对象的方法
@interface BaseModel : NSObject

/**
 根据字典初始化获取模型数据

 @param dict 原始字典
 @return 返回已解析好的模型
 */
+(id)initWithDictionary:(NSDictionary *)dict;

/**
 模型转字典

 @return 返回转好的字典
 */
-(NSDictionary *)dictionaryByModel;

/**
 向模型中的数组属性赋值一个数组数据源的方法,必须保证key值名字的属性在模型中存在并且为数组

 @param dataArray 属性数组
 @param class 属性数组从要存储的模型
 @param key 提取数组的KEY
 */
-(void)addSubModelToArrayWithDictionary:(NSArray *)dataArray Model:(Class)class Key:(NSString *)key;
@end
