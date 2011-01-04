#import <Foundation/Foundation.h>
#import "APXML/APXML.h"

@class SMWeatherControl;
@interface MainMenuWeatherControl: NSObject 
{
    
}
+(NSDictionary *)loadDictionaryForCode:(NSString *)code usUnits:(BOOL)us;
+(NSDictionary *)parseYahooRSS:(SMFDocument*)apDoc;
+(SMWeatherControl *)control;
+(void)reload;
@end