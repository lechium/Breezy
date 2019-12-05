#import "NSObject+CD.h"

@implementation NSObject (CD)

- (void)classDumpObject:(id)obj
{
    HBLogDebug(@"weouchea?");
    Class clazz = [obj class];
    u_int count;
    Ivar* ivars = class_copyIvarList(clazz, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* ivarName = ivar_getName(ivars[i]);
        NSString *ivarPropName = [NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding];
        if ([obj respondsToSelector:NSSelectorFromString(ivarPropName)]){
            id value = [obj valueForKey:ivarPropName];
            if (value){
                NSDictionary *propertyDict = @{ivarPropName: value};
                [ivarArray addObject:propertyDict];
            } else {
                [ivarArray addObject:ivarPropName];
            }
        } else {
            [ivarArray addObject:ivarPropName];
        }
        
        
    }
    free(ivars);
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        const char* attributes = property_getAttributes(properties[i]);
        NSString *propertyNameString = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        NSString *attributesString = [NSString  stringWithCString:attributes encoding:NSUTF8StringEncoding];
        NSDictionary *propertyDict = @{propertyNameString: attributesString};
        //NSLog(@"propertyDIct: %@", propertyDict);
        if ([obj respondsToSelector:NSSelectorFromString(propertyNameString)] && [attributesString containsString:@"T@"]){
            id value = [obj valueForKey:propertyNameString];
            if (value){
                NSMutableDictionary *mut = [propertyDict mutableCopy];
                [mut setValue:value forKey:@"value"];
                propertyDict = mut;
            }
        }
        
        [propertyArray addObject:propertyDict];
    }
    free(properties);
    
    Method* methods = class_copyMethodList(clazz, &count);
    NSMutableArray* methodArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        SEL selector = method_getName(methods[i]);
        const char* methodName = sel_getName(selector);
        [methodArray addObject:[NSString  stringWithCString:methodName encoding:NSUTF8StringEncoding]];
    }
    free(methods);
    
    NSDictionary* classDump = [NSDictionary dictionaryWithObjectsAndKeys:
                               ivarArray, @"ivars",
                               propertyArray, @"properties",
                               methodArray, @"methods",
                               nil];
    
    HBLogDebug(@"%@", classDump);
}

@end
