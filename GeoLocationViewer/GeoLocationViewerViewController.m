//
//  GeoLocationViewerViewController.m
//  GeoLocationViewer
//
//  Created by Ken Zhou on 19/01/2014.
//  Copyright (c) 2014 Ken Zhou. All rights reserved.
//

#import "GeoLocationViewerViewController.h"

@interface GeoLocationViewerViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *findPin;
@property  (strong, nonatomic) MKPointAnnotation *pin;

@end

@implementation GeoLocationViewerViewController

- (MKPointAnnotation*)pin{
    if (!_pin) {
        _pin = [[MKPointAnnotation alloc] init];
    }
    return _pin;
}

- (GeolocationAttachment *)locationAttachment{
    if (!_locationAttachment) {
        NSDictionary *addressAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             @"THROUGH FARE", @"Throughfare",
                                             @"ADDRESS NAME", @"Name",
                                             @"ADMINISTRATIVE AREA", @"AdministrativeArea", nil];
        double latitue = -33.919361;
        double longitute = 151.227222;
        NSDictionary *locationAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                            addressAttributes, @"Address",
                                            [NSNumber numberWithDouble:latitue] , @"Latitude",
                                            [NSNumber numberWithDouble:longitute], @"Longitude",nil];
        
        _locationAttachment = [[GeolocationAttachment alloc] initWithAttributes:locationAttributes];
    }
    return _locationAttachment;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self loadPinFromLocationAttachment:self.locationAttachment];
    [self findPin:self.pin];
}

- (void) loadPinFromLocationAttachment: (GeolocationAttachment *) locationAttachment{
    MKPointAnnotation *pin = self.pin;
    pin.coordinate = locationAttachment.coordinate;
    
//    //save the address name to the location object
//    CLPlacemark *pm = (CLPlacemark *)selectedMapItem.placemark;
//    [self populateAttachmentModelWithPM:pm];
    
    NSString *address = [[self locationAttachment] addressDisplayTextLine1];
    [pin setTitle:address];
    
    
    NSString *address2 = [[self locationAttachment] addressDisplayTextLine2];
    [pin setSubtitle:address2];
    
}
- (void) findPin:(MKPointAnnotation *) pin{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:self.pin];
    [self.mapView selectAnnotation:self.pin animated:YES];
    
    MKCoordinateRegion selectedMapItemRegion;
    selectedMapItemRegion.center = pin.coordinate;
    selectedMapItemRegion.span.latitudeDelta = 0.001;
    selectedMapItemRegion.span.longitudeDelta = 0.0005;
    [self.mapView setRegion:selectedMapItemRegion animated:YES];

}

- (IBAction)findPinAction:(UIButton *)sender {
    [self findPin:self.pin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
