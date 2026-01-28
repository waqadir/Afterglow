// Private CoreBrightness API header for True Tone display control.
// These APIs are not documented by Apple and may change between macOS versions.

#ifndef CBTrueToneClient_h
#define CBTrueToneClient_h

#import <Foundation/Foundation.h>

@interface CBTrueToneClient : NSObject

- (BOOL)supported;
- (BOOL)available;
- (BOOL)enabled;
- (BOOL)setEnabled:(BOOL)enabled;

@end

#endif /* CBTrueToneClient_h */
