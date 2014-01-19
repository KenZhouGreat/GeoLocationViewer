//
//  GeoLocationViewerViewController.h
//  GeoLocationViewer
//
//  Created by Ken Zhou on 19/01/2014.
//  Copyright (c) 2014 Ken Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeolocationAttachment.h"
#import "MapKit/MapKit.h"

@interface GeoLocationViewerViewController : UIViewController

- (void) loadPinFromLocationAttachment: (GeolocationAttachment *) locationAttachment;
- (void) findPin:(MKPointAnnotation *) pin;

@property (nonatomic, strong) GeolocationAttachment *locationAttachment;


@end
