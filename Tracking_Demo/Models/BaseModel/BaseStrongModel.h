//
//  BaseStrongModel.h
//  模型自动赋值试验1
//
//  Created by Andy on 15/6/8.
//  Copyright © 2015年 FL-Smart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseStrongModel : NSObject
/**
 *  需要建立一个模型，属性名称和类型应当与字典的相应key相同，将模型对象、数据字典、想赋值的class传入方法，可自动赋值。
 *  名称或类型不符的将不会被赋值。只保证JSON解析结果中的类型（string,array,dictionary,bool,number）赋值正确。
 *  对于模型的一对一嵌套可以递归赋值（即字典中的一个值为子字典，模型中相应的属性为子模型,可以递归赋值.字典套数组有空再写...）
 *
 *  ! 在类型不符的情况下，NSNumber和NSString类型会被相互转化赋值(模型中的int,float等算作是NSNumber类型)
 *
 *
 *  @param dic    数据字典
 *  @param mClass 要赋值的对象的class,class可以是这个类本身，也可以是它的父类的，增加这个参数是考虑到对继承自父类的那部分的属性赋值
 *  @param model  要赋值的模型对象
 *  @param open   是否开启递归赋值
 *  @return 成功返回model本身，传入参数有误返回nil
 *
 */
+(NSObject *)ModelAttributeAutomaticAssignment:(NSDictionary *)dic kindOfClass:(Class)mClass ToModel:(NSObject *)model openRecursive:(BOOL)open;

/**
 *  带改名字典的自动赋值，键值对为 新属性名:原属性名（即数据字典key值）
 *  @param dic    数据字典
 *  @param mClass 要赋值的对象的class,class可以是这个类本身，也可以是它的父类的，增加这个参数是考虑到对继承自父类的那部分的属性赋值
 *  @param model  要赋值的模型对象
 *  @param nameDic 改名字典
 *  @param open   是否开启递归赋值
 *  @return 成功返回model本身，传入参数有误返回nil
 */
+(NSObject *)ModelAttributeAutomaticAssignment:(NSDictionary *)dic kindOfClass:(Class)mClass ToModel:(NSObject *)model WithNameDictionary:(NSDictionary *)nameDic openRecursive:(BOOL)open;

/**
 *  测试中，模型转字典
 *  C的基本数据类型int,double等会自动转为NSNumber存入字典
 *
 *  @param model 需要转成字典的模型对象
 *  @param mClass 参照的Class
 *  @param nameDic 改名字典
 *
 *  @return 返回一个 属性名:属性值 的字典
 */
+(NSDictionary *)dictionaryForModelAttribute:(NSObject *)model kindOfClass:(Class)mClass WithNameDictionary :(NSDictionary *)nameDic;


@end
