//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Feb 20 2016 22:04:40).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <Foundation/NSObject.h>

#import <SimulatorKit/SimDeviceIOPortConsumer-Protocol.h>
#import <SimulatorKit/SimDisplayDamageRectangleDelegate-Protocol.h>
#import <SimulatorKit/SimDisplayIOSurfaceRenderableDelegate-Protocol.h>

@class MTLTextureDescriptor, NSOutputStream, NSString, NSUUID, SimVideoFile;
@protocol MTLCommandQueue, MTLComputePipelineState, MTLDevice, MTLFunction, MTLLibrary, OS_dispatch_queue;

@interface SimDisplayVideoWriter : NSObject <SimDeviceIOPortConsumer, SimDisplayDamageRectangleDelegate, SimDisplayIOSurfaceRenderableDelegate>
{
    BOOL _startedWriting;
    double _framesPerSecond;
    unsigned long long _timeScale;
    NSUUID *_consumerUUID;
    NSString *_consumerIdentifier;
    NSObject<OS_dispatch_queue> *_executionQueue;
    id<MTLDevice> _metalDevice;
    id<MTLLibrary> _metalLibrary;
    id<MTLCommandQueue> _metalCommandQueue;
    id<MTLFunction> _kernelFunction;
    id<MTLComputePipelineState> _pipelineState;
    struct __CVMetalTextureCache *_metalTextureCache;
    MTLTextureDescriptor *_ioSurfaceTextureDescriptor;
    NSOutputStream *_stream;
    SimVideoFile *_videoFile;
    id _ioSurface;
    struct OpaqueVTCompressionSession *_compressionSession;
    void *_startTime;
    void *_lastEncodeTime;
}

+ (id)videoWriterForURL:(id)arg1 fileType:(id)arg2;
+ (id)videoWriterForOutputStream:(id)arg1 fileType:(id)arg2;
+ (id)videoWriter;
@property (nonatomic, assign) void *lastEncodeTime;
@property (nonatomic, assign) void *startTime;
@property (nonatomic, assign) struct OpaqueVTCompressionSession *compressionSession;
@property (retain, nonatomic) id ioSurface;
@property (nonatomic, assign) BOOL startedWriting;
@property (retain, nonatomic) SimVideoFile *videoFile;
@property (retain, nonatomic) NSOutputStream *stream;
@property (retain, nonatomic) MTLTextureDescriptor *ioSurfaceTextureDescriptor;
@property (nonatomic, assign) struct __CVMetalTextureCache *metalTextureCache;
@property (retain, nonatomic) id<MTLComputePipelineState> pipelineState;
@property (retain, nonatomic) id<MTLFunction> kernelFunction;
@property (retain, nonatomic) id<MTLCommandQueue> metalCommandQueue;
@property (retain, nonatomic) id<MTLLibrary> metalLibrary;
@property (retain, nonatomic) id<MTLDevice> metalDevice;
@property (retain, nonatomic) NSObject<OS_dispatch_queue> *executionQueue;
@property (copy, nonatomic) NSString *consumerIdentifier;
@property (strong, nonatomic) NSUUID *consumerUUID;
@property (nonatomic, assign) unsigned long long timeScale;
@property (nonatomic, assign) double framesPerSecond;
- (void)startWriting;
- (void)finishWriting;
- (void)didReceiveDamageRect:(struct CGRect)arg1;
- (void)didChangeIOSurface:(id)arg1;
- (void)dealloc;

// Remaining properties
@property (atomic, copy, readonly) NSString *debugDescription;
@property (atomic, copy, readonly) NSString *description;
@property (atomic, readonly) NSUInteger hash;
@property (atomic, readonly) Class superclass;

@end
