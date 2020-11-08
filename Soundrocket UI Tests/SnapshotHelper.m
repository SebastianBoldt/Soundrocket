#import "SnapshotHelper.h"

@implementation SnapshotHelper {
    XCUIApplication* _app;
}

- (instancetype)initWithApp:(XCUIApplication *)app {
    if ((self = [super init])) {
        _app = app;
        [self setLanguage];
        [self setLaunchArguments];
    }
    return self;
}

- (void)snapshot:(NSString *)name waitForLoadingIndicator:(BOOL)wait {
    if (wait) {
        [self waitForLoadingIndicatorToDisappear];
    }

    printf("snapshot: %s", name.UTF8String);
    sleep(1);
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationUnknown;
}

- (void)waitForLoadingIndicatorToDisappear {
    XCUIElementQuery* query = [[[_app.statusBars childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:1] childrenMatchingType:XCUIElementTypeOther];

    while (query.count > 4) {
        sleep(1);
        NSLog(@"Number of Elements in Status Bar: %ld... waiting for status bar to disappear", query.count);
    }
}

- (void)setLanguage {
    NSString* path = @"/tmp/language.txt";

    NSError* error;
    NSString* locale = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%s could not detect language %@", __PRETTY_FUNCTION__, error);
        return;
    }
    NSUInteger idx = 2;
    if (locale.length < idx) {
        idx = locale.length;
    }
    NSString* deviceLanguage = [locale substringToIndex:idx];
    _app.launchArguments = [_app.launchArguments arrayByAddingObjectsFromArray:@[@"-AppleLanguages",[NSString stringWithFormat:@"(%@)", deviceLanguage],@"-AppleLocale",locale]];
}

- (void)setLaunchArguments {
    NSString* path = @"/tmp/snapshot-launch_arguments.txt";

    _app.launchArguments = [_app.launchArguments arrayByAddingObjectsFromArray:@[@"-FASTLANE_SNAPSHOT", @"YES"]];

    NSError* error;
    NSString* argsString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%s could not detect launch arguments: %@", __PRETTY_FUNCTION__, error);
        return;
    }

    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"(\\\".+?\\\"|\\S+)" options:0 error:&error];
    if (error) {
        NSLog(@"%s could not detect launch arguments: %@", __PRETTY_FUNCTION__, error);
        return;
    }

    NSArray<NSTextCheckingResult*>* matches = [regex matchesInString:argsString options:0 range:NSMakeRange(0, argsString.length)];
    NSMutableArray<NSString*>* results = [NSMutableArray array];
    for (NSTextCheckingResult* match in matches) {
        [results addObject:[argsString substringWithRange:match.range]];
    }
    if (results.count > 0) {
        _app.launchArguments = [_app.launchArguments arrayByAddingObjectsFromArray:results];
    }
}

@end
