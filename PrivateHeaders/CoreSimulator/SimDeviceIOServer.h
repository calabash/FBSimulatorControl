//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Feb 20 2016 22:04:40).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <CoreSimulator/SimDeviceIO.h>

#import <CoreSimulator/SimDeviceIOInterface-Protocol.h>

@class NSArray, NSDictionary;

@interface SimDeviceIOServer : SimDeviceIO <SimDeviceIOInterface>
{
    NSDictionary *_loadedBundles;
    NSArray *_ioPorts;
    NSArray *_ioPortProxies;
}

@property (nonatomic, copy) NSArray *ioPortProxies;
@property (nonatomic, copy) NSArray *ioPorts;
@property (nonatomic, copy) NSDictionary *loadedBundles;
- (void).cxx_destruct;
- (BOOL)unregisterService:(id)arg1 error:(id *)arg2;
- (BOOL)registerPort:(unsigned int)arg1 service:(id)arg2 error:(id *)arg3;
- (NSDictionary *)makeRequest:(id)arg1 fields:(NSDictionary *)arg2;
- (id)tvOutDisplayDescriptorState;
- (id)mainDisplayDescriptorState;
- (BOOL)unloadAllBundles;
- (BOOL)loadAllBundles;

@end
