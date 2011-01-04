//
//  SMWeatherControl.m
//  SoftwareMenu
//
//  Created by Thomas Cool on 3/14/10.
//  Copyright 2010 Thomas Cool. All rights reserved.
//
//#import "../../Headers/PrivateHeaders/CATransition.h"
//#import <QuartzCore/CATransition.h>
#import "SMWeatherControl.h"
//#import "../../Headers/PrivateHeaders/CAMediaTimingFunction.h"
#import "../MainMenuWeather.h"
#import <UIKit/UIColor.h>
//#import "SMYahooWeather.h"
//#import "SMWeatherController.h"
#define bundleImag(name,ext)    [BRImage imageWithPath:[[NSBundle bundleForClass:[self class]]pathForResource:(name) ofType:(ext)]]
#define bundleResc(name,ext)    [[NSBundle bundleForClass:[self class]]pathForResource:(name) ofType:(ext)]
#define plitFile [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.tomcool.weather.plist"]
#define NEWWeatherFile [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.tomcool.mainmenu.weather.plist"]
#define OPACITY     1.0
NSString * directionStringFromAngle(int angle)
{
    NSString *d=nil;
    if (angle<11)
        d=@"N";
    else if(angle<34)
        d=@"NNE";
    else if(angle<56)
        d=@"NE";
    else if(angle<79)
        d=@"ENE";
    else if(angle<101)
        d=@"E";
    else if(angle<123)
        d=@"ESE";
    else if(angle<146)
        d=@"SE";
    else if(angle<168)
        d=@"SSE";
    else if(angle<191)
        d=@"S";
    else if(angle<213)
        d=@"SSW";
    else if(angle<236)
        d=@"SW";
    else if(angle<258)
        d=@"WSW";
    else if(angle<281)
        d=@"W";
    else if(angle<303)
        d=@"WNW";
    else if(angle<326)
        d=@"NW";
    else if(angle<348)
        d=@"NNW";
    else
        d=@"N";
    return d;
}
@implementation SMWeatherControl
-(id)init
{
    self=[super init];
    _city=[[BRTextControl alloc]init];
    _centerImage=[[BRImageControl alloc]init];
    _infoDict=[[NSMutableArray alloc]init];
    _firstLoad=YES;
    menuItemsTextAttributes=[[[BRThemeInfo sharedTheme]menuItemTextAttributes] mutableCopy];
    menuTitleTextAttributes=[[[BRThemeInfo sharedTheme]menuTitleTextAttributes] mutableCopy];
    [menuTitleTextAttributes setObject:[NSNumber numberWithInt:0] forKey:@"BRTextAlignmentKey"];
    labelTextAttributes=[[[BRThemeInfo sharedTheme] labelTextAttributes] mutableCopy];
    metaDataTitleAttributes=[[[BRThemeInfo sharedTheme]metadataTitleAttributes] mutableCopy];
//    UIColor *c = [UIColor blackColor];
//    [metaDataTitleAttributes setObject:[c CGColor] forKey:@"CTForegroundColor"];
//    [menuTitleTextAttributes setObject:[c CGColor] forKey:@"CTForegroundColor"];
//    [labelTextAttributes setObject:[c CGColor] forKey:@"CTForegroundColor"];

    
//    [self drawControls];
    
    return self;
}
- (BOOL)brEventAction:(id)action
{
    NSLog(@"action: %@",action);
    return [super brEventAction:action];
}
- (BOOL)brKeyEvent:(id)event
{
    NSLog(@"event: %@",event);
    return [super brKeyEvent:event];
}
-(CGRect)addText:(NSString *)text inControl:(BRTextControl *)ctrl withAttributes:(NSDictionary *)attributes atPoint:(CGPoint )p
{
    CGRect r;
    r.origin=p;
    [ctrl setText:text withAttributes:attributes];
    r.size=[ctrl renderedSize];
    [ctrl setOpacity:OPACITY];
    [self addControl:ctrl];
    return r;
}

-(void)drawControls;
{
    [_city removeFromParent];
    [_city release];
    [_region_country removeFromParent];
    [_region_country release];
    
    _city=[[BRTextControl alloc]init];
    _region_country=[[BRTextControl alloc]init];
    
    
    /*
     *      Adding City Name
     */
    _error = [[BRTextControl alloc]init];
    [_error setText:@"Error, Please Check the Selected Location" withAttributes:menuTitleTextAttributes];
    CGSize s = [_error renderedSize];
    CGRect f;
    f.size=s;
    f.origin.x=([BRWindow maxBounds].width-f.size.width)/2.0f;
    f.origin.y=[BRWindow maxBounds].height*0.75f;
    [_error setHidden:YES];
    [_error setFrame:f];
    [self addControl:_error];
    

    [_city setText:@"(Cannot Load)            " withAttributes:menuTitleTextAttributes];
    CGRect nframe;
    CGRect masterFrame;
    masterFrame.origin.x=0.f;
    masterFrame.origin.y=0.f;
    masterFrame.size = [BRWindow maxBounds];
    nframe.size = [_city renderedSize];
    nframe.origin.x=masterFrame.origin.x+masterFrame.size.width*0.05f;
    nframe.origin.y=masterFrame.origin.y+masterFrame.size.height-nframe.size.height*1.3;
    [_city setFrame:nframe];
    [_city setOpacity:OPACITY];
    [self addControl:_city];
    CGPoint topLeft=nframe.origin;
    topLeft.y=topLeft.y+nframe.size.height;
    
    [_region_country setText:@"(null)                           " withAttributes:labelTextAttributes];
    nframe.origin.y=nframe.origin.y-[_region_country renderedSize].height*1.1;
    nframe.size=[_region_country renderedSize];
    [_region_country setFrame:nframe];
    [_region_country setOpacity:OPACITY];
    [self addControl:_region_country];
    
    
    
    BRDividerControl *ctrl3 = [[BRDividerControl alloc] init];
    [ctrl3 setLineThickness:2];
    [ctrl3 setBrightness:1.0f];
    [ctrl3 setOpacity:OPACITY];
    nframe.origin.y = nframe.origin.y-[ctrl3 recommendedHeight];
    nframe.origin.x = masterFrame.origin.x+masterFrame.size.width*0.05;
    nframe.size.width=masterFrame.size.width*0.9f;
	nframe.size.height = [ctrl3 recommendedHeight];
    [ctrl3 setFrame:nframe];
    [self addControl: ctrl3];
    CGPoint pt_two = nframe.origin;
    
    
    
    BRImage *image=[self imageForCode:[_infoDict objectForKey:@"code"]];
    [_centerImage setImage:image];
    CGRect imgFrame;
    imgFrame.size.height=topLeft.y-pt_two.y;
    imgFrame.size.width=imgFrame.size.height*[image aspectRatio];
    imgFrame.origin.x=([BRWindow maxBounds].width*1.1-imgFrame.size.width)/2.;
    imgFrame.origin.y=pt_two.y;
    [_centerImage setFrame:imgFrame];
    [_centerImage setOpacity:OPACITY];
    [self addControl:_centerImage];
    CGRect tframe=imgFrame;
    
    
    /*
     *  Adding Temperature
     */
    
    [_temperature removeFromParent];
    [_temperature release];
    _temperature=[[BRTextControl alloc]init];
    [_temperature setText:@"???°?"//[NSString stringWithFormat:@"???°?",[_infoDict objectForKey:@"temp"],[_infoDict objectForKey:@"temperature"],nil]
           withAttributes:menuTitleTextAttributes];
    tframe.origin.x=imgFrame.origin.x-[_temperature renderedSize].width*1.3;
    tframe.origin.y=tframe.origin.y+(tframe.size.height-[_temperature renderedSize].height)/2.f;
    tframe.size=[_temperature renderedSize];
    [_temperature setOpacity:OPACITY];
    [_temperature setFrame:tframe];
    [self addControl:_temperature];
    
    /*
     *  Adding Date
     */
    tframe=imgFrame;
    [_date removeFromParent];
    [_date release];
    _date=[[SMFClockController alloc]init];

    tframe.origin.x=tframe.origin.x+tframe.size.width*1.3;
    tframe.origin.y=tframe.origin.y+(tframe.size.height-[_date renderedSize].height)/2.f;
    tframe.size=[_date renderedSize];
    [_date setOpacity:OPACITY];
    [_date setFrame:tframe];
    [self addControl:_date];

    
    BRTextControl *sunriseText = [[BRTextControl alloc]init];
    [sunriseText setText:@"Sunrise:" withAttributes:metaDataTitleAttributes];
    nframe.origin.y=nframe.origin.y-[sunriseText renderedSize].height*1.f;
    nframe.size=[sunriseText renderedSize];
    [sunriseText setOpacity:OPACITY];
    [sunriseText setFrame:nframe];
    [self addControl:sunriseText];
    CGPoint pt_three=nframe.origin;
    
    [_sunrise removeFromParent];
    [_sunrise release];
    _sunrise=[[BRTextControl alloc] init];
    [_sunrise setText:@"???                    " withAttributes:metaDataTitleAttributes];
    nframe.origin.x=nframe.origin.x+nframe.size.width*1.2f;
    nframe.size=[_sunrise renderedSize];
    [_sunrise setOpacity:OPACITY];
    [_sunrise setFrame:nframe];
    [self addControl:_sunrise];
    
    sunriseText = [[BRTextControl alloc]init];
    [sunriseText setText:@"Sunset:" withAttributes:metaDataTitleAttributes];
    nframe.origin=pt_three;
    nframe.origin.y=nframe.origin.y-[sunriseText renderedSize].height*1.f;
    nframe.size=[sunriseText renderedSize];
    [sunriseText setOpacity:OPACITY];
    [sunriseText setFrame:nframe];
    [self addControl:sunriseText];
    
    [_sunset removeFromParent];
    [_sunset release];
    _sunset=[[BRTextControl alloc] init];
    [_sunset setText:@"???                    " withAttributes:metaDataTitleAttributes];
    nframe.origin=[_sunrise frame].origin;
    nframe.origin.y=nframe.origin.y-[_sunset renderedSize].height*1.1f;
    nframe.size=[_sunset renderedSize];
    [_sunset setOpacity:OPACITY];
    [_sunset setFrame:nframe];
    [self addControl:_sunset];
    
    
    nframe.origin.y=pt_three.y;
    nframe.origin.x+=[BRWindow maxBounds].width*0.26;
    BRTextControl *windControl;// = [[BRTextControl alloc]init];
    windControl = [[BRTextControl alloc]init];
    [windControl setText:@"Wind Direction:" withAttributes:metaDataTitleAttributes];
    [windControl setOpacity:OPACITY];
    nframe.size=[windControl renderedSize];
    [windControl setFrame:nframe];
    [self addControl:windControl];
    
    float width = [windControl renderedSize].width*1.1;
    [_windDirection removeFromParent];
    [_windDirection release];
    _windDirection=[[BRTextControl alloc]init];
    [_windDirection setText:@"???                    " 
             withAttributes:metaDataTitleAttributes];
    CGRect wframe=nframe;
    wframe.origin.x=wframe.origin.x+width;
    wframe.size=[_windDirection renderedSize];
    [_windDirection setFrame:wframe];
    [_windDirection setOpacity:OPACITY];
    [self addControl:_windDirection];
    
    
    nframe.origin.y=nframe.origin.y-[windControl renderedSize].height*1.f;
    windControl = [[BRTextControl alloc]init];
    [windControl setText:@"Wind Speed:" withAttributes:metaDataTitleAttributes];
    [windControl setOpacity:OPACITY];
    nframe.size=[windControl renderedSize];
    [windControl setFrame:nframe];
    [self addControl:windControl];
    
    wframe.origin.y-=[_windDirection renderedSize].height*1.f;
    [_windSpeed removeFromParent];
    [_windSpeed release];
    _windSpeed=[[BRTextControl alloc]init];
    [_windSpeed setText:@"???                    "
         withAttributes:metaDataTitleAttributes];
    wframe.size=[_windSpeed renderedSize];
    [_windSpeed setFrame:wframe];
    [_windSpeed setOpacity:OPACITY];
    [self addControl:_windSpeed];
    
    
    nframe.origin.y=nframe.origin.y-[windControl renderedSize].height*1.f;
    windControl = [[BRTextControl alloc]init];
    [windControl setText:@"Wind Chill:" withAttributes:metaDataTitleAttributes];
    [windControl setOpacity:OPACITY];
    nframe.size=[windControl renderedSize];
    [windControl setFrame:nframe];
    [self addControl:windControl];
    
    wframe.origin.y-=[_windDirection renderedSize].height*1.f;
    [_windChill removeFromParent];
    [_windChill release];
    _windChill=[[BRTextControl alloc]init];
    [_windChill setText:@"???                    "
         withAttributes:metaDataTitleAttributes];
    wframe.size=[_windChill renderedSize];
    [_windChill setFrame:wframe];
    [_windChill setOpacity:OPACITY];
    [self addControl:_windChill];
    float lowestHeight = wframe.origin.y;
    
    
    nframe.origin.y=pt_three.y;
    nframe.origin.x+=[BRWindow maxBounds].width*0.36;
    BRTextControl *humidityControl;// = [[BRTextControl alloc]init];
    humidityControl = [[BRTextControl alloc]init];
    [humidityControl setText:@"Humidity:" withAttributes:metaDataTitleAttributes];
    [humidityControl setOpacity:OPACITY];
    nframe.size=[humidityControl renderedSize];
    [humidityControl setFrame:nframe];
    [self addControl:humidityControl];
    
    
    width = [humidityControl renderedSize].width*1.1;
    [_humidity removeFromParent];
    [_humidity release];
    _humidity=[[BRTextControl alloc]init];
    [_humidity setText:@"???                    "
             withAttributes:metaDataTitleAttributes];
    wframe=nframe;
    wframe.origin.x=wframe.origin.x+width;
    wframe.size=[_humidity renderedSize];
    [_humidity setFrame:wframe];
    [_humidity setOpacity:OPACITY];
    [self addControl:_humidity];    
    
    nframe.origin.y=nframe.origin.y-[windControl renderedSize].height*1.f;
    windControl = [[BRTextControl alloc]init];
    [windControl setText:@"Pressure:" withAttributes:metaDataTitleAttributes];
    [windControl setOpacity:OPACITY];
    nframe.size=[windControl renderedSize];
    [windControl setFrame:nframe];
    [self addControl:windControl];
    
    wframe.origin.y-=[_windDirection renderedSize].height*1.f;
    [_pressure removeFromParent];
    [_pressure release];
    _pressure=[[BRTextControl alloc]init];
    [_pressure setText:@"???                    "
         withAttributes:metaDataTitleAttributes];
    wframe.size=[_pressure renderedSize];
    [_pressure setFrame:wframe];
    [_pressure setOpacity:OPACITY];
    [self addControl:_pressure];
    
    ctrl3 = [[BRDividerControl alloc] init];
    [ctrl3 setLineThickness:2];
    [ctrl3 setBrightness:1.0f];
    [ctrl3 setOpacity:OPACITY];
    [ctrl3 setLabel:@"Forecast" withAttributes:metaDataTitleAttributes];
    CGColorRef c = [[UIColor redColor] CGColor];
    [ctrl3 setBorderColor:c];
    nframe.origin.y = lowestHeight-[ctrl3 recommendedHeight];//+[ctrl3 recommendedHeight];//[ctrl2 recommendedHeight]*2.f-nframe.size.height*0.1f-masterFrame.size.height*0.25f;
    nframe.origin.x = masterFrame.origin.x+masterFrame.size.width*0.05;
    nframe.size.width=masterFrame.size.width*0.9f;
	nframe.size.height = [ctrl3 recommendedHeight];
    //frame.size.width = masterFrame.size.width-frame.origin.x-masterFrame.size.width*0.05f;
    [ctrl3 setFrame:nframe];
    [self addControl: ctrl3];
    CGPoint underForcast= nframe.origin;
    NSDictionary *forecast1=[[_infoDict objectForKey:@"forecast"] objectAtIndex:0];
   // NSDictionary *forecast2=[[_infoDict objectForKey:@"forecast"] objectAtIndex:1];
    
    _forecastDate1 = [[BRTextControl alloc]init];
    [_forecastDate1 setText:@"???                            " 
             withAttributes:metaDataTitleAttributes];
    nframe.origin.y=nframe.origin.y-[_forecastDate1 renderedSize].height*1.f;
    nframe.size=[_forecastDate1 renderedSize];
    [_forecastDate1 setOpacity:OPACITY];
    [_forecastDate1 setFrame:nframe];
    [self addControl:_forecastDate1];
    CGPoint pt_five=nframe.origin;
    
    BRTextControl *high=[[BRTextControl alloc]init];
    [high setText:@"High:" withAttributes:metaDataTitleAttributes];
    CGRect highFrame;
    highFrame.origin=nframe.origin;
    highFrame.size=[high renderedSize];
    highFrame.origin.x+=masterFrame.size.width*0.16;
    [high setOpacity:OPACITY];
    [high setFrame:highFrame];
    [self addControl:high];
    [high release];
    
    tframe= highFrame;
    tframe.origin.x+=[high renderedSize].width*1.1f;
    _forecastHigh1=[[BRTextControl alloc]init];
    [_forecastHigh1 setText:@"???                     "
             withAttributes:metaDataTitleAttributes];
    tframe.size=[_forecastHigh1 renderedSize];
    [_forecastHigh1 setFrame:tframe];
    [_forecastHigh1 setOpacity:OPACITY];
    [self addControl:_forecastHigh1];
    

    
    
    
    BRTextControl *low=[[BRTextControl alloc]init];
    [low setText:@"Low:" withAttributes:metaDataTitleAttributes];
    CGRect lowFrame;
    lowFrame.origin=nframe.origin;
    lowFrame.size=[low renderedSize];
    lowFrame.origin.x+=masterFrame.size.width*0.16;
    lowFrame.origin.y-=[low renderedSize].height;
    [low setOpacity:OPACITY];
    [low setFrame:lowFrame];
    [self addControl:low];
    [low release];
    
    _weatherImage1=[[BRImageControl alloc]init];
    image=[self imageForCode:@"3200"];
    [_weatherImage1 setImage:image];
    imgFrame.size.height=(underForcast.y-masterFrame.size.height*0.5)*0.95;
    imgFrame.size.width=imgFrame.size.height*[image aspectRatio];
    imgFrame.origin.x=lowFrame.origin.x+masterFrame.size.width*0.1;
    imgFrame.origin.y=masterFrame.size.height*0.54;//lowFrame.origin.y-lowFrame.size.height;
    [_weatherImage1 setFrame:imgFrame];
    [_weatherImage1 setOpacity:OPACITY];
    [self addControl:_weatherImage1];
    //NSLog(@"weather image1: %lf, %lf, %lf, %lf",imgFrame.size.height,imgFrame.size.width,imgFrame.origin.x,imgFrame.origin.y);

    
//    tframe= highFrame;
    tframe.origin.y-=[high renderedSize].height;
    _forecastLow1=[[BRTextControl alloc]init];
    [_forecastLow1 setText:@"???                     "
             withAttributes:metaDataTitleAttributes];
    tframe.size=[_forecastLow1 renderedSize];
    [_forecastLow1 setFrame:tframe];
    [_forecastLow1 setOpacity:OPACITY];
    [self addControl:_forecastLow1];
    
    ctrl3 = [[BRDividerControl alloc]init];
    [ctrl3 setLineThickness:1];
    [ctrl3 setBrightness:0.5f];
    [ctrl3 setOpacity:OPACITY];
    CGRect dframe=nframe;
    dframe.origin.x=masterFrame.size.width*0.5;
    dframe.origin.y=masterFrame.size.height*0.58;
    
    dframe.size.width=[ctrl3 recommendedWidth];
    dframe.size.height=masterFrame.size.height*0.1;
    [ctrl3 setDividerOrientation:1];
    [ctrl3 setFrame:dframe];
    [self addControl:ctrl3];
    
    _forecastDate2 = [[BRTextControl alloc]init];
    [_forecastDate2 setText:@"???                            " withAttributes:metaDataTitleAttributes];
    //nframe.origin.y=//nframe.origin.y-[_forecastDate2 renderedSize].height*1.1f;
    nframe.origin.x=pt_five.x+masterFrame.size.width*0.5;
    nframe.origin.y=pt_five.y;
    nframe.size=[_forecastDate2 renderedSize];
    [_forecastDate2 setOpacity:OPACITY];
    [_forecastDate2 setFrame:nframe];
    [self addControl:_forecastDate2];
    
    

    
    

    high=[[BRTextControl alloc]init];
    [high setText:@"High:" withAttributes:metaDataTitleAttributes];
//    CGRect highFrame;
    highFrame.origin=nframe.origin;
    highFrame.size=[high renderedSize];
    highFrame.origin.x+=masterFrame.size.width*0.16;
    [high setOpacity:OPACITY];
    [high setFrame:highFrame];
    [self addControl:high];
    [high release];
    
    tframe= highFrame;
    tframe.origin.x+=[high renderedSize].width*1.1f;
    _forecastHigh2=[[BRTextControl alloc]init];
    [_forecastHigh2 setText:@"???                     "//[NSString stringWithFormat:@"%@°%@",[forecast2 objectForKey:@"high"],[_infoDict objectForKey:@"temperature"],nil]
             withAttributes:metaDataTitleAttributes];
    tframe.size=[_forecastHigh2 renderedSize];
    [_forecastHigh2 setFrame:tframe];
    [_forecastHigh2 setOpacity:OPACITY];
    [self addControl:_forecastHigh2];
    
    
    low=[[BRTextControl alloc]init];
    [low setText:@"Low:" withAttributes:metaDataTitleAttributes];
//    CGRect lowFrame;
    lowFrame.origin=nframe.origin;
    lowFrame.size=[low renderedSize];
    lowFrame.origin.x+=masterFrame.size.width*0.16;
    lowFrame.origin.y-=[low renderedSize].height;
    [low setOpacity:OPACITY];
    [low setFrame:lowFrame];
    [self addControl:low];
    [low release];
    
    _weatherImage2=[[BRImageControl alloc]init];

    image=[self imageForCode:[forecast1 objectForKey:@"code"]];
    [_weatherImage2 setImage:image];
    imgFrame.size.height=(underForcast.y-masterFrame.size.height*0.5)*0.95;
    imgFrame.size.width=imgFrame.size.height*[image aspectRatio];
    imgFrame.origin.x=lowFrame.origin.x+masterFrame.size.width*0.1;
    imgFrame.origin.y=masterFrame.size.height*0.54;
    [_weatherImage2 setFrame:imgFrame];
    [_weatherImage2 setOpacity:OPACITY];
    [self addControl:_weatherImage2];
    
//    tframe= highFrame;
    tframe.origin.y-=[high renderedSize].height;
    _forecastLow2=[[BRTextControl alloc]init];
    [_forecastLow2 setText:@"???                     "//[NSString stringWithFormat:@"%@°%@",[forecast2 objectForKey:@"low"],[_infoDict objectForKey:@"temperature"],nil]
            withAttributes:metaDataTitleAttributes];
    tframe.size=[_forecastLow2 renderedSize];
    [_forecastLow2 setFrame:tframe];
    [_forecastLow2 setOpacity:OPACITY];
    [self addControl:_forecastLow2];
    

    
    
    
    
}
-(void)setText:(NSString *)text inControl:(BRTextControl *)ctrl withAttributes:(NSDictionary *)attributes withFrame:(CGRect )f
{
    
}
-(void)setText:(NSString *)text inControl:(BRTextControl *)ctrl withAttributes:(NSDictionary *)attributes atPoint:(CGPoint )p
{
    
}
-(void)setText:(NSString *)text inControl:(BRTextControl *)ctrl withAttributes:(NSDictionary *)attributes
{
    
//    CGRect oldFrame=[ctrl frame];
//    [ctrl removeFromParent];
    [ctrl setText:text
           withAttributes:attributes];
    [ctrl setOpacity:OPACITY];
    [ctrl setNeedsDisplay];
    
//    [ctrl setFrame:oldFrame];
//    [self addControl:ctrl];
}
-(void)setImage:(BRImage *)img inControl:(BRImageControl *)ctrl
{
    
    CGRect oldFrame=[ctrl frame];
    [ctrl removeFromParent];
    [ctrl setImage:img];
    [ctrl setFrame:oldFrame];
    [self addControl:ctrl];
}
-(NSString *)windDirectionForAngle:(NSString *)angle
{
    return directionStringFromAngle([angle intValue]);//[NSString stringWithFormat:@"%@°",angle,nil];
}
-(void)drawControlsN;
{
    if (_timezone!=nil) {
        [_date setTimeZone:_timezone];
        
    }

    
    /*
     *      Adding City Name
     */

    CGRect oldFrame=[_city frame];
    [_city removeFromParent];
    [_city setText:[_infoDict objectForKey:@"city"] withAttributes:menuTitleTextAttributes];
//    oldFrame.size = [_city renderedSize];
    [_city setFrame:oldFrame];
    [self addControl:_city];
    
    /*
     *      Adding Region and Country Subtitle
     */
    NSString *text;
    if ([[_infoDict objectForKey:@"region"]length]>0) {
        text=[NSString stringWithFormat:@"%@, %@",[_infoDict objectForKey:@"region"],[_infoDict objectForKey:@"country"]];
    }
    else {
        text=[_infoDict objectForKey:@"country"];
    }
    [self setText:text inControl:_region_country withAttributes:labelTextAttributes];

    /*
     *  Main Image
     */
    [self setImage:[self imageForCode:[_infoDict objectForKey:@"code"]forForecast:NO] 
         inControl:_centerImage];
    
    /*
     *  Adding Current Temperature
     */
    [self setText:[NSString stringWithFormat:@"%@°%@",[_infoDict objectForKey:@"temp"],[_infoDict objectForKey:@"temperature"],nil] 
        inControl:_temperature 
   withAttributes:menuTitleTextAttributes];


    [self setText:[_infoDict objectForKey:@"sunrise"] 
        inControl:_sunrise withAttributes:metaDataTitleAttributes];
    
    [self setText:[_infoDict objectForKey:@"sunset"] 
        inControl:_sunset withAttributes:metaDataTitleAttributes];

    [self setText:[self windDirectionForAngle:[_infoDict objectForKey:@"direction"]]
        inControl:_windDirection withAttributes:metaDataTitleAttributes];
    
    [self setText:[NSString stringWithFormat:@"%@ %@",[_infoDict objectForKey:@"speed"],[_infoDict objectForKey:@"speedU"],nil] 
        inControl:_windSpeed withAttributes:metaDataTitleAttributes];
    
    [self setText:[NSString stringWithFormat:@"%@°%@",[_infoDict objectForKey:@"chill"],[_infoDict objectForKey:@"temperature"],nil] 
        inControl:_windChill withAttributes:metaDataTitleAttributes];
    
    [self setText:[NSString stringWithFormat:@"%@%%",[_infoDict objectForKey:@"humidity"],nil]  
        inControl:_humidity withAttributes:metaDataTitleAttributes];
    
    [self setText:[NSString stringWithFormat:@"%@ %@",[_infoDict objectForKey:@"pressure"],[_infoDict objectForKey:@"pressureU"],nil] 
        inControl:_pressure withAttributes:metaDataTitleAttributes];
    
    /*
     *  Forecast
     */
    NSDictionary *forecast1=[[_infoDict objectForKey:@"forecast"] objectAtIndex:0];
    NSDictionary *forecast2=[[_infoDict objectForKey:@"forecast"] objectAtIndex:1];
    [self setText:[NSString stringWithFormat:@"%@, %@",[forecast1 objectForKey:@"day"],[forecast1 objectForKey:@"date"],nil] 
        inControl:_forecastDate1 withAttributes:metaDataTitleAttributes];
    
    [self setText:[NSString stringWithFormat:@"%@°%@",[forecast1 objectForKey:@"high"],[_infoDict objectForKey:@"temperature"],nil] 
        inControl:_forecastHigh1 withAttributes:metaDataTitleAttributes];
    
    [self setText:[NSString stringWithFormat:@"%@°%@",[forecast1 objectForKey:@"low"],[_infoDict objectForKey:@"temperature"],nil] 
        inControl:_forecastLow1 withAttributes:metaDataTitleAttributes];
    
    
    [self setText:[NSString stringWithFormat:@"%@, %@",[forecast2 objectForKey:@"day"],[forecast2 objectForKey:@"date"],nil] 
        inControl:_forecastDate2 withAttributes:metaDataTitleAttributes];
    
    [self setText:[NSString stringWithFormat:@"%@°%@",[forecast2 objectForKey:@"high"],[_infoDict objectForKey:@"temperature"],nil] 
        inControl:_forecastHigh2 withAttributes:metaDataTitleAttributes];
    
    [self setText:[NSString stringWithFormat:@"%@°%@",[forecast2 objectForKey:@"low"],[_infoDict objectForKey:@"temperature"],nil] 
        inControl:_forecastLow2 withAttributes:metaDataTitleAttributes];
    
    [self setImage:[self imageForCode:[forecast1 objectForKey:@"code"]forForecast:YES] 
         inControl:_weatherImage1];
    
    [self setImage:[self imageForCode:[forecast2 objectForKey:@"code"]forForecast:YES] 
         inControl:_weatherImage2];
    
    
    
}
-(void)setTimeZones:(NSString *)tz
{

    if (_timezone!=nil) {
        [_timezone release];
        _timezone=nil;
    }
    if (tz==nil) {
        return;
    }

    _timezone=[NSTimeZone timeZoneWithName:tz];
    [_timezone retain];
}
-(void)loadUsDictionaryForCode:(NSString *)code
{
    NSAutoreleasePool *newpool = [[NSAutoreleasePool alloc] init];
    NSDictionary *dict=[self loadDictionaryForCode:code usUnits:YES];
    [self performSelectorOnMainThread:@selector(setInfoDictionary:) withObject:dict waitUntilDone:NO];
    [newpool drain];
}
-(void)loadEuDictionaryForCode:(NSString *)code
{
    NSAutoreleasePool *newpool = [[NSAutoreleasePool alloc] init];
    
    NSDictionary *dict=[self loadDictionaryForCode:code usUnits:NO];
    [self performSelectorOnMainThread:@selector(setInfoDictionary:) 
                           withObject:dict 
                        waitUntilDone:NO];
    [newpool drain];
}
-(void)hideall
{
    NSArray *controls = [self controls];
    
    for(BRControl *ctrl in controls)
    {
        [ctrl setHidden:YES];
    }
    if (_error==nil) {

        
    }
    [_error setHidden:NO];

}
-(void)showall
{
    NSArray *controls = [self controls];
    for(BRControl *ctrl in controls)
    {
        //[ctrl setOpacity:OPACITY];
        [ctrl setHidden:NO];
    }
    [_error setHidden:YES];
}
-(NSDictionary *)loadDictionaryForCode:(NSString *)code usUnits:(BOOL)us
{
    return [MainMenuWeatherControl loadDictionaryForCode:code usUnits:us];
    
}

-(NSTimeZone *)timeZone
{
    return _timezone;
}

-(void)reload
{
    NSString *code;
    if ([[NSFileManager defaultManager] fileExistsAtPath:plitFile]) {
        NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:plitFile];
        code = [d objectForKey:@"mainmenuweather"];
        if(!code)
            code = @"2400737";
    }
    else
        code = @"2400737";
    
    NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:NEWWeatherFile];
    NSDictionary *obj = [d objectForKey:code];
    if (obj) {
        if ([[obj objectForKey:@"units"] localizedCaseInsensitiveCompare:@"f"]==NSOrderedSame) {
            [NSThread detachNewThreadSelector:@selector(loadUsDictionaryForCode:) toTarget:self withObject:code];
        }
        else
            [NSThread detachNewThreadSelector:@selector(loadEuDictionaryForCode:) toTarget:self withObject:code];

        if ([[obj allKeys] containsObject:@"timeZone"]) 
        {   NSLog(@"found Time Zone: %@",[obj objectForKey:@"timeZone"]);
            [self setTimeZones:[obj objectForKey:@"timeZone"]];
        }
        else
        {
            NSLog(@"no time zone found: %@",@"America/Chicago");
            [self setTimeZones:@"America/Chicago"];
            
        }
            
    }
    else
        [NSThread detachNewThreadSelector:@selector(loadEuDictionaryForCode:) toTarget:self withObject:code]; 
}
-(void)setInfoDictionary:(NSDictionary *)infoDict
{
    if (infoDict==nil) 
        infoDict=[NSDictionary dictionary];
    
    [_infoDict release];
    _infoDict=[infoDict retain];
    [self checkInfoDict];
    if(_firstLoad)
    {
        [self drawControls];
        [self drawControlsN];
        _firstLoad=NO;
    }
    else {
        [self drawControlsN];
    }
    if ([[_infoDict objectForKey:@"city"] isEqualToString:@"N/A                          ."]) {
        [self hideall];
    }
    else
        [self showall];
}
-(BRImage *)imageForCode:(NSString *)code
{
    return [self imageForCode:code forForecast:YES];
}
-(BRImage *)imageForCode:(NSString *)code forForecast:(BOOL)forecast
{
    if ([code intValue]<0 || [code intValue]>49) {
        return bundleImag(@"3200",@"png");
    }
    if ([code isEqualToString:@"3200"]) {
        return bundleImag(@"3200",@"png");
    }
    if (forecast) {
        code=[code stringByAppendingString:@"d"];
    }
    else {
        int sunrise=[self convertTimeToInt:[_infoDict objectForKey:@"sunrise"]];
        int sunset=[self convertTimeToInt:[_infoDict objectForKey:@"sunset"]];
        int c = [self convertCurrentTimeToInt];
        if (c>=sunrise && c<=sunset) {
            code=[code stringByAppendingString:@"d"];
        }
        else
            code=[code stringByAppendingString:@"n"];
    }
    NSString *path = bundleResc(code,@"png");
    if (path!=nil) {
        return [BRImage imageWithPath:path];
    }
    else
        return bundleImag(@"3200",@"png");
    
}
-(int)convertCurrentTimeToInt
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HHmm"];
    int t = [[outputFormatter stringFromDate:[NSDate date]]intValue];
    //NSLog(@"date: %@, %@, %@",time, rdate, [rdate descriptionWithCalendarFormat:@"%H%M" timeZone:_timezone locale:nil]);
    [outputFormatter release];
    return t;
}
-(int)convertTimeToInt:(NSString *)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"hh:mm a"]; 
    NSDate *rdate=[formatter dateFromString:time];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HHmm"];
    int t = [[outputFormatter stringFromDate:rdate]intValue];
    //NSLog(@"date: %@, %@, %@",time, rdate, [rdate descriptionWithCalendarFormat:@"%H%M" timeZone:_timezone locale:nil]);
    [formatter release];
    [outputFormatter release];
    return t;//[[rdate descriptionWithCalendarFormat:@"%H%M" timeZone:nil locale:nil]intValue];
}
-(NSDate*)parseDate:(NSString *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"EEE, dd MMM yyyy hh:mm a zzz"];
//    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
//    [fmt setDateStyle:NSDateFormatterFullStyle];
//    [fmt setTimeStyle:NSDateFormatterFullStyle];
    //NSDate *rdate2= [fmt dateFromString:date];
    NSDate *rdate = [formatter dateFromString:date];
    [formatter release];
    return rdate;
}
-(void)checkInfoDict
{


    NSArray *expectedKeys = [NSArray arrayWithObjects:@"chill",@"city",@"code",@"country",@"date",@"direction",
                             @"distance",@"humidity",@"pressure",@"region",@"rising",@"speed",@"speedU",
                             @"sunrise",@"sunset",@"temp",@"temperature",@"text",@"visibility",nil];
    NSMutableDictionary *dict=[_infoDict mutableCopy];
    NSArray *keys =[dict allKeys];
    int i,count=[expectedKeys count];
    for(i=0;i<count;i++)
    {
        if(![keys containsObject:[expectedKeys objectAtIndex:i]])
        {
            [dict setObject:@"N/A                          ." forKey:[expectedKeys objectAtIndex:i]];
        }
    }
    if(![keys containsObject:@"forecast"])
    {
        NSDictionary *forecast = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"3201",@"code",
                                  @"N/A                      .",@"date",
                                  @"N/A.",@"day",
                                  @"N/A     .",@"high",
                                  @"N/A     .",@"low",
                                  @"N/A             .",@"text",nil];
        [dict setObject:[NSArray arrayWithObjects:forecast,forecast,nil] forKey:@"forecast"];
    }
    [_infoDict release];
    _infoDict=[dict retain];
}
-(void)dealloc
{
    [_date release];
    [super dealloc];
}
@end
