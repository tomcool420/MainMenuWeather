//
//  MainMenuWeatherLocationController.m
//  Untitled
//
//  Created by Thomas Cool on 10/22/10.
//  Copyright 2010 tomcool.org. All rights reserved.
//

#import "MainMenuWeatherLocationController.h"
#import "MainMenuWeather.h"
typedef enum _kWCRows
{

    kWCCoderow,
    kWCUnitsrow,
    kWCTimezonerow,
    kWCSaverow,
    kWCRemoverow,
    kWCActivaterow,
    
    kWCCountrow,
    
        kWCCityrow,
}kWCRows;
#define NEWWeatherFile [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.tomcool.mainmenu.weather.plist"]
#define plitFile [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.tomcool.weather.plist"]

@implementation MainMenuWeatherLocationController
- (id)previewControlForItem:(long)row
{
    NSString * f = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo_logo" ofType:@"png"];
    BRImage * image = [BRImage imageWithPath:f];
    BRImageAndSyncingPreviewController *preview = [[BRImageAndSyncingPreviewController alloc] init];
    [preview setImage:image];
	return [preview autorelease];
}
-(id)initWithLocationCode:(NSString *)locationCode
{
    if ((self=[super init])!=nil) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:NEWWeatherFile]) 
        {
            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithContentsOfFile:NEWWeatherFile];
            NSDictionary *cityInfo = [d objectForKey:locationCode];
            _location = [[cityInfo objectForKey:@"location"] retain];
            _name = [[cityInfo objectForKey:@"name"] retain];
            _units = [[cityInfo objectForKey:@"units"] retain];
            _timeZone = [[cityInfo objectForKey:@"timeZone"] retain];
            if (_timeZone==nil) {
                _timeZone=[@"America/Chicago" retain];
            }
            [self setListTitle:_name];
            USUnits = [_units isEqualToString:@"f"];
            needsSaving=NO;
        }
        [[self list] addDividerAtIndex:(kWCCountrow-3) withLabel:@"Management"];
    }
    return self;
}
-(long)itemCount
{
    return kWCCountrow;
}
-(void)leftActionForRow:(long)row
{
    if (row == kWCUnitsrow) {
        USUnits=!USUnits;
        needsSaving=YES;
        [[self list]reload];
    }
}
-(void)rightActionForRow:(long)row
{
    if (row == kWCUnitsrow) {
        USUnits=!USUnits;
        needsSaving=YES;
        [[self list]reload];
    }
}
-(void)itemSelected:(long)row
{
    if (row==kWCUnitsrow) {
        USUnits=!USUnits;
        needsSaving=YES;
        [[self list]reload];
    }
    else if(row==kWCTimezonerow){
        SMFQueryMenu *q =[[SMFQueryMenu alloc]init];
        [q setDelegate:self];
        [[self stack]pushController:q];
        [q release];
    }
    else if (row==kWCSaverow)
    {
        NSInvocation *inf = [SMFInvocationCenteredMenuController invocationsForObject:self 
                                                                      withSelectorVal:@"save:" 
                                                                        withArguments:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]];
        NSInvocation *inf2 = [SMFInvocationCenteredMenuController invocationsForObject:self 
                                                                       withSelectorVal:@"save:" 
                                                                         withArguments:[NSArray arrayWithObject:[NSNumber numberWithInt:0]]];
        NSArray * a = [NSArray arrayWithObjects:inf,inf2,nil];
        
        SMFInvocationCenteredMenuController *i = [[SMFInvocationCenteredMenuController alloc] initWithTitles:[NSArray arrayWithObjects:@"Yes",@"No",nil] 
                                                                                             withInvocations:a 
                                                                                                   withTitle:[NSString stringWithFormat:@"Save %@",_name,nil] 
                                                                                             withDescription:[NSString stringWithFormat:@"Are you sure you want to change the way the world views %@",_name,nil ]];
        [[self stack]pushController:i];
        [i release];
    }
    else if (row==kWCRemoverow) 
    {
        NSInvocation *inf = [SMFInvocationCenteredMenuController invocationsForObject:self 
                                                                      withSelectorVal:@"remove:" 
                                                                        withArguments:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]];
        NSInvocation *inf2 = [SMFInvocationCenteredMenuController invocationsForObject:self 
                                                                       withSelectorVal:@"remove:" 
                                                                         withArguments:[NSArray arrayWithObject:[NSNumber numberWithInt:0]]];
        NSArray * a = [NSArray arrayWithObjects:inf,inf2,nil];
        
        SMFInvocationCenteredMenuController *i = [[[SMFInvocationCenteredMenuController alloc] initWithTitles:[NSArray arrayWithObjects:@"Yes",@"No",nil] 
                                                                                             withInvocations:a 
                                                                                                   withTitle:[NSString stringWithFormat:@"Remove %@",_name,nil] 
                                                                                             withDescription:[NSString stringWithFormat:@"Are you sure you want to remove %@ from the world map",_name,nil ]]autorelease];
        [[self stack]pushController:i];
    }
    else if (row==kWCActivaterow) {
        NSInvocation *inf = [SMFInvocationCenteredMenuController invocationsForObject:self 
                                                                      withSelectorVal:@"useOnMainMenu:" 
                                                                        withArguments:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]];
        NSInvocation *inf2 = [SMFInvocationCenteredMenuController invocationsForObject:self 
                                                                       withSelectorVal:@"useOnMainMenu:" 
                                                                         withArguments:[NSArray arrayWithObject:[NSNumber numberWithInt:0]]];
        NSArray * a = [NSArray arrayWithObjects:inf,inf2,nil];
        
        SMFInvocationCenteredMenuController *i = [[[SMFInvocationCenteredMenuController alloc] initWithTitles:[NSArray arrayWithObjects:@"Yes",@"No",nil] 
                                                                                             withInvocations:a 
                                                                                                   withTitle:[NSString stringWithFormat:@"Use %@",_name,nil] 
                                                                                             withDescription:[NSString stringWithFormat:@"Are you sure you want to display %@ on the main menu?",_name,nil ]]autorelease];
        [[self stack]pushController:i];
    }
}
-(id)itemForRow:(long)row
{
    BRMenuItem *item = [[BRMenuItem alloc] init];
    NSString *title=@"";
    NSString *subText=nil;
    if (row==kWCCityrow) {
        title=_name;
        subText=nil;
    }
    else if (row == kWCCoderow) {
        title=@"Code";
        subText=_location;
    }
    else if (row == kWCUnitsrow)
    {
        title=@"Units";
        subText=(!USUnits?@"Celcius":@"Farenheit");
    }
    else if (row == kWCTimezonerow)
    {
        title=@"Time Zone";
        subText=_timeZone;
    }
    else if (row == kWCSaverow)
    {
        title = @"Save";
                if (needsSaving==NO) {
                    [item setDimmed:YES];
                }
    }
    else if (row == kWCRemoverow)
    {
        title = @"Remove";
        
    }
    else if (row==kWCActivaterow)
    {
        title = @"Set Activate on Main Menu";
    }
    [item setText:title withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
    if (subText) 
        [item setRightJustifiedText:subText 
                     withAttributes:[[BRThemeInfo sharedTheme] menuItemSmallTextAttributes]];
    
    return item;
}
-(void)useOnMainMenu:(NSNumber *)nb
{
    if([nb boolValue])
    {
        NSMutableDictionary *  d;
        if ([[NSFileManager defaultManager] fileExistsAtPath:plitFile]) {
            d = [NSMutableDictionary dictionaryWithContentsOfFile:plitFile];

        }
        else
            d= [NSMutableDictionary dictionary];
        [d setObject:_location forKey:@"mainmenuweather"];
        [d writeToFile:plitFile atomically:YES];
        [[MainMenuWeatherControl control] reload];
    }
}
-(void)save:(NSNumber *)nb
{
    if ([nb boolValue]) {
        NSMutableDictionary *ddd = [NSMutableDictionary dictionaryWithContentsOfFile:NEWWeatherFile];
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                           _location,@"location",
                           _name,@"name",
                           (USUnits?@"f":@"c") ,@"units",
                           _timeZone,@"timeZone",
                           nil];
        [ddd setObject:d forKey:_location];
        [ddd writeToFile:NEWWeatherFile atomically:YES];
        needsSaving=NO;
        
    }
    [[self stack]popController];
}
-(void)saveQuit:(NSNumber *)nb
{
    [self save:nb];
    [[self stack]popController];
}
-(void)remove:(NSNumber *)nb
{
    if ([nb boolValue]) {
        NSMutableDictionary *ddd = [NSMutableDictionary dictionaryWithContentsOfFile:NEWWeatherFile];
        [ddd removeObjectForKey:_location];
        [ddd writeToFile:NEWWeatherFile atomically:YES];
        [[self stack] popController];
    }
    
}
-(void)queryMenu:(SMFQueryMenu *)q itemSelected:(NSString *)it
{
    
    [_timeZone release];
    _timeZone=[it copy];
    [[self list] reload];
    needsSaving=YES;
    [[self stack]popController];
}
-(BOOL)brEventAction:(id)action
{
    if ([action remoteAction]==1&& needsSaving) {
        NSInvocation *inf = [SMFInvocationCenteredMenuController invocationsForObject:self 
                                                                      withSelectorVal:@"saveQuit:" 
                                                                        withArguments:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]];
        NSInvocation *inf2 = [SMFInvocationCenteredMenuController invocationsForObject:self 
                                                                       withSelectorVal:@"saveQuit:" 
                                                                         withArguments:[NSArray arrayWithObject:[NSNumber numberWithInt:0]]];
        NSArray * a = [NSArray arrayWithObjects:inf,inf2,nil];
        
        SMFInvocationCenteredMenuController *i = [[[SMFInvocationCenteredMenuController alloc] initWithTitles:[NSArray arrayWithObjects:@"Yes",@"No",nil] 
                                                                                             withInvocations:a 
                                                                                                   withTitle:[NSString stringWithFormat:@"Save %@",_name,nil] 
                                                                                             withDescription:[NSString stringWithFormat:@"Do you want to save the changes made to %@",_name,nil ]]autorelease];
        [[self stack]pushController:i];
        return YES;
    }
    return [super brEventAction:action];
}
-(id)titleForRow:(long)row
{
    if(row==kWCCityrow)
        return _name;
    else if(row==kWCCoderow)
        return @"Code";
    else if(row==kWCUnitsrow)
        return @"Units";
    else if(row==kWCTimezonerow)
        return @"Time Zone";
    else if(row==kWCRemoverow)
        return @"Remove City";
    else if(row==kWCActivaterow)
        return @"Set Activate on Main Menu";
    else if(row==kWCSaverow)
        return @"Save";
    return nil;
}
@end
