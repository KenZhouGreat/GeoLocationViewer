

//
//  CanaryViewController.h
//  GeolocationAttachment
//    
//  This view controller is made to perform the Geo-location attachment function
//  inside a new Vox.
//
//  Created by Ken Zhou on 28/11/2013.
//  Copyright (c) 2013 Ken Zhou. All rights reserved.
//


#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
#import "GeolocationAttachment.h"

@interface CanaryGeolocationAttachmentViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

//Array to store the search result
@property (nonatomic, strong) NSArray *places;
//Selected geolocation
@property (nonatomic, strong) GeolocationAttachment *geolocationAttachment;


@end
