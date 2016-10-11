
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

//Try to store logs at "${HOME}/.calabash/iOSDeviceManager/logs"
+ (NSString *)logfileLocation:(NSError *__autoreleasing *)err {
    NSString *errStr = nil;
    NSString *logsDir = [[[NSHomeDirectory()
                           stringByAppendingPathComponent:@".calabash"]
                          stringByAppendingPathComponent:@"iOSDeviceManager"]
                         stringByAppendingPathComponent:@"logs"];

    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:logsDir]) {
        NSError *e;
        [fm createDirectoryAtPath:logsDir withIntermediateDirectories:YES attributes:nil error:&e];
        if (e) {
            errStr = [NSString stringWithFormat:@"Error creating logging dir at %@: %@", logsDir, e];
        }
    }
    if (errStr) {
        logsDir = nil;
        *err = [NSError errorWithDomain:@"sh.calaba.iOSDeviceManager.LoggingError"
                                   code:27753
                               userInfo:@{NSLocalizedDescriptionKey: errStr}];
    }
    return logsDir;
}

@end
