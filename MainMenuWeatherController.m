//
//  MainMenuWeatherController.m
//  MMWeather
//
//  Created by Thomas Cool on 10/22/10.
//  Copyright 2010 tomcool.org. All rights reserved.
//

#import "MainMenuWeatherController.h"
#import "MainMenuWeatherLocationController.h"
#import "MainMenuWeather.h"
#import "APXML/APXML.h"

#define WeatherFile [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.nito.nitoTV.weather.plist"]
#define YAHOO_API @"dj0yJmk9ZXZQb3hzT3hkUUI5JmQ9WVdrOVRrb3dUV1oyTkdrbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD01Zg--"
#define NEWWeatherFile [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.tomcool.mainmenu.weather.plist"]
#define OLDWeatherFile [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.nito.nitoTV.weather.plist"]
#define plitFile [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.tomcool.weather.plist"]
#define WDomain (CFStringRef)@"Library/Preferences/org.tomcool.weather.plist"

static NSString * const kEnabledBool = @"enabled";
static NSString * const kMainMenuLocation = @"mainmenuweather";
@implementation MainMenuWeatherController
+(SMFPreferences *)preferences {
    static SMFPreferences *_weatherPreferences = nil;
    
    if(!_weatherPreferences)
    {
        _weatherPreferences = [[SMFPreferences alloc] initWithPersistentDomainName:@"org.tomcool.MainMenuWeather.New"];
        [_weatherPreferences registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                               @"2400737",kMainMenuLocation,
                                               [NSNumber numberWithBool:YES],kEnabledBool,
                                               nil]];
    }
        
    return _weatherPreferences;
}
+(BOOL)enabled
{
    CFPreferencesSynchronize(WDomain, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
    BOOL r = (BOOL)CFPreferencesGetAppBooleanValue((CFStringRef)@"enabled", WDomain, nil);
}
+(void)setEnabled:(BOOL)e
{
    CFPreferencesSetValue((CFStringRef)@"testVal", [NSNumber numberWithBool:e], WDomain, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
    CFPreferencesSynchronize(WDomain, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
}
- (id)previewControlForItem:(long)row
{
    NSString * f = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo_logo" ofType:@"png"];
    BRImage * image = [BRImage imageWithPath:f];
    BRImageAndSyncingPreviewController *preview = [[BRImageAndSyncingPreviewController alloc] init];
    [preview setImage:image];
    

	return [preview autorelease];
}
-(void)convert
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:NEWWeatherFile] && 
        [[NSFileManager defaultManager] fileExistsAtPath:OLDWeatherFile]) 
    {
        NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:OLDWeatherFile];
        NSArray *keys = [dict allKeys];
        NSMutableDictionary *locations = [[NSMutableDictionary alloc]init];
        for(NSString *key in keys)
        {
            [locations setObject:[dict objectForKey:key] forKey:[[dict objectForKey:key] objectForKey:@"location"]];
        }
        [locations writeToFile:NEWWeatherFile atomically:YES];
    }
    
}
-(void)reloadLocations
{

    [[self list] removeDividers];
    [_locations removeAllObjects];
    [_management removeAllObjects];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:NEWWeatherFile]) 
    {
        NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:NEWWeatherFile];
        for(NSString *key in [dict allKeys])
        {
            [_locations addObject:[dict objectForKey:key]];
        }
    }
    else
        _locations = [[NSMutableArray alloc] init];
    
    BRMenuItem *item = [[BRMenuItem alloc] init];
    [item setText:@"Add by WOEID" withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
    [_management addObject:item];
    [item release];
    
    item = [[BRMenuItem alloc] init];
    [item setText:@"Search WOEID" withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
    [_management addObject:item];
    [item release];
    
    item = [SMFMenuItem menuItem];
    [item setTitle:@"Select Display Color"];
    [_management addObject:item];
    
    
    [[self list] addDividerAtIndex:[_locations count] withLabel:@"Management"];
}
-(id)init
{
    self=[super init];
    if (self==nil) 
        return nil;
    [self setListTitle:@"Weather"];
    [[MainMenuWeatherController preferences] setObject:@"Hello" forKey:@"Location"];
    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:NEWWeatherFile] && 
//        [[NSFileManager defaultManager] fileExistsAtPath:OLDWeatherFile]) 
//    {
//        [self convert];
//    }
    [[self list] setDatasource:self];
    _management = [[NSMutableArray alloc]init];
    _locations = [[NSMutableArray alloc]init];
    searchType=0;
    [self reloadLocations];
    
    return self;
    
    
    
}

- (float)heightForRow:(long)row				{ return 0.0f;}

- (BOOL)rowSelectable:(long)row				{ return YES;}

- (long)itemCount							{ return ((long)[_locations count] + (long)[_management count]);}
-(void)leftActionForRow:(long)row
{
}
-(void)rightActionForRow:(long)row
{
}
- (id)itemForRow:(long)row					
{ 
    if (row<[_locations count]) 
    {
        BRMenuItem *menuItem = [[BRMenuItem alloc] init];
        NSDictionary *cityInfo = [_locations objectAtIndex:row];
        NSString *city = [cityInfo objectForKey:@"name"];
        NSString *units = [cityInfo objectForKey:@"units"];
        [menuItem addAccessoryOfType:1];
        [menuItem setText:(city?city:@"No Name") 
           withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
        [menuItem setRightJustifiedText:(units?units:@"c") 
                         withAttributes:[[BRThemeInfo sharedTheme] menuItemSmallTextAttributes]];
        return [menuItem autorelease];
    }
    else
    {
        row=row-[_locations count];
        return [_management objectAtIndex:row];
    }
    return nil;
}
- (id)titleForRow:(long)row					
{ 
    if (row<[_locations count]) 
    {
        NSDictionary *cityInfo = [_locations objectAtIndex:row];
        NSString *city = [cityInfo objectForKey:@"name"];
        return (city?city:@"No Name");
    }
    else if(row<([_locations count]+[_management count]))
        return [[_management objectAtIndex:(row-[_locations count])] text];
            
//    else if(row == [_locations count])
//    {
//        return @"Add by WOEID";
//    }
//    else if(row==([_locations count]+1)){
//        return @"Search WOEID";
//    }
//    else if(row==([_locations count]+2))
//    {
//        return @"Enabled";
//    }
//    else if(row==([_locations count]+3))
//    {
//        return @"Hello";
//    }
    
    return nil;
}
-(void)itemSelected:(long)selected
{
    if (selected<[_locations count]) 
    {
        NSString *code = [[_locations objectAtIndex:selected] objectForKey:@"location"];
        MainMenuWeatherLocationController *a = [[MainMenuWeatherLocationController alloc]initWithLocationCode:code];
        [[self stack]pushController:[a autorelease]];
    }
    if (selected == [_locations count]) {
        BRTextEntryController *controller = [[BRTextEntryController alloc] init];
		[controller setTitle:@"Enter Yahoo Weather Location Code"];
		[controller setTextEntryTextFieldLabel:@"ID"];
        [controller setListIcon:[[BRThemeInfo sharedTheme]appleTVIcon]];
        [controller setTextFieldDelegate:self];
        //[controller setTextEntryStyle:2];
        searchType=1;
		//[controller setInitialTextEntryText:rightString];
		[[self stack] pushController: controller];
        
    }
    if (selected == ([_locations count]+1)) {
        BRTextEntryController *controller = [[BRTextEntryController alloc] init];
		[controller setTitle:@"Input search string to use"];
		[controller setTextEntryTextFieldLabel:@"Search"];
        //[controller setListIcon:[[BRThemeInfo sharedTheme]appleTVIcon]];
        [controller setTextFieldDelegate:self];
        //[controller setTextEntryStyle:2];
        searchType=2;
		//[controller setInitialTextEntryText:rightString];
		[[self stack] pushController: controller];
    }
}
- (void) textDidChange: (id) sender
{
    // do nothing for now
}

- (void) textDidEndEditing: (id) sender
{
    if (searchType==1) 
    {
        [self addLocation:[sender stringValue]];
        [[self stack] popController];
    }
    else if(searchType==2)
    {

        NSString *url = [NSString stringWithFormat:@"http://where.yahooapis.com/v1/places.q('%@');start=0;count=5?appid=%@",[[sender stringValue] stringByReplacingOccurrencesOfString:@" " withString:@"\%20"],YAHOO_API,nil];
        NSStringEncoding s;
        NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] usedEncoding:&s error:nil];
        SMFDocument *doc = [SMFDocument documentWithXMLString:str];
        SMFElement *elt = [doc rootElement];
    
        NSArray *val2=[elt childrenNamed:@"place"];
        NSMutableArray *cities = [[NSMutableArray alloc] init];
        NSMutableArray *invocations=[[NSMutableArray alloc]init];
        for (SMFElement *el in val2) 
        {
            NSString *v = [el firstChildElementNamed:@"name"].value;
            NSString *c = [el firstChildElementNamed:@"country"].value;
            NSString *st = [el firstChildElementNamed:@"admin1"].value;
            NSString *w = [el firstChildElementNamed:@"woeid"].value;
            NSInvocation *invocation =[SMFInvocationCenteredMenuController invocationsForObject:self 
                                                                               withSelectorVal:@"addLocation:" 
                                                                                  withArguments:[NSArray arrayWithObject:w]];
            [cities addObject:[NSString stringWithFormat:@"%@, %@ %@",v,c,(st?st:@""),nil]];
            [invocations addObject:invocation];
            
        }
        SMFInvocationCenteredMenuController *ctrl = [[SMFInvocationCenteredMenuController alloc] initWithTitles:cities 
                                                                                                withInvocations:invocations 
                                                                                                      withTitle:@"Select Location" 
                                                                                                withDescription:@"Please select the appropriate city"];
        [cities release];
        [invocations release];
        [[self stack]swapController:ctrl];
        
        
        
    }

}
-(void)addLocation:(NSString *)cc
{
    
    NSDictionary *d = [MainMenuWeatherControl loadDictionaryForCode:cc usUnits:NO]; 
    if (d!=nil) {
        NSString *city = [d objectForKey:@"city"];
//        NSString *code = [d objectForKey:@"code"];
        NSString *units= @"c";
        if (units &&  cc && city) {
             NSString *filter = [city stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@",filter,nil];
            NSArray *filteredArray = [[NSTimeZone knownTimeZoneNames] filteredArrayUsingPredicate:predicate];
            NSString *timeZone=@"America/Chicago";
            if ([filteredArray count]==1) {
                timeZone=[filteredArray objectAtIndex:0];
            }
            NSDictionary *dd = [NSDictionary dictionaryWithObjectsAndKeys:
                                city,@"name",
                                cc,@"location",
                                units,@"units",
                                timeZone,@"timeZone",nil];
            NSMutableDictionary *ddd = [NSMutableDictionary dictionaryWithContentsOfFile:NEWWeatherFile];
            if (ddd==nil) {
                ddd=[NSMutableDictionary dictionary];
            }
            [ddd setObject:dd forKey: cc];
            [ddd writeToFile:NEWWeatherFile atomically:YES];
        }
    }
}
-(void)wasExhumed
{
    [self reloadLocations];
    [super wasExhumed];
}
@end
