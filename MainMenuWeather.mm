#import "MainMenuWeather.h"
#import "SMWeather/SMWeatherControl.h"
#import "MainMenuWeatherController.h"
//#import <SMFramework/SMFColorSelectionMenu.h>
#import <UIKit/UIKit.h>
#import <SMFramework/SMFramework.h>
static int reportCount = 0;
static SMWeatherControl *_control;

@implementation MainMenuWeatherControl

+(SMWeatherControl *)control
{
    if (_control==nil) {
        _control=[[SMWeatherControl alloc]init];
        [_control retain];
        [_control retain];
    }
    return _control;
    
}
+(BOOL)enabled
{
    return [MainMenuWeatherController enabled];
}
+(NSString *)displayName
{
    [[SMFCommonTools sharedInstance]test];
    return @"Main Menu Weather";
}
+(BRMenuController *)configurationMenu
{

    //[[[BRApplicationStackManager singleton] stack] pushController:[c autorelease]];
    //SMFColorSelectionMenu *c = [SMFColorSelectionMenu colorMenuForKey:@"hello" andDelegate:self];
    [[SMFCommonTools sharedInstance]test];
    MainMenuWeatherController *ctrl = [[MainMenuWeatherController alloc]init];
    return [ctrl autorelease];
}
+(void)reload
{
    //NSLog(@"control: %@",_control);
    if (_control==nil) {
        return;
    }
    [_control retain];
    [_control reload];
    
}
-(BRControl *)backgroundControl
{
    
    if (_control==nil) {
        _control=[[SMWeatherControl alloc]init];
        [_control retain];
        [_control retain];
    }
    else {
        return _control;
    }
    
    CGRect frame;
    frame.origin=CGPointMake(0.0f, 0.0f);
    CGSize bounds =[BRWindow maxBounds];
    bounds.height=bounds.height/2.0f;
    frame.size=bounds;
    [_control setFrame:frame];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(callU) userInfo:nil repeats:NO];
    return _control;
    
}
-(void)callU
{
    int time = 10;
    [_control reload];
    [NSTimer scheduledTimerWithTimeInterval:time*60 target:self selector:@selector(callU) userInfo:nil repeats:NO];
}
+(NSDictionary *)loadDictionaryForCode:(NSString *)code usUnits:(BOOL)us
{
    NSURL *url;
    if (us) {
        url=[NSURL URLWithString:[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%@",code,nil]];
        
    }
    else
        url=[NSURL URLWithString:[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%@&u=c",code,nil]];
//    NSLog(@"URL: %@",url);
//    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
//	NSURLResponse *response = nil;
//    NSError *error;
//	NSData *documentData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    NSLog(@"data: %@",documentData);
//    NSLog(@"before doc");
//    APDocument *doc;
//    NSLog(@"After doc");
////    if (error!=nil) {
////        NSLog(@"error: %@",error);
////        return [NSDictionary dictionary];
////    }
////    else {
//        NSLog(@"goodTimes");
//        NSStringEncoding responseEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)[response textEncodingName]));
//        NSString *documentString = [[NSString alloc] initWithData:documentData encoding:responseEncoding];
//        NSLog(@"documentString: %@",documentString);
//        doc=[APDocument documentWithXMLString:documentString];
//        [documentString release];
//        
////    }
//    NSLog(@"doc: %@",doc);
    NSStringEncoding enc;
    NSString *theString = [NSString stringWithContentsOfURL:url usedEncoding:&enc error:nil];
	SMFDocument *xmlDoc = [SMFDocument documentWithXMLString:theString];
    //NSDictionary *dict = [SMYahooWeather parseYahooRSS:doc];
//    [doc release];
//    return dict;
    NSDictionary *d = [MainMenuWeatherControl parseYahooRSS:xmlDoc];
    return d;
}
+(NSDictionary *)parseYahooRSS:(SMFDocument*)apDoc
{
	id rootElt = [[[apDoc rootElement] childElements] objectAtIndex:0];
	
#define XMLATSTR(dict,element,key)    [(dict) setObject:[(element) valueForAttributeNamed:(key)]forKey:(key)]
#define XMLATSTRK(dict,element,key,keyt)    [(dict) setObject:[(element) valueForAttributeNamed:(key)] forKey:(keyt)]
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    id val =[rootElt firstChildElementNamed:@"yweather:location"];
    
	if (val != nil)
	{
		XMLATSTR(dict,val,@"city");
        XMLATSTR(dict,val,@"region");
        XMLATSTR(dict,val,@"country");
	}
	
	val = [rootElt firstChildElementNamed:@"yweather:units"];
	
	if (val != nil)
    {
        XMLATSTR(dict,val,@"temperature");
        XMLATSTR(dict,val,@"distance");
        XMLATSTRK(dict,val,@"pressure",@"pressureU");
        XMLATSTRK(dict,val,@"speed",@"speedU");
    }
	
	val = [rootElt firstChildElementNamed:@"yweather:wind"];
    
	if (val != nil)
    {
        
        XMLATSTR(dict,val,@"chill");
        XMLATSTR(dict,val,@"direction");
        XMLATSTR(dict,val,@"speed");
    }
	
	val = [rootElt firstChildElementNamed:@"yweather:atmosphere"];
    if (val != nil)
    {
        
        XMLATSTR(dict,val,@"humidity");
        XMLATSTR(dict,val,@"visibility");
        XMLATSTR(dict,val,@"pressure");
        XMLATSTR(dict,val,@"rising");
    }
    val = [rootElt firstChildElementNamed:@"yweather:astronomy"];
	if (val != nil)
    {
        
        XMLATSTR(dict,val,@"sunrise");
        XMLATSTR(dict,val,@"sunset");
    }
	
	val=[rootElt firstChildElementNamed:@"item"];
    //NSLog(@"val: %@",val);
    if (val != nil) {
        SMFElement *elt = val;
        val=[elt firstChildElementNamed:@"yweather:condition"];
        if (val!=nil) {
            
            XMLATSTR(dict,val,@"text");
            XMLATSTR(dict,val,@"code");
            XMLATSTR(dict,val,@"temp");
            XMLATSTR(dict,val,@"date");
        }
		
		val=[elt firstChildElementNamed:@"title"];
		
		if(val!=nil)
        {
			NSString *title=[val value];
			[dict setObject:title forKey:@"title"];
			//NSLog(@"elt2: %@", elt2);
		}
		
		
		val=[elt childElements:@"yweather:forecast"];
		//NSLog(@"yweather:forecast childElements: %@", val);
        if ([val count] > 0)
        {
            NSMutableArray *forecasts=[[NSMutableArray alloc]init];
            NSUInteger i;
            for(i=0;i<[val count];i++)
            {
                NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]init];
                SMFElement *elt2=[val objectAtIndex:i];
                XMLATSTR(tempDict,elt2,@"day");
                XMLATSTR(tempDict,elt2,@"date");
                XMLATSTR(tempDict,elt2,@"low");
                XMLATSTR(tempDict,elt2,@"high");
                XMLATSTR(tempDict,elt2,@"text");
                XMLATSTR(tempDict,elt2,@"code");
                [forecasts addObject:tempDict];
				[tempDict release];
            }
            [dict setObject:forecasts forKey:@"forecast"];
			[forecasts release];
        }
	}
	//NSLog(@"dict; %@", dict);
	
	return [dict autorelease];
}
-(void)test
{
    NSString * evanston = @"2400737";
    [MainMenuWeatherControl loadDictionaryForCode:evanston usUnits:NO];
}
@end

// vim:ft=objc
