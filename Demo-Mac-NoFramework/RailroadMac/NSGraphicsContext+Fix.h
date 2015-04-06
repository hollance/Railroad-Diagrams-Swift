
// This workaround is needed because NSGraphicsContext(graphicsPort:flipped:)
// is deprecated in 10.10 but the new NSGraphicsContext(CGContext:) does not
// work in 10.9, yet the Swift compiler insists that CGContext is used instead
// of graphicsPort.

#import <Cocoa/Cocoa.h>

@interface NSGraphicsContext (Fix)

+ (NSGraphicsContext *)graphicsContextWithFix:(CGContextRef)graphicsPort;

@end
