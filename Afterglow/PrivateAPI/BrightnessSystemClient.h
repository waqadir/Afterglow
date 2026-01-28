// Private CoreBrightness API header for reading sunrise/sunset data.
// Used to determine the solar schedule for Night Shift.

#ifndef BrightnessSystemClient_h
#define BrightnessSystemClient_h

#import <Foundation/Foundation.h>

@interface BrightnessSystemClient : NSObject

- (BOOL)isAlive;
- (id)copyPropertyForKey:(NSString *)key;

@end

#endif /* BrightnessSystemClient_h */
