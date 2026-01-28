// Private CoreBrightness API header for Night Shift control.
// These APIs are not documented by Apple and may change between macOS versions.

#ifndef CBBlueLightClient_h
#define CBBlueLightClient_h

#import <Foundation/Foundation.h>

typedef struct {
    int hour;
    int minute;
} Time;

typedef struct {
    Time fromTime;
    Time toTime;
} Schedule;

typedef struct {
    BOOL active;
    BOOL enabled;
    BOOL sunSchedulePermitted;
    int mode;               // 0 = off, 1 = solar, 2 = custom
    Schedule schedule;
    unsigned long long disableFlags;
    BOOL available;
} Status;

@interface CBBlueLightClient : NSObject

- (BOOL)setEnabled:(BOOL)enabled;
- (BOOL)setMode:(int)mode;
- (BOOL)setSchedule:(Schedule *)schedule;
- (BOOL)setStrength:(float)strength commit:(BOOL)commit;
- (BOOL)getStrength:(float *)strength;
- (BOOL)getBlueLightStatus:(Status *)status;
- (BOOL)setStatusNotificationBlock:(void (^)(void))block;

+ (BOOL)supportsBlueLightReduction;

@end

#endif /* CBBlueLightClient_h */
