//
//  Geolocationattachment.h
//  GeolocationAttachment
//
//  Created by Ken Zhou on 28/11/2013.
//  Copyright (c) 2013 Ken Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "LocationAttachmentCoreData.h"

/** This is a Geolocation attachment with location attributres. */
@interface GeolocationAttachment : NSObject

@property (readwrite, nonatomic) NSString *throughfare;
@property (readwrite, nonatomic) NSString *subthroughfare;
@property (readwrite, nonatomic) NSString *locality;
@property (readwrite, nonatomic) NSString *sublocality;
@property (readwrite, nonatomic) NSString *administrativearea;
@property (readwrite, nonatomic) NSString *subadministrativearea;
@property (readwrite, nonatomic) NSString *region;
@property (readwrite, nonatomic) NSString *postalcode;
@property (readwrite, nonatomic) NSString *isocountrycode;
@property (readwrite, nonatomic) NSString *country;
@property (readwrite, nonatomic) long long attachmentID;
@property (readwrite, nonatomic) NSString *addressName;

@property (readwrite, nonatomic) CLLocationCoordinate2D coordinate;

@property (readwrite, nonatomic) NSString *locationImageUrl;

@property (readwrite, nonatomic) NSString *locationImageName;




- (id)init;

- (id)initWithAttributes:(NSDictionary *)attributes;

- (id)initWithLocationAttachmentCoreData:(LocationAttachmentCoreData *)locationAttachmentCoreData;

- (NSString *)addressDisplayTextLine1;

- (NSString *)addressDisplayTextLine2;


@end