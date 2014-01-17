//
//  CanaryViewController.m
//  GeolocationAttachment
//

//  This view controller is made to perform the Geo-location attachment function
//  inside a new Vox.
//

//  Created by Ken Zhou on 28/11/2013.
//  Copyright (c) 2013 Ken Zhou. All rights reserved.
//

#import "CanaryGeolocationAttachmentViewController.h"
#import "MapKit/MapKit.h"
#import "DraftNewVoxViewController.h"
#import "Utils.h"
#import "MacroHeader.h"

#import "NSObject+logProperties.h"

@interface CanaryGeolocationAttachmentViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) UIButton *userHeadingBtn;


@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D userLocation;

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIToolbar *bottomToolBar;


@property  (nonatomic, strong) NSString *searchString;

@end



@implementation CanaryGeolocationAttachmentViewController
@synthesize userHeadingBtn;
//getter setter
@synthesize geolocationAttachment = _geolocationAttachment;
-(GeolocationAttachment *)geolocationAttachment
{
    if(!_geolocationAttachment)
    {
        _geolocationAttachment = [[GeolocationAttachment alloc] init];
    }
    return _geolocationAttachment;
}
-(void)setGeolocationAttachment:(GeolocationAttachment *)geolocationAttachment
{
    _geolocationAttachment = geolocationAttachment;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
   
    [[[self navigationController] navigationBar] setTitleTextAttributes:FNT_ATTR_navBarTitle];
    
    
    //instantiate a mapview here and add it to the first cell of the tableView
    //Todo
    //changing the height based on different screen size
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 376)];
    self.mapView = mapView;
    [self.mapView setShowsUserLocation:YES];
	self.mapView.delegate = self;

  
    //Adding the findMe button
    //User Heading Button states images
    UIImage *buttonImage = [UIImage imageNamed:@"greyButtonHighlight.png"];
    UIImage *buttonImageHighlight = [UIImage imageNamed:@"greyButton.png"];
    UIImage *buttonArrow = [UIImage imageNamed:@"LocationGrey.png"];
    
    //Configure the button
    userHeadingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [userHeadingBtn addTarget:self action:@selector(startShowingUserHeading:) forControlEvents:UIControlEventTouchUpInside];
    //Add state images
    [userHeadingBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [userHeadingBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [userHeadingBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [userHeadingBtn setImage:buttonArrow forState:UIControlStateNormal];
    
    //Position and Shadow
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    userHeadingBtn.frame = CGRectMake(5,screenBounds.size.height-145,39,30);
    userHeadingBtn.frame = CGRectMake(5,320,39,30);
    userHeadingBtn.layer.cornerRadius = 8.0f;
    userHeadingBtn.layer.masksToBounds = NO;
    userHeadingBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    userHeadingBtn.layer.shadowOpacity = 0.8;
    userHeadingBtn.layer.shadowRadius = 1;
    userHeadingBtn.layer.shadowOffset = CGSizeMake(0, 1.0f);
    
    [self.mapView addSubview:userHeadingBtn];

    // start by locating user's current position
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	[self.locationManager startUpdatingLocation];
    
    //search bar placeholder
    [[self searchBar] setPlaceholder:NSLocalizedString(kSearchForLocation, nil)];
    
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Tablc view data source and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if(  [tableView isMemberOfClass:[UITableView class]])
  {
      return 1;
  }
  else
  {
	return [self.places count];
  }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellID = @"CellIdentifier";
    static NSString *kMapViewCellId = @"MapViewCell";
    if ([tableView isMemberOfClass:[UITableView class]]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMapViewCellId];
        [cell.contentView addSubview:self.mapView];
        NSLog(@"%f, %f", self.mapView.center.x, self.mapView.center.y);
        UIImageView *centerPinView = [[UIImageView alloc] initWithFrame:CGRectMake(self.mapView.center.x - 17, self.mapView.center.y - 35, 35, 35)];
        UIImage *pinImage = [UIImage imageNamed:@"GreenPin.png"];
        [centerPinView setImage:pinImage];
        [cell.contentView addSubview:centerPinView];
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:kCellID];
        }
        
        MKMapItem *mapItem = [self.places objectAtIndex:indexPath.row];
        [cell.textLabel setText:mapItem.name];
        NSString *address2 = [NSString stringWithFormat:@"%@%@%@",
                              mapItem.placemark.thoroughfare? [mapItem.placemark.thoroughfare stringByAppendingString:@", "]: @"",
                              mapItem.placemark.locality? [mapItem.placemark.locality stringByAppendingString:@", "] : @"",
                              mapItem.placemark.administrativeArea? mapItem.placemark.administrativeArea : @""];
        [cell.detailTextLabel setText:address2];
        
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    // pass the individual place to our map destination view controller
    NSIndexPath *selectedItem = indexPath;
    MKMapItem *selectedMapItem = [self.places objectAtIndex:selectedItem.row];
    
    
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    [point setCoordinate:selectedMapItem.placemark.location.coordinate];
    
    //save the address name to the location object
    CLPlacemark *pm = (CLPlacemark *)selectedMapItem.placemark;
    [self populateAttachmentModelWithPM:pm];
    
    NSString *address = [[self geolocationAttachment] addressDisplayTextLine1];
    [point setTitle:address];
    
    
    NSString *address2 = [[self geolocationAttachment] addressDisplayTextLine2];
    
//    [NSString stringWithFormat:@"%@%@%@",
//                          selectedMapItem.placemark.thoroughfare?  [selectedMapItem.placemark.thoroughfare  stringByAppendingString:@", "]: @"",
//                          selectedMapItem.placemark.locality? [selectedMapItem.placemark.locality stringByAppendingString:@", "] : @"",
//                          selectedMapItem.placemark.administrativeArea? selectedMapItem.placemark.administrativeArea : @""];
    [point setSubtitle:address2];
    


    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:point];
    [self.mapView selectAnnotation:point animated:YES];
    
    MKCoordinateRegion selectedMapItemRegion;
    selectedMapItemRegion.center = selectedMapItem.placemark.location.coordinate;
    selectedMapItemRegion.span.latitudeDelta = 0.001;
    selectedMapItemRegion.span.longitudeDelta = 0.0005;
    [self.mapView setRegion:selectedMapItemRegion animated:YES];

    
    [self.searchBar resignFirstResponder];
//    NSLog(@"searchString: %@", self.searchBar.text);
//    NSLog(@"searchString from display controller:%@", self.searchDisplayController.searchBar.text);
    NSString *str = self.searchDisplayController.searchBar.text;
    self.searchString = str;
    [self.searchDisplayController setActive:YES animated:YES];
    [self.searchDisplayController setActive:NO animated:YES];
    [self.searchDisplayController.searchBar setText:str];
    

}




#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar bringSubviewToFront:self.searchDisplayController.searchResultsTableView];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - UISearchDisplayControllerDelegate
- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    [self.searchDisplayController.searchResultsTableView reloadData];
    [controller.searchBar setShowsCancelButton:YES animated:YES];
    [self.searchDisplayController.searchBar setText:self.searchString];
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    //If this function is re-called before 1 sec delay then DONT make a WS call for search
    [NSRunLoop cancelPreviousPerformRequestsWithTarget:self];
    
    //Execute search if the string length is min 2 chars
    if([searchString length] > 1)
    {
        //Copy the search string to Model class
        
        //Make the search WS call after 1 sec delay
        [self startSearch:self.searchBar.text searchButtonClicked:NO];
    }
    
    return NO;
}


- (void)startSearch:(NSString *)searchString searchButtonClicked:(BOOL)searchBottonClicked
{
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
    // confine the map search area to the user's current location
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = self.userLocation.latitude;
    newRegion.center.longitude = self.userLocation.longitude;
    
    // setup the area spanned by the map region:
    // we use the delta values to indicate the desired zoom level of the map,
    //      (smaller delta values corresponding to a higher zoom level)
    //
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;

    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchString;
    request.region = newRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error)
    {
        if (error != nil && searchBottonClicked)
        {
            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            self.places = [response mapItems];
            NSLog(@"%@", [response mapItems]);
            // used for later when setting the map's region in "prepareForSegue"
            self.boundingRegion = response.boundingRegion;
//            [self.searchDisplayController searchResultsDelegate]
            
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (self.localSearch != nil)
    {
        self.localSearch = nil;
    }
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [self.localSearch startWithCompletionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    // check to see if Location Services is enabled, there are two state possibilities:
    // 1) disabled for entire device, 2) disabled just for this app
    //
    NSString *causeStr = nil;
    
    // check whether location services are enabled on the device
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        causeStr = @"device";
    }
    // check the application’s explicit authorization status:
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        causeStr = @"app";
    }
    else
    {
        // we are good to go, start the search
        [self startSearch:searchBar.text searchButtonClicked:YES];
    }
    
    if (causeStr != nil)
    {
        NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];
        
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                        message:alertMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}



#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSDate* time = newLocation.timestamp;
    NSTimeInterval timePeriod = [time timeIntervalSinceNow];
    if (timePeriod < 2.0){
        // remember for later the user's current location
        
        NSLog(@"%@", [self.mapView showsUserLocation]?@"YES":@"NO");
        self.userLocation = [self.mapView userLocation].location.coordinate;
        if (self.userLocation.latitude != 0 && self.userLocation.longitude !=0) {            
            [self.mapView setCenterCoordinate:self.userLocation animated:YES];
            NSLog(@"%f, %f", [self.mapView userLocation].location.coordinate.latitude, [self.mapView userLocation].location.coordinate.longitude);
            MKCoordinateRegion myRegion;
            myRegion.center = self.userLocation;
            myRegion.span.latitudeDelta = 0.002;
            myRegion.span.longitudeDelta = 0.0010;
            [self.mapView setRegion:myRegion animated:YES];
     
            
            [manager stopUpdatingLocation]; // we only want one update
            NSLog(@"%f, %f", [self.mapView userLocation].location.coordinate.latitude, [self.mapView userLocation].location.coordinate.longitude);
            manager.delegate = nil;         // we might be called again here, even though we
            // called "stopUpdatingLocation", remove us as the delegate to be sure
        }
    }
    else{
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // report any errors returned back from Location Services
}

#pragma mark - MKMapViewDelegate

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLGeocoder* geoCoder = [[CLGeocoder alloc]init];
    CLLocation *regionCenterLocation = [[CLLocation alloc] initWithLatitude:self.mapView.region.center.latitude longitude:self.mapView.region.center.longitude];
    
    [geoCoder reverseGeocodeLocation:regionCenterLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       CLPlacemark* pm = [placemarks objectAtIndex:0];
                       
//                       [pm logProperties];
                       
                       //save the address name to the location object
                       [self populateAttachmentModelWithPM:pm];
                       
                       NSString *address = [[self geolocationAttachment] addressDisplayTextLine1];
                       NSString *address2 = [[self geolocationAttachment] addressDisplayTextLine2];
                       
                       MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                       [point setCoordinate:self.mapView.region.center];
                       [point setTitle:address];
                       
                       [point setSubtitle:address2];
                       
                       [self.mapView removeAnnotations:self.mapView.annotations];
                       [self.mapView addAnnotation:point];
                       [self.mapView selectAnnotation:point animated:YES];
                       
                   
                       
                       
                   }];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKPinAnnotationView *annotationView = nil;
	if ([annotation isKindOfClass:[MKPointAnnotation class]])
	{
		annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
		if (annotationView == nil)
		{
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
			[annotationView setImage:nil];
            
            annotationView.canShowCallout = YES;
            annotationView.opaque = NO;

    
            
		}
	}
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    [annotationView setImage:nil];

	return annotationView;
}




- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated{
    if(self.mapView.userTrackingMode == 0){
        [self.mapView setUserTrackingMode: MKUserTrackingModeNone animated: YES];
        
        //Put it back again
        UIImage *buttonArrow = [UIImage imageNamed:@"LocationGrey.png"];
        [userHeadingBtn setImage:buttonArrow forState:UIControlStateNormal];
    }
    
}

#pragma mark - User Heading

- (void) startShowingUserHeading:(id)sender{
    
    if(self.mapView.userTrackingMode == 0){
        [self.mapView setUserTrackingMode: MKUserTrackingModeFollow animated: YES];
        
        //Turn on the position arrow
        UIImage *buttonArrow = [UIImage imageNamed:@"LocationBlue.png"];
        [userHeadingBtn setImage:buttonArrow forState:UIControlStateNormal];
        
    }
    else if(self.mapView.userTrackingMode == 1){
        [self.mapView setUserTrackingMode: MKUserTrackingModeFollowWithHeading animated: YES];
        
        //Change it to heading angle
        UIImage *buttonArrow = [UIImage imageNamed:@"LocationHeadingBlue"];
        [userHeadingBtn setImage:buttonArrow forState:UIControlStateNormal];
    }
    else if(self.mapView.userTrackingMode == 2){
        [self.mapView setUserTrackingMode: MKUserTrackingModeNone animated: YES];
        
        //Put it back again
        UIImage *buttonArrow = [UIImage imageNamed:@"LocationGrey.png"];
        [userHeadingBtn setImage:buttonArrow forState:UIControlStateNormal];
    }
    
}

#pragma mark - Save location object
int temPuserId = 2;
int tempEntityId = 15;
- (IBAction)setLocation:(UIBarButtonItem *)sender {
    //1. Save coordinate
    [self.geolocationAttachment setCoordinate:self.mapView.centerCoordinate];
    //2. Save addressName
    
    //3. Taking an image and store it locally and saving the fileName    
    UIImage *mapSnapshot = [self saveMapSnapshot];
    UIImage *processedImage = [self resizeToFit:mapSnapshot];
    [self saveImageToLocalFolder:processedImage];
    
    DraftNewVoxViewController *newDrafViewController = (DraftNewVoxViewController *) [self backViewController];
    
    if ([newDrafViewController isKindOfClass:[DraftNewVoxViewController class]]) {
        newDrafViewController.voxDraft.locationAttachment = self.geolocationAttachment;
    }
    
    
    
    [self.navigationController popViewControllerAnimated:YES];
    //the NewVox controller
    
}

#pragma mark - snapshot taking
-(UIImage *)saveMapSnapshot
{
    __block UIImage * finalImage = nil;
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = self.mapView.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = self.mapView.frame.size;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    StartBlock();
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        
        // get the image associated with the snapshot
        
        UIImage *image = snapshot.image;
        
        // Get the size of the final image
        
        CGRect finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        // Get a standard annotation view pin. Clearly, Apple assumes that we'll only want to draw standard annotation pins!
        
        MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
        UIImage *pinImage = pin.image;
        
        
        
        // ok, let's start to create our final image
        
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        
        // first, draw the image from the snapshotter
        
        [image drawAtPoint:CGPointMake(0, 0)];
        
        // now, let's iterate through the annotations and draw them, too
        if ([self.mapView.annotations count] > 1){
            
            
            for (id<MKAnnotation>annotation in self.mapView.annotations)
            {
                if ([annotation isKindOfClass:[MKUserLocation class]]) {
                    continue;
                }
                CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
                if (CGRectContainsPoint(finalImageRect, point)) // this is too conservative, but you get the idea
                {
                    CGPoint pinCenterOffset = pin.centerOffset;
                    point.x -= pin.bounds.size.width / 2.0;
                    point.y -= pin.bounds.size.height / 2.0;
                    point.x += pinCenterOffset.x;
                    point.y += pinCenterOffset.y;
                    
                    [pinImage drawAtPoint:point];
                }
            }
        }
        else{
            for (id<MKAnnotation>annotation in self.mapView.annotations)
            {
                if ([annotation isKindOfClass:[MKUserLocation class]]) {
                    continue;
                }
                CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
                if (CGRectContainsPoint(finalImageRect, point)) // this is too conservative, but you get the idea
                {
                    CGPoint pinCenterOffset = pin.centerOffset;
                    point.x -= pin.bounds.size.width / 2.0;
                    point.y -= pin.bounds.size.height / 2.0;
                    point.x += pinCenterOffset.x;
                    point.y += pinCenterOffset.y;
                    
                    [pinImage drawAtPoint:point];
                }
            }
        }
        
        
        
        // grab the final image
        finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
    return finalImage;
}

-(UIImage *)resizeToFit:(UIImage*)originSnapshotImage
{
    UIImage * processedImage = nil;
    //TODO find a right size to cropping the image to
    CGImageRef imageRef = CGImageCreateWithImageInRect(originSnapshotImage.CGImage, CGRectMake(0, 250.66, 640, 250.66));
    processedImage = [UIImage imageWithCGImage:imageRef];
    return processedImage;
}

-(void)saveImageToLocalFolder:(UIImage*)image
{
    /*Create the Images folder under the documents directory*/
    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [Utils createDirectory:kImageDir atFilePath:applicationDocumentsDir];
//    NSString *imageName = [NSString stringWithFormat:@"%d_%d_%@.png", temPuserId, tempEntityId, [NSString stringWithFormat:@"locationSnapshot"]];
    
    NSString *imageName = [NSString stringWithFormat:@"%@.png", [Utils getUUID]];
    
    NSString *imageDir = [NSString stringWithFormat:@"%@%@%@", applicationDocumentsDir,kImageDir,imageName];
    [[self geolocationAttachment] setLocationImageName:imageDir];
    [UIImagePNGRepresentation(image) writeToFile:imageDir atomically:NO];
    
}


#pragma mark - uitils
- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

- (void)populateAttachmentModelWithPM:(CLPlacemark *)pm
{
    [self.geolocationAttachment setThroughfare:[pm thoroughfare]];
    [self.geolocationAttachment setSubthroughfare:[pm subThoroughfare]];
    [self.geolocationAttachment setLocality:[pm locality]];
    [self.geolocationAttachment setSublocality:[pm subLocality]];
    [self.geolocationAttachment setAdministrativearea:[pm administrativeArea]];
    [self.geolocationAttachment setSubadministrativearea:[pm subAdministrativeArea]];
    
//    [self.geolocationAttachment setRegion:[pm region]];//KZ pm region is a clregion
    
    [self.geolocationAttachment setPostalcode:[pm postalCode]];
    [self.geolocationAttachment setIsocountrycode:[pm ISOcountryCode]];
    [self.geolocationAttachment setCountry:[pm country]];
    
    [self.geolocationAttachment setAddressName:[pm name]];
}

#pragma mark - Cancel Action

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end


