//
//  HeroSimpleStorage
//  hero-ios
//
//  Created by Liu Guoping on 2018/10/26.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "HeroDB.h"


@interface HeroDB ()

@end

@implementation HeroDB {
    id ldb;
}
-(instancetype)init{
//    LevelDB *ldb = [LevelDB databaseInLibraryWithName:@"test.ldb"];
    return [super init];
}
-(void)on:(NSDictionary *)json{
    if (json[@"isNpc"]) {
        NSString *key = json[@"key"];
        id value = json[@"value"];
        if (value) {
            ldb[key] = value;
        }else{
            NSString *js = [NSString stringWithFormat:@"window['%@callback'](%@)",[self class],[[NSString alloc] initWithData:ldb[key] encoding:NSUTF8StringEncoding]];
            [self.controller.webview stringByEvaluatingJavaScriptFromString:js];
        }
        NSString *arrayKey = json[@"arrayKey"];
        NSString *start = json[@"start"];
        NSString *end = json[@"end"];
        if (arrayKey) {
//            [ldb enumerateKeysAndObjectsUsingBlock:^(LevelDBKey *key, id value, BOOL *stop) {
//                // This step is necessary since the key could be a string or raw data (use NSDataFromLevelDBKey in that case)
//                NSString *keyString = NSStringFromLevelDBKey(key); // Assumes UTF-8 encoding
//                // Do something clever
//            }];
            if (value) {
//                
            }
        }
    }
}

@end

