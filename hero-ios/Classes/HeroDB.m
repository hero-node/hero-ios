//
//  HeroSimpleStorage
//  hero-ios
//
//  Created by Liu Guoping on 2018/10/26.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <Objective_LevelDB/LevelDB.h>
#import "HeroDB.h"


@interface HeroDB ()

@end

@implementation HeroDB {
    LevelDB *ldb;
}
-(instancetype)init{
    ldb = [LevelDB databaseInLibraryWithName:@"hero.ldb"];
    return [super init];
}
-(void)on:(NSDictionary *)json{
    NSString *key = json[@"key"];
    NSString *arrayKey = json[@"arrayKey"];
    NSString *start = json[@"start"];
    NSString *count = json[@"count"];
    id value = json[@"value"];
    
    if (key) {
        if (value) {
            [self setValue:value forKey:key];
        } else{
            id value = [self valueForKey:key];
            if (json[@"isNpc"]) {
                NSString *js = [NSString stringWithFormat:@"window['%@callback'](%@)",[self class], value];
                [self.controller.webview stringByEvaluatingJavaScriptFromString:js];
            } else {
                [self.controller on:@{@"result": value}];
            }
        }
    }
    
    if (arrayKey) {
        if (value) {
            [self addValue:value forArrayKey:arrayKey];
        } else if (start && count) {
            NSArray *value = [self valueForArrayKey:arrayKey start:[start integerValue] count:[count integerValue]];
            
            if (json[@"isNpc"]) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSString *js = [NSString stringWithFormat:@"window['%@callback'](%@)",[self class], jsonString];
                [self.controller.webview stringByEvaluatingJavaScriptFromString:js];
            } else {
                [self.controller on:@{@"result": value}];
            }
        
        }
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    ldb.safe = YES;
    ldb[key] = value;
    ldb.safe = NO;
}

- (id)valueForKey:(NSString *)key {
    return ldb[key];
}

- (void)addValue:(id)value forArrayKey:(NSString *)arrayKey {
    NSMutableArray *array = [ldb[arrayKey] mutableCopy];
    ldb.safe = YES;
    if ([value isKindOfClass:[NSArray class]]) {
        [array addObjectsFromArray:value];
    } else {
        [array addObject:value];
    }
    ldb.safe = NO;
}

- (NSArray *)valueForArrayKey:(NSString *)arrayKey start:(NSUInteger)start count:(NSUInteger)count {
    NSArray *array = ldb[arrayKey];
    if (start + count <= array.count) {
        NSRange range = NSMakeRange(array.count - start - count, count);
        NSArray *value = [array subarrayWithRange:range];
        return value;
    } else {
        return @[];
    }
}

@end

