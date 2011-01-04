/*
 Copyright 2009, Arash Payan (http://arashpayan.com)
 This library is distributed under the terms of the GNU Lesser GPL.
 
 This file is part of SMFXML.
 
 SMFXML is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 SMFXML is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with SMFXML.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "APDocument.h"
#import "APElement.h"

/*
 You probably only need to care about this class if you want to make
 changes to the way SMFXML builds SMFDocuments.
 
 This class is used as the NSXMLParser delegate that's responsible for
 building SMFDocuments.
*/
@interface SMFXMLBuilder : NSObject<NSXMLParserDelegate>
{
	SMFElement *rootElement;
	SMFElement *openElement;
	SMFElement *parentElement;
}

- (SMFElement*)rootElement;

@end

@implementation SMFXMLBuilder

- (id)init {
	if ((self = [super init])!=nil)
	{
		rootElement = nil;
		openElement = nil;
		parentElement = nil;
	}
	
	return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	SMFElement *newElement = [SMFElement elementWithName:elementName attributes:attributeDict];
	if (rootElement == nil)
		rootElement = [newElement retain];
	
	if (openElement != nil)
	{
		newElement.parent = openElement;
		parentElement = openElement;
		openElement = newElement;
	}
	else
	{
		newElement.parent = parentElement;
		openElement = newElement;
	}
	if (parentElement != nil)
		[parentElement addChild:openElement];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (openElement != nil)
	{
		openElement = parentElement;
		parentElement = parentElement.parent;
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError {
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[openElement appendValue:string];
}

/*
 Returns the root element of the document that was parsed in.
*/
- (SMFElement*)rootElement {
	return rootElement;
}

- (void) dealloc
{
	[rootElement release];
	
	[super dealloc];
}


@end




/*
 DOM representation of an XML document
*/
@implementation SMFDocument

/*
 Returns an SMFDocument representation of the specified xml. Should be used
 if you want to read in some XML as a document and want to manipulate it as
 such.
*/
+ (id)documentWithXMLString:(NSString*)anXMLString {
	return [[[SMFDocument alloc] initWithString:anXMLString] autorelease];
}

/*
 Initializes the document with a root element. This should be used
 if you're creating a new document programmatically.
*/
- (id)initWithRootElement:(SMFElement*)aRootElement {
	if ((self = [super init])!=nil)
	{
		rootElement = [aRootElement retain];
	}
	
	return self;
}

/*
 Initializes the document with an XML string.
*/
- (id)initWithString:(NSString*)anXMLString {
	if ((self = [super init])!=nil)
	{
		SMFXMLBuilder *builder = [[SMFXMLBuilder alloc] init];
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[anXMLString dataUsingEncoding:NSUTF8StringEncoding]];
		[parser setDelegate:builder];
		[parser parse];
		
		rootElement = [[builder rootElement] retain];
		
		[builder release];
		[parser release];
	}
	
	return self;
}

/*
 Returns the document's root element
*/
- (SMFElement*)rootElement {
	return rootElement;
}

/*
 Returns a pretty string representation of the document with newlines
 and tabs.
*/
- (NSString*)prettyXML {
	if (rootElement != nil)
	{
		NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
		[result appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"];
		[result appendString:[rootElement prettyXML:0]];
		return result;
	}
	else
		return nil;
}

/*
 Returns a compact string representation of the document without newlines
 or tabs.
*/
- (NSString*)xml {
	if (rootElement != nil)
	{
		NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
		[result appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"];
		[result appendString:[rootElement xml]];
		return result;
	}
	else
		return nil;
}

- (void) dealloc
{
	[rootElement release];
	
	[super dealloc];
}


@end
