#import <CSLinearLayoutView.h>
#import <MapKit/MapKit.h>
#import <MKMapView+ZoomLevel.h>
#import "DataManager.h"
#import "OpenStatusBadge.h"
#import "PharmacyDetailsViewController.h"
#import "Pharmacy.h"
#import "PharmacyAnnotation.h"
#import "PickerViewController.h"
#import "UIView+LayoutHelpers.h"
#import "StreetViewController.h"

@interface PharmacyDetailsViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet CSLinearLayoutView *mainLayoutView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextView *headerTextView;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *pharmacyHoursView;
@property (weak, nonatomic) IBOutlet OpenStatusBadge *pharmacyOpenStatusBadge;
@property (weak, nonatomic) IBOutlet UILabel *pharmacyHoursLabel;
@property (weak, nonatomic) IBOutlet UIView *photoHoursView;
@property (weak, nonatomic) IBOutlet OpenStatusBadge *photoOpenStatuBadge;
@property (weak, nonatomic) IBOutlet UILabel *photoHoursLabel;
@property (weak, nonatomic) IBOutlet UIView *minuteClinicHoursView;
@property (weak, nonatomic) IBOutlet OpenStatusBadge *minuteClinicOpenStatusBadge;
@property (weak, nonatomic) IBOutlet UILabel *minuteClinicHoursLabel;
@property (weak, nonatomic) IBOutlet UIView *storeServicesView;
@property (weak, nonatomic) IBOutlet UILabel *storeServicesLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) CSLinearLayoutItem *headerLayoutItem;
@property (nonatomic) CSLinearLayoutItem *separatorLayoutItem;
@property (nonatomic) CSLinearLayoutItem *pharmacyHoursLayoutItem;
@property (nonatomic) CSLinearLayoutItem *photoHoursLayoutItem;
@property (nonatomic) CSLinearLayoutItem *minuteClinicHoursLayoutItem;
@property (nonatomic) CSLinearLayoutItem *storeServicesLayoutItem;
@property (nonatomic) CSLinearLayoutItem *mapLayoutItem;

@end

@implementation PharmacyDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainLayoutView.orientation = CSLinearLayoutViewOrientationVertical;
    self.headerLayoutItem = [self addLayoutItemForView:self.headerView];
    self.separatorLayoutItem = [self addLayoutItemForView:self.separatorView];
    self.pharmacyHoursLayoutItem = [self addLayoutItemForView:self.pharmacyHoursView];
    self.photoHoursLayoutItem = [self addLayoutItemForView:self.photoHoursView];
    self.minuteClinicHoursLayoutItem = [self addLayoutItemForView:self.minuteClinicHoursView];
    self.storeServicesLayoutItem = [self addLayoutItemForView:self.storeServicesView];
    self.mapLayoutItem = [self addLayoutItemForView:self.mapView];
}

- (void)openStreetView {
    StreetViewController *street = [[StreetViewController alloc] init];
    street.coordinate = self.pharmacy.location.coordinate;
    [self.navigationController pushViewController:street animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
    if (self.navigationParameters[@"pharmacy"] != nil) {
        self.pharmacy = self.navigationParameters[@"pharmacy"];
    }
    
    [self.mainLayoutView removeAllItems];
    
    [self updateHeader];
    [self updateOpenHours];
    [self updateOpenStatus];
    [self updateMap];
    
    [self.mainLayoutView setNeedsLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.mapView.frame = CGRectMake(self.mapView.frame.origin.x,
                                    self.mapView.frame.origin.y,
                                    self.mapView.frame.size.width,
                                    self.mapView.frame.size.width * 3./4);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.pharmacy.lastViewed = [NSDate date];
    [[DataManager sharedManager] saveChanges];
}

- (CSLinearLayoutItem *)addLayoutItemForView:(UIView *)view {
    static const CGFloat LayoutItemHorizontalPadding = 30;
    static const CGFloat LayoutItemVerticalPadding = 8;
    const CSLinearLayoutItemPadding LayoutItemPadding = CSLinearLayoutMakePadding(LayoutItemVerticalPadding, LayoutItemHorizontalPadding, LayoutItemVerticalPadding, LayoutItemHorizontalPadding);
    static const CSLinearLayoutItemFillMode LayoutItemFillMode = CSLinearLayoutItemFillModeStretch;
    
    CSLinearLayoutItem *layoutItem = [CSLinearLayoutItem layoutItemForView:view];
    layoutItem.padding = LayoutItemPadding;
    layoutItem.fillMode = LayoutItemFillMode;
    
    return layoutItem;
}

- (void)updateFavoriteButtonImage {
    NSString *imageName = [self.pharmacy.favorite boolValue] ? @"favorite_active" : @"favorite_inactive";
    [self.favoriteButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)changeHeightHeaderTextView {
    
    self.headerTextView.scrollEnabled = NO;
    [self.headerTextView sizeToFit];
    [self.headerTextView layoutIfNeeded];
    
    CGRect frame = self.headerTextView.frame;
    frame.size.height = self.headerTextView.contentSize.height;
    self.headerTextView.frame = frame;
}

- (void)updateHeader {
    UIFont *const TitleFont = [UIFont systemFontOfSize:15];
    UIFont *const NormalTextFont = [UIFont systemFontOfSize:12];
    
    self.headerTextView.linkTextAttributes = @{
        NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
    };
    
    NSMutableString *headerText = [NSMutableString stringWithFormat:@"%@\n%@\n%@", self.pharmacy.displayName, self.pharmacy.address,self.pharmacy.phone];
    NSMutableAttributedString *attributedHeaderText = [[NSMutableAttributedString alloc] initWithString:headerText];
    [attributedHeaderText addAttribute:NSFontAttributeName value:TitleFont range:NSMakeRange(0, self.pharmacy.displayName.length)];
    [attributedHeaderText addAttribute:NSFontAttributeName value:NormalTextFont range:NSMakeRange(self.pharmacy.displayName.length, self.pharmacy.address.length + self.pharmacy.phone.length + 2)];
    [attributedHeaderText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]  range:NSMakeRange(0, self.pharmacy.address.length + self.pharmacy.phone.length + self.pharmacy.displayName.length + 2)];
    self.headerTextView.attributedText = attributedHeaderText;
    [self.headerTextView sizeToFitSubviews];
    
    [self updateFavoriteButtonImage];
    [self.mainLayoutView addItem:self.headerLayoutItem];
    [self.mainLayoutView addItem:self.separatorLayoutItem];
    [self changeHeightHeaderTextView];
}

- (void)updateOpenHours {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    timeFormatter.dateFormat = @"h:mm a";
    
    if (self.pharmacy.pharmacyHours.length != 0) {
        if ([self.pharmacy isOpen24Hours]) {
            self.pharmacyHoursLabel.text = @"24/7";
        } else {
            self.pharmacyHoursLabel.text = [NSString stringWithFormat:@"M-F %@ - %@\nSat %@ - %@\nSun %@ - %@",
             [timeFormatter stringFromDate:self.pharmacy.pharmacyMFHoursOpen],
             [timeFormatter stringFromDate:self.pharmacy.pharmacyMFHoursClose],
             [timeFormatter stringFromDate:self.pharmacy.pharmacySatHoursOpen],
             [timeFormatter stringFromDate:self.pharmacy.pharmacySatHoursClose],
             [timeFormatter stringFromDate:self.pharmacy.pharmacySunHoursOpen],
             [timeFormatter stringFromDate:self.pharmacy.pharmacySunHoursClose]];
        }
        self.photoHoursView.hidden = NO;
        
        CGFloat fixedWidth = self.pharmacyHoursLabel.frame.size.width;
        CGSize newSize = [self.pharmacyHoursLabel sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = self.pharmacyHoursLabel.frame;
        newFrame.size = CGSizeMake(fmax(newSize.width, fixedWidth),newSize.height);
        self.pharmacyHoursLabel.frame = newFrame;
        
        [self.pharmacyHoursView sizeToFitSubviews];
        [self.mainLayoutView addItem:self.pharmacyHoursLayoutItem];
    } else {
        self.photoHoursView.hidden = YES;
        [self.mainLayoutView removeItem:self.pharmacyHoursLayoutItem];
    }
    
    if (self.pharmacy.photoHours.length != 0) {
        if ([self.pharmacy hasPhotoOpen24Hours]) {
            self.photoHoursLabel.text = @"24/7";
        } else {
            self.photoHoursLabel.text = [NSString stringWithFormat:@"M-F %@ - %@\nSat %@ - %@\nSun %@ - %@",
             [timeFormatter stringFromDate:self.pharmacy.photoMFHoursOpen],
             [timeFormatter stringFromDate:self.pharmacy.photoMFHoursClose],
             [timeFormatter stringFromDate:self.pharmacy.photoSatHoursOpen],
             [timeFormatter stringFromDate:self.pharmacy.photoSatHoursClose],
             [timeFormatter stringFromDate:self.pharmacy.photoSunHoursOpen],
             [timeFormatter stringFromDate:self.pharmacy.photoSunHoursClose]];
        }
        self.photoHoursView.hidden = NO;
        
        CGFloat fixedWidth = self.photoHoursLabel.frame.size.width;
        CGSize newSize = [self.photoHoursLabel sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = self.photoHoursLabel.frame;
        newFrame.size = CGSizeMake(fmax(newSize.width, fixedWidth),newSize.height);
        self.photoHoursLabel.frame = newFrame;
        
        [self.photoHoursView sizeToFitSubviews];
        [self.mainLayoutView addItem:self.photoHoursLayoutItem];
    } else {
        self.photoHoursView.hidden = YES;
        [self.mainLayoutView removeItem:self.photoHoursLayoutItem];
    }
    
    if (self.pharmacy.minuteClinicHours.length != 0) {
        if ([self.pharmacy hasMinuteClinicOpen24Hours]) {
            self.minuteClinicHoursLabel.text = @"24/7";
        } else {
            self.minuteClinicHoursLabel.text = [NSString stringWithFormat:@"M-F %@ - %@\nSat %@ - %@\nSun %@ - %@",
             [timeFormatter stringFromDate:self.pharmacy.minuteClinicMFHoursOpen],
             [timeFormatter stringFromDate:self.pharmacy.minuteClinicMFHoursClose],
             [timeFormatter stringFromDate:self.pharmacy.minuteClinicSatHoursOpen],
             [timeFormatter stringFromDate:self.pharmacy.minuteClinicSatHoursClose],
             [timeFormatter stringFromDate:self.pharmacy.minuteClinicSunHoursOpen],
             [timeFormatter stringFromDate:self.pharmacy.minuteClinicSunHoursClose]];
        }
        self.minuteClinicHoursView.hidden = NO;
        
        CGFloat fixedWidth = self.minuteClinicHoursLabel.frame.size.width;
        CGSize newSize = [self.minuteClinicHoursLabel sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = self.minuteClinicHoursLabel.frame;
        newFrame.size = CGSizeMake(fmax(newSize.width, fixedWidth),newSize.height);
        self.minuteClinicHoursLabel.frame = newFrame;
        
        [self.minuteClinicHoursView sizeToFitSubviews];
        [self.mainLayoutView addItem:self.minuteClinicHoursLayoutItem];
    } else {
        self.minuteClinicHoursView.hidden = YES;
        [self.mainLayoutView removeItem:self.minuteClinicHoursLayoutItem];
    }
    
    if (self.pharmacy.service.length != 0) {
        self.storeServicesLabel.text = [self.pharmacy.service stringByReplacingOccurrencesOfString:@", " withString:@"\n"];
        self.storeServicesView.hidden = NO;
        [self.storeServicesLabel sizeToFit];
        [self.storeServicesView sizeToFitSubviews];
        [self.mainLayoutView addItem:self.storeServicesLayoutItem];
    } else {
        self.storeServicesView.hidden = YES;
        [self.mainLayoutView removeItem:self.storeServicesLayoutItem];
    }
}

- (void)updateOpenStatus {
    NSDate *currentDate = [NSDate date];
    self.pharmacyOpenStatusBadge.open = [self.pharmacy isOpenAt:currentDate];
    self.photoOpenStatuBadge.open = [self.pharmacy isOpenAt:currentDate];
    self.minuteClinicOpenStatusBadge.open = [self.pharmacy isOpenAt:currentDate];
}

- (void)updateMap {
    [self.mapView setCenterCoordinate:self.pharmacy.location.coordinate zoomLevel:15 animated:YES];
    
    PharmacyAnnotation *annotation = [[PharmacyAnnotation alloc] initWithPharmacy:self.pharmacy];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    
    [self.mainLayoutView addItem:self.mapLayoutItem];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [self.mapView selectAnnotation:view.annotation animated:YES];
}

- (IBAction)toggleFavoriteStatus {
    self.pharmacy.favorite = @(![self.pharmacy.favorite boolValue]);
    [[DataManager sharedManager] saveChanges];
    [self updateFavoriteButtonImage];
}

- (IBAction)showMapsAppPickerView {
    PickerViewController *pickerViewController = [[PickerViewController alloc] init];
    if ([self canOpenGoogleMaps]) {
        [pickerViewController addAction:[PickerAction actionWithTitle:@"Open in Google Maps" handler:^{
            [self openGoogleMaps];
        }]];
    }
    if ([self canOpenAppleMaps]) {
        [pickerViewController addAction:[PickerAction actionWithTitle:@"Open in Maps" handler:^{
            [self openAppleMaps];
        }]];
    }
        [pickerViewController addAction:[PickerAction actionWithTitle:@"Open Street View" handler:^{
            [self openStreetView];
        }]];
    [self presentViewController:pickerViewController animated:YES completion:nil];
}

- (BOOL)canOpenAppleMaps {
    Class mapItemClass = [MKMapItem class];
    return mapItemClass != nil && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)];
}

- (void)openAppleMaps {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.pharmacy.location.coordinate addressDictionary:nil];
    MKMapItem *pharmacyMapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    pharmacyMapItem.name = self.pharmacy.address;
    
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, pharmacyMapItem] launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving}];
}

- (BOOL)canOpenGoogleMaps {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];
}

- (void)openGoogleMaps {
    NSString *coordinates = [NSString stringWithFormat:@"%@,%@", self.pharmacy.latitude, self.pharmacy.longitude];
    NSString *coordinatesEncoded = [coordinates stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *URL = [NSString stringWithFormat: @"comgooglemaps://?daddr=%@", coordinatesEncoded];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
    
}

@end