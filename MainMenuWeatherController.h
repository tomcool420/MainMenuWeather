//
//  MainMenuWeatherController.h
//  MMWeather
//
//  Created by Thomas Cool on 10/22/10.
//  Copyright 2010 tomcool.org. All rights reserved.
//


//#import "OFMediaMenuController.h"
#import <SMFramework/SMFramework.h>

@interface MainMenuWeatherController : SMFMediaMenuController 
{
    NSMutableArray *    _locations;
    NSMutableArray *    _management;
    int searchType;

}
-(void)addLocation:(NSString *)code;
+(BOOL)enabled;
+(void)setEnabled:(BOOL)e;
@end
