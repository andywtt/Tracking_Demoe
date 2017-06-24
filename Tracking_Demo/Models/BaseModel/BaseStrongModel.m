//
//  BaseStrongModel.m
//  模型自动赋值试验1
//
//  Created by Andy on 15/6/8.
//  Copyright © 2015年 FL-Smart. All rights reserved.
//

#import "BaseStrongModel.h"
#import <objc/runtime.h>


@interface BaseStrongModel()

@end
@implementation BaseStrongModel

#pragma mark - ModelAttributeAutomaticAssignment
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
+(NSObject *)ModelAttributeAutomaticAssignment:(NSDictionary *)dic  kindOfClass:(Class)mClass ToModel:(NSObject *)model openRecursive:(BOOL)open {
    /**
     *  模型，字典，class不对都直接返回
     */
    if (!model || ![dic isKindOfClass:[NSDictionary class]] || ![model isKindOfClass:mClass]) {
        return nil;
    }
    
    NSDictionary * attrDic = [self property:mClass];//获取模型的属性字典
    
    NSArray * nameArr = [attrDic allKeys];
    
    for (NSString * key in nameArr) {
        
        //获得数据字典中attrKey对应的值的class，获得模型字典中key值对应的class
        Class dicObjectValue = [dic[key] class];
        Class modelAttrValue = NSClassFromString(attrDic[key]);
        
        //针对JSON中的数据类型可以赋一个默认值
        if ([modelAttrValue isSubclassOfClass:[NSString class]] && ![model valueForKey:key]) {
            [model setValue:@"" forKey:key];
        }
        if ([modelAttrValue isSubclassOfClass:[NSNumber class]] && ![model valueForKey:key]) {
            [model setValue:@(0) forKey:key];
        }
        if ([modelAttrValue isSubclassOfClass:[NSArray class]] && ![model valueForKey:key]) {
            [model setValue:[NSArray array] forKey:key];
        }
        if ([modelAttrValue isSubclassOfClass:[NSDictionary class]] && ![model valueForKey:key]) {
            [model setValue:[NSDictionary dictionary] forKey:key];
        }
        
        //如果数据字典属性类型和模型属性类型相同，直接赋值
        if ([dicObjectValue isSubclassOfClass:modelAttrValue]) {
            [model setValue:dic[key] forKey:key];
            
        }
        else
        {   //NSString 和 NSNumber 可以互相转换
            if ([dicObjectValue isSubclassOfClass:[NSString class]] &&
                [modelAttrValue isSubclassOfClass:[NSNumber class]])
            {
                NSNumber * number = [[[NSNumberFormatter alloc] init] numberFromString:dic[key]];
                
                if (number) {
                    [model setValue:number forKey:key];
                    
                }
                
            }
            else if ([dicObjectValue isSubclassOfClass:[NSNumber class]] &&
                     [modelAttrValue isSubclassOfClass:[NSString class]])
            {
                
                NSString * string = [NSString stringWithFormat:@"%@",dic[key]];
                [model setValue:string forKey:key];
                
            }
            /**
             *  如果递归赋值开启，数据字典当前值的类型为字典，则
             *  ! 默认模型的当前属性为子模型  对这个属性的类型创建一个对象并递归赋值
             *  ! 如果模型中当前属性不是相应的子模型，可能导致崩溃
             *  @param open 是否开启递归赋值
             *
             *
             */
            else if (open && [dicObjectValue isSubclassOfClass:[NSDictionary class]])
            {
                NSObject * obj = [[modelAttrValue alloc] init];
                if (obj) {
                    [self ModelAttributeAutomaticAssignment:dic[key]  kindOfClass:[obj class] ToModel:obj openRecursive:YES];
                    [model setValue:obj forKey:key];
                }
            }
        }
    }
    
    return model;
}

/**
 *  带改名字典的自动赋值，键值对为 新属性名:原属性名（即数据字典key值）
 *  @param dic    数据字典
 *  @param mClass 要赋值的对象的class,class可以是这个类本身，也可以是它的父类的，增加这个参数是考虑到对继承自父类的那部分的属性赋值
 *  @param model  要赋值的模型对象
 *  @param nameDic 改名字典
 *  @param open   是否开启递归赋值
 *  @return 成功返回model本身，传入参数有误返回nil
 */
+(NSObject *)ModelAttributeAutomaticAssignment:(NSDictionary *)dic  kindOfClass:(Class)mClass ToModel:(NSObject *)model WithNameDictionary:(NSDictionary *)nameDic openRecursive:(BOOL)open {
    /**
     *  模型，字典，class不对都直接返回
     */
    if (!model || ![dic isKindOfClass:[NSDictionary class]] || ![model isKindOfClass:mClass]) {
        return nil;
    }
    
    NSDictionary * attrDic = [self property:mClass];//获取模型的属性字典
    
    NSArray * nameArr = [attrDic allKeys];//取得所有属性名
    
    for (int i = 0;i < nameArr.count; i++) {//循环赋值
        NSString * key = nameArr[i];//模型属性名
        NSString * attrKey = key;   //数据字典属性名，默认和模型属性名相同
        if (nameDic) {              //如果改名字典中有相应的模型属性名，则修改数据字典属性名
            if (nameDic[key]) {
                attrKey = nameDic[key];
            }
        }
        //获得数据字典中attrKey对应的值的class，获得模型字典中key值对应的class
        Class dicObjectValue = [dic[attrKey] class];
        Class modelAttrValue = NSClassFromString(attrDic[key]);

        //针对JSON中的数据类型可以赋一个默认值
        if ([modelAttrValue isSubclassOfClass:[NSString class]] && ![model valueForKey:key]) {
            [model setValue:@"" forKey:key];
        }
        if ([modelAttrValue isSubclassOfClass:[NSNumber class]] && ![model valueForKey:key]) {
            [model setValue:@(0) forKey:key];
        }
        if ([modelAttrValue isSubclassOfClass:[NSArray class]] && ![model valueForKey:key]) {
            [model setValue:[NSMutableArray array] forKey:key];
        }
        if ([modelAttrValue isSubclassOfClass:[NSDictionary class]] && ![model valueForKey:key]) {
            [model setValue:[NSMutableDictionary dictionary] forKey:key];
        }

        
        if (dicObjectValue == nil) {        //如果数据字典中没有取到值，直接忽略
            continue;
        }
        //如果数据字典属性类型和模型属性类型相同，直接赋值
        if ([dicObjectValue isSubclassOfClass:modelAttrValue]) {
            [model setValue:dic[attrKey] forKey:key];
            
        }
        else
        {   //NSString 和 NSNumber 可以互相转换
            if ([dicObjectValue isSubclassOfClass:[NSString class]] &&
                [modelAttrValue isSubclassOfClass:[NSNumber class]])
            {
                NSNumber * number = [[[NSNumberFormatter alloc] init] numberFromString:dic[attrKey]];
                
                if (number) {
                    [model setValue:number forKey:key];
                    
                }
                
            }
            else if ([dicObjectValue isSubclassOfClass:[NSNumber class]] &&
                     [modelAttrValue isSubclassOfClass:[NSString class]])
            {
                
                NSString * string = [NSString stringWithFormat:@"%@",dic[attrKey]];
                [model setValue:string forKey:key];
                
            }
            /**
             *  如果递归赋值开启，数据字典当前值的类型为字典，则
             *  ! 默认模型的当前属性为子模型  创建一个子对象并递归赋值
             *  ! 如果模型中当前属性不是相应的子模型，可能导致崩溃
             *  @param open 是否开启递归赋值
             *
             *
             */
            else if (open && [dicObjectValue isSubclassOfClass:[NSDictionary class]])
            {
                NSObject * obj = [[modelAttrValue alloc] init];
                if (obj) {
                    [self ModelAttributeAutomaticAssignment:dic[attrKey]  kindOfClass:[obj class] ToModel:obj WithNameDictionary:nameDic openRecursive:YES];
                    [model setValue:obj forKey:key];
                }
            }
        }
    }
    
    return model;
    
}

+(NSDictionary *)property:(Class)mclass {
    
    NSMutableDictionary * attrDic = [NSMutableDictionary new];
    
    unsigned int count = 0;
    //取得当前class的所有属性数组
    objc_property_t * proArr = class_copyPropertyList(mclass, &count);
    
    //获得属性名和类型
    for (int i = 0; i < count; i++) {
        objc_property_t property = proArr[i];
        
        NSString * name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];//获得属性名
        
        NSString * valueStr = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];//获得类型字符串
        
        valueStr = [self valueString:valueStr];//通过解析方法转换类型字符串，获得类型名称
        
        [attrDic setObject:valueStr forKey:name];
    }
    free(proArr);
    return attrDic;
}


+(NSString *)valueString:(NSString *)valueStr
{
//     NSLog(@"valueStr:%@",valueStr);

    NSString * temp = [valueStr componentsSeparatedByString:@","][0];
    if ([temp rangeOfString:@"@"].location != NSNotFound) {
        
        if (temp.length == 2) {
            return @"NSObject";
        }
        if (temp.length < 4) {
            return @" ";
        }
        temp = [[temp substringToIndex:temp.length - 1] substringFromIndex:3];
        return temp;
    }
    else if(temp.length == 2)
    {
        return @"NSNumber";
    }
    return @" ";
    
}

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
+(NSDictionary *)dictionaryForModelAttribute:(NSObject *)model kindOfClass:(Class)mClass WithNameDictionary :(NSDictionary *)nameDic {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (!model || ![model.class isSubclassOfClass:mClass]) {
        return dic;
    }
    
    NSDictionary *attrDic = [self property:mClass];
    NSArray *attrArray = [attrDic allKeys];
    /**
     *  不使用系统自带的dictionaryWithValuesForKeys:(NSArray *)是考虑到可以改名
     */
    for (int i = 0; i < attrArray.count; i++) {
        
        NSString *name = attrArray[i];
        NSObject *value = [model valueForKey:name];
        if (value == nil) {
            value = [NSNull null];
        }
        
        if (nameDic && nameDic[name]) {
            name = nameDic[name];
        }
        
        [dic setObject:value forKey:name];
        
    }
    return dic;
}

#pragma mark - ModelAttributeCreateTable


@end
