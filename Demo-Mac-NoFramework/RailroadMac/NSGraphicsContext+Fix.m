
#import <Cocoa/Cocoa.h>
#import "NSGraphicsContext+Fix.h"

@implementation NSGraphicsContext (Fix)

+ (NSGraphicsContext *)graphicsContextWithFix:(CGContextRef)graphicsPort {
  return [self graphicsContextWithGraphicsPort:graphicsPort flipped:YES];
}

@end
