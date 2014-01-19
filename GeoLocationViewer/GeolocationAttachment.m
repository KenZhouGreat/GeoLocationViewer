//
//  Geolocationattachment.m
//  GeolocationAttachment
//
//  Created by Ken Zhou on 28/11/2013.
//  Copyright (c) 2013 Ken Zhou. All rights reserved.
//

#import "GeolocationAttachment.h"

@implementation GeolocationAttachment

@synthesize coordinate = _coordinate;
@synthesize locationImageUrl = _locationImageUrl;
@synthesize locationImageName = _locationImageName;

@synthesize throughfare = _throughfare;
@synthesize subthroughfare = _subthroughfare;
@synthesize locality = _locality;
@synthesize sublocality = _sublocality;
@synthesize administrativearea = _administrativearea;
@synthesize subadministrativearea = _subadministrativearea;
@synthesize region = _region;
@synthesize postalcode = _postalcode;
@synthesize isocountrycode = _isocountrycode;
@synthesize country = _country;
@synthesize attachmentID = _attachmentID;
@synthesize addressName = _addressName;

-(id)init
{
    if(self = [super init])
    {
        _attachmentID = 0;
        _throughfare = nil;
        _subthroughfare = nil;
        _locality = nil;
        _sublocality = nil;
        _administrativearea = nil;
        _subadministrativearea = nil;
        _region = nil;
        _postalcode = nil;
        _isocountrycode = nil;
        _country = nil;
        _coordinate = CLLocationCoordinate2DMake(0, 0);
        _locationImageName = nil;
        _locationImageUrl = nil;
        _addressName = nil;
        //KZ: TODO: SN suggested to have attachmentId here
        
    }
    
    return self;
}

static NSString *kLatitude = @"Latitude";
static NSString *kLongitude = @"Longitude";
static NSString *kAddress = @"Address";
static NSString *kAddressId = @"AddressId";
static NSString *kThroughfare = @"Throughfare";
static NSString *kLocality = @"Locality";
static NSString *kSubLocality = @"SubLocality";
static NSString *kAdministrativeArea = @"AdministrativeArea";
static NSString *kPostalCode = @"PostalCode";
static NSString *kISOCountryCode = @"ISOCountryCode";
static NSString *kCountry = @"Country";
static NSString *kFileURI = @"FileURI";
NSString *kLocationAttachmentIdID = @"LocationAttachmentId";


static NSString *kAddressName = @"Name";

- (id)initWithAttributes:(NSDictionary *)attributes
{
    if(self = [super init])
    {
        //TODO
        double latitude = [[attributes valueForKey:kLatitude] doubleValue];
        double longitude = [[attributes valueForKey:kLongitude] doubleValue];
        [self setCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
        if (NULL_TO_NIL([attributes objectForKey:kAddress])) {
            NSDictionary *address = [attributes objectForKey:kAddress];
                [self setThroughfare:NULL_TO_NIL([address objectForKey:kThroughfare])];
                [self setLocality:NULL_TO_NIL([address objectForKey:kLocality])];
                [self setSublocality:NULL_TO_NIL([address objectForKey:kSubLocality])];
                [self setAdministrativearea:NULL_TO_NIL([address objectForKey:kAdministrativeArea])];
                [self setPostalcode:NULL_TO_NIL([address objectForKey:kPostalCode])];
                [self setIsocountrycode:NULL_TO_NIL([address objectForKey:kISOCountryCode])];
                [self setCountry:NULL_TO_NIL([address objectForKey:kCountry])];
                [self setAddressName:NULL_TO_NIL([address objectForKey:kAddressName])];
            
        }
        [self setLocationImageUrl:NULL_TO_NIL([attributes objectForKey:kFileURI])];
        _attachmentID = [NULL_TO_NIL([attributes valueForKey:kLocationAttachmentIdID]) longLongValue];
    }
    
    return self;
}

//- (id)initWithLocationAttachmentCoreData:(LocationAttachmentCoreData *)locationAttachmentCoreData
//{
//    if(self = [super init])
//    {
//        _attachmentID = locationAttachmentCoreData.attachmentID.longLongValue;
//        _locationImageUrl = locationAttachmentCoreData.thumbnailImageURI;
//        _coordinate = CLLocationCoordinate2DMake(locationAttachmentCoreData.latitude.doubleValue, locationAttachmentCoreData.longitude.doubleValue);
//        _throughfare = locationAttachmentCoreData.throughfare;
//        _subthroughfare = locationAttachmentCoreData.subthroughfare;
//        _locality = locationAttachmentCoreData.locality;
//        _sublocality = locationAttachmentCoreData.sublocality;
//        _administrativearea = locationAttachmentCoreData.administrativearea;
//        _subadministrativearea = locationAttachmentCoreData.subadministrativearea;
//        _region = locationAttachmentCoreData.region;
//        _postalcode = locationAttachmentCoreData.postalcode;
//        _isocountrycode = locationAttachmentCoreData.isocountrycode;
//        _country = locationAttachmentCoreData.country;
//    }
//    
//    return self;
//}

-(void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;
}

-(NSString*)locationImageName
{
    if (!_locationImageName) {
        _locationImageName = @"";
    }
    return _locationImageName;
}
-(void)setLocationImageName:(NSString *)locationImageName
{
    _locationImageName = locationImageName;
}


- (NSString *)addressDisplayTextLine1
{
    NSString *addressLine1 = @"";
    
    addressLine1 = [NSString stringWithFormat:@"%@%@",
                    [self subthroughfare]?[[self subthroughfare] stringByAppendingString:@" "] : @""
                    , [self throughfare]?[[self throughfare] stringByAppendingString:@","] : @"" ];
    if ([addressLine1 isEqualToString:@""]) {
        addressLine1 = [self addressName];
    }
    return addressLine1;
}

- (NSString *)addressDisplayTextLine2;
{
    NSString *addressLine2 = @"";
    addressLine2 = [NSString stringWithFormat:@"%@%@%@",
                    [self locality]? [[self locality] stringByAppendingString:@" "] : @"",
                    [self administrativearea]? [[self administrativearea] stringByAppendingString:@" "] : @"",
                    [self postalcode]? [[self postalcode] stringByAppendingString:@" "] : @""];
                    
                    
                    
//                    [self country]? [[self country] stringByAppendingString:@""] : @""  ]
//    ;
    return addressLine2;
}










@end
