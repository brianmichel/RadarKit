//
//  Init.m
//  RadarKit
//
//  Created by Jacob Wan on 2015-03-26.
//  Copyright (c) 2015 Cedexis. All rights reserved.
//

#import "Init.h"

@interface Init()
@property NSString * _currentValue;
@end

@implementation Init

@synthesize _zoneId;
@synthesize _customerId;
@synthesize _majorVersion;
@synthesize _minorVersion;
@synthesize _initTimestamp;
@synthesize _protocol;
@synthesize _requestSignature;

-(id)initWithZoneId:(int)zoneId CustomerId:(int)customerId Timestamp:(unsigned long)timestamp AndProtocol:(NSString *)protocol {
    if (self = [super init]) {
        self._zoneId = zoneId;
        self._customerId = customerId;
        self._majorVersion = 0;
        self._minorVersion = 2;
        self._initTimestamp = timestamp;
        self._transactionId = arc4random();
        self._protocol = protocol;
        self._requestSignature = nil;
    }
    return self;
}

-(NSString *) url {
    NSString * flag = @"i";
    if ([self._protocol isEqualToString:@"https"]) {
        flag = @"s";
    }
    return [NSString stringWithFormat:@"%@://i1-io-%d-%d-%d-%d-%lu-%@.%@/i1/%lu/%lu/xml?seed=i1-io-%d-%d-%d-%d-%lu-%@",
            self._protocol,
            self._majorVersion,
            self._minorVersion,
            self._zoneId,
            self._customerId,
            self._transactionId,
            flag,
            @"init.cedexis-radar.net",
            self._initTimestamp,
            self._transactionId,
            self._majorVersion,
            self._minorVersion,
            self._zoneId,
            self._customerId,
            self._transactionId,
            flag
    ];
}

-(NSString *)makeRequest {
    NSURL * url = [NSURL URLWithString:[self url]];
    NSLog(@"%@", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
        cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20.0];
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
        returningResponse:&response error:&error];
    
    if ((nil != data) && (200 == [response statusCode])) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        [parser parse];
    }
    else {
        NSLog(@"Radar communication error (init)");
    }
    
    return self._requestSignature;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //NSLog(@"Element ended: %@", elementName);
    if ([elementName isEqualToString:@"requestSignature"]) {
        self._requestSignature = self._currentValue;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //NSLog(@"Found characters: %@", string);
    self._currentValue = string;
}

@end
