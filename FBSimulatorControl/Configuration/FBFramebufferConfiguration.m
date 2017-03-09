/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBFramebufferConfiguration.h"

#import <FBControlCore/FBControlCore.h>

#import "FBSimulatorScale.h"
#import "FBVideoEncoderConfiguration.h"
#import "FBSimulator.h"
#import "FBSimulatorDiagnostics.h"

@implementation FBFramebufferConfiguration

+ (NSString *)defaultImagePath
{
  return [NSHomeDirectory() stringByAppendingString:@"image.png"];
}

+ (instancetype)configurationWithScale:(nullable id<FBSimulatorScale>)scale encoder:(FBVideoEncoderConfiguration *)encoder imagePath:(NSString *)imagePath
{
  return [[self alloc] initWithScale:scale encoder:encoder imagePath:imagePath];
}

+ (instancetype)defaultConfiguration
{
  return [self new];
}

- (instancetype)init
{
  return [self initWithScale:nil encoder:FBVideoEncoderConfiguration.defaultConfiguration imagePath:FBFramebufferConfiguration.defaultImagePath];
}

- (instancetype)initWithScale:(nullable id<FBSimulatorScale>)scale encoder:(FBVideoEncoderConfiguration *)encoder imagePath:(NSString *)imagePath
{
  self = [super init];
  if (!self) {
    return nil;
  }

  _scale = scale;
  _encoder = encoder;
  _imagePath = imagePath;

  return self;
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
  return self;
}

#pragma mark NSObject

- (NSUInteger)hash
{
  return self.scale.hash ^ self.encoder.hash ^ self.imagePath.hash;
}

- (BOOL)isEqual:(FBFramebufferConfiguration *)configuration
{
  if (![configuration isKindOfClass:self.class]) {
    return NO;
  }

  return (self.scale == configuration.scale || [self.scale isEqual:configuration.scale]) &&
         (self.encoder == configuration.encoder || [self.encoder isEqual:configuration.encoder]) &&
         (self.imagePath == configuration.imagePath || [self.imagePath isEqual:configuration.imagePath]);
}

#pragma mark NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
  self = [super init];
  if (!self) {
    return nil;
  }

  _scale = [decoder decodeObjectForKey:NSStringFromSelector(@selector(scale))];
  _encoder = [decoder decodeObjectForKey:NSStringFromSelector(@selector(encoder))];
  _imagePath = [decoder decodeObjectForKey:NSStringFromSelector(@selector(imagePath))];

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.scale forKey:NSStringFromSelector(@selector(scale))];
  [coder encodeObject:self.encoder forKey:NSStringFromSelector(@selector(encoder))];
  [coder encodeObject:self.imagePath forKey:NSStringFromSelector(@selector(imagePath))];
}

#pragma mark FBJSONSerializable

static NSString *KeyScale = @"scale";
static NSString *KeyEncoder = @"encoder";
static NSString *KeyImagePath = @"image_path";

- (id)jsonSerializableRepresentation
{
  return @{
    KeyScale : self.scale.scaleString ?: NSNull.null,
    KeyEncoder : self.encoder.jsonSerializableRepresentation,
    KeyImagePath : self.imagePath,
  };
}

#pragma mark FBDebugDescribeable

- (NSString *)shortDescription
{
  return [NSString stringWithFormat:
    @"Scale %@ | Encoder %@ | Image Path %@",
    self.scale.scaleString,
    self.encoder.shortDescription,
    self.imagePath
  ];
}

- (NSString *)debugDescription
{
  return self.shortDescription;
}

- (NSString *)description
{
  return self.shortDescription;
}

#pragma mark Scale

+ (instancetype)withScale:(nullable id<FBSimulatorScale>)scale
{
  return [self.new withScale:scale];
}

- (instancetype)withScale:(nullable id<FBSimulatorScale>)scale
{
  return [[self.class alloc] initWithScale:scale encoder:self.encoder imagePath:self.imagePath];
}

- (nullable NSDecimalNumber *)scaleValue
{
  return self.scale.scaleString ? [NSDecimalNumber decimalNumberWithString:self.scale.scaleString] : nil;
}

- (CGSize)scaleSize:(CGSize)size
{
  NSDecimalNumber *scaleNumber = self.scaleValue;
  if (!self.scaleValue) {
    return size;
  }
  CGFloat scale = scaleNumber.doubleValue;
  return CGSizeMake(size.width * scale, size.height * scale);
}

#pragma mark Encoder

+ (instancetype)withEncoder:(FBVideoEncoderConfiguration *)encoder
{
  return [self.new withEncoder:encoder];
}

- (instancetype)withEncoder:(FBVideoEncoderConfiguration *)encoder
{
  return [[self.class alloc] initWithScale:self.scale encoder:encoder imagePath:self.imagePath];
}

#pragma mark Diagnostics

+ (instancetype)withImagePath:(NSString *)imagePath
{
  return [self.new withImagePath:imagePath];
}

- (instancetype)withImagePath:(NSString *)imagePath
{
  return [[self.class alloc] initWithScale:self.scale encoder:self.encoder imagePath:imagePath];
}

+ (instancetype)withImageDiagnostic:(FBDiagnostic *)diagnostic
{
  return [self.new withImageDiagnostic:diagnostic];
}

- (instancetype)withImageDiagnostic:(FBDiagnostic *)diagnostic
{
  FBDiagnosticBuilder *builder = [FBDiagnosticBuilder builderWithDiagnostic:diagnostic];
  return [[self.class alloc] initWithScale:self.scale encoder:self.encoder imagePath:builder.createPath];
}

#pragma mark Simulators

- (instancetype)inSimulator:(FBSimulator *)simulator
{
  FBDiagnosticBuilder *imageBuilder = [FBDiagnosticBuilder builderWithDiagnostic:simulator.simulatorDiagnostics.screenshot];
  FBDiagnosticBuilder *videoBuilder = [FBDiagnosticBuilder builderWithDiagnostic:simulator.simulatorDiagnostics.screenshot];
  FBVideoEncoderConfiguration *encoder = [self.encoder withFilePath:videoBuilder.createPath];
  return [[self withEncoder:encoder] withImagePath:imageBuilder.createPath];
}

@end
