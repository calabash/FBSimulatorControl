
#import "CalabashUtils.h"

@implementation CalabashUtils

+ (void)doOnMain:(void(^)(void))someWork {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        someWork();
    } else {
        dispatch_sync(dispatch_get_main_queue(), someWork);
    }
}

+ (id)doOnMainAndReturn:(id(^)(void))someResult {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        return someResult();
    } else {
        __block id ret = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            ret = someResult();
        });
        return ret;
    }
}

@end
