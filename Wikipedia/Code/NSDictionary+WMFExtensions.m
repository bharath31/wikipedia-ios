
#import "NSDictionary+WMFExtensions.h"

@implementation NSDictionary (WMFExtensions)

- (BOOL)wmf_containsNullObjects {
    NSNull* null = [self bk_match:^BOOL (id key, id obj) {
        return [obj isKindOfClass:[NSNull class]];
    }];
    return (null != nil);
}

- (BOOL)wmf_recursivelyContainsNullObjects{
    
    if([self wmf_containsNullObjects]){
        return YES;
    }
    
    __block BOOL hasNull = NO;
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if([obj isKindOfClass:[NSDictionary class]]){
            
            hasNull = [obj wmf_recursivelyContainsNullObjects];
            if(hasNull){
                *stop = YES;
                return;
            }
        }
        
        if([obj isKindOfClass:[NSArray class]]){
            
            hasNull = [obj wmf_recursivelyContainsNullObjects];
            if(hasNull){
                *stop = YES;
                return;
            }
        }
        
    }];
    
    return hasNull;
}

@end
