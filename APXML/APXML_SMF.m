//
//  APXML_SMF.m
//  MMWeather
//
//  Created by Thomas Cool on 10/24/10.
//  Copyright 2010 tomcool.org. All rights reserved.
//

#import "APXML_SMF.h"


@implementation SMFElement (SMF)
-(NSArray *)childrenNamed:(NSString *)aName
{
        int numElements = [childElements count];
        int i;
    NSMutableArray *ar = [[NSMutableArray alloc] init];
        for (i = 0; i<numElements; i++)
        {
            SMFElement *currElement = [childElements objectAtIndex:i];
            if ([currElement.name isEqual:aName])
                [ar addObject:currElement];
        }
        
        return [ar autorelease];
}
@end
