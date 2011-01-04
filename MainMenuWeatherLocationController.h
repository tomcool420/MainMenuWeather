//
//  MainMenuWeatherLocationController.h
//  Untitled
//
//  Created by Thomas Cool on 10/22/10.
//  Copyright 2010 tomcool.org. All rights reserved.
//

//#import "OFMediaMenuController.h"
#import <SMFramework/SMFramework.h>


@interface MainMenuWeatherLocationController : SMFMediaMenuController<SMFQueryDelegate> {
    NSString *_location;
    NSString *_units;
    NSString *_name;
    NSString *_timeZone;
    BOOL needsSaving;
    BOOL USUnits;
}
-(id)initWithLocationCode:(NSString *)locationCode;
-(void)remove:(NSNumber *)nb;
-(void)save:(NSNumber *)nb;
-(void)queryMenu:(SMFQueryMenu *)q itemSelected:(NSString *)it;
-(void)saveQuit:(NSNumber *)nb;

@end
