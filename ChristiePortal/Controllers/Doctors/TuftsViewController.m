//
//  TuftsViewController.m
//  ChristiePortal
//
//  Created by Sergey on 11/01/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

#import "APIClient.h"
#import "Doctor.H"
#import "TuftsViewController.h"

@interface TuftsViewController ()

@property (weak, nonatomic) IBOutlet UIView *favoriteDoctorButton;
@property (weak, nonatomic) IBOutlet UILabel *favoriteDoctorName;
@property (weak, nonatomic) IBOutlet UILabel *favoriteDoctorAddress;
@property (weak, nonatomic) IBOutlet UILabel *noFavoriteDoctorLabel;

@property (weak, nonatomic) IBOutlet UIView *recentDoctor1Button;
@property (weak, nonatomic) IBOutlet UILabel *recentDoctor1Name;
@property (weak, nonatomic) IBOutlet UILabel *recentDoctor1Address;
@property (weak, nonatomic) IBOutlet UIView *recentDoctor2Button;
@property (weak, nonatomic) IBOutlet UILabel *recentDoctor2Name;
@property (weak, nonatomic) IBOutlet UILabel *recentDoctor2Address;
@property (weak, nonatomic) IBOutlet UILabel *noRecentDoctorsLabel;

@property (nonatomic) Doctor *favoriteDoctor;
@property (nonatomic) Doctor *recentDoctor1;
@property (nonatomic) Doctor *recentDoctor2;

- (IBAction)showSearchView;
- (IBAction)handleTapGesture:(UIGestureRecognizer *)sender;

@end

@implementation TuftsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Doctors" image:@"menu_doctors"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkInternetAccess];
    [self.activityIndicator startAnimating];
    
    NSArray<Doctor *> *doctors = [[APIClient sharedClient] fetchDoctors];
    self.favoriteDoctor = [doctors firstObject];
//    NSArray *favoriteDoctors = [doctors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"favorite == 1"]];
//    self.favoriteDoctor = [favoriteDoctors firstObject];
    
    if (self.favoriteDoctor == nil) {
        self.favoriteDoctorButton.hidden = YES;
        self.noFavoriteDoctorLabel.hidden = NO;
    } else {
        self.favoriteDoctorButton.hidden = NO;
        self.favoriteDoctorName.text = self.favoriteDoctor.name;
        self.favoriteDoctorAddress.text = self.favoriteDoctor.address;
        self.noFavoriteDoctorLabel.hidden = YES;
    }

    NSArray<Doctor *> *recentDoctors = doctors;
//    NSArray<Doctor *> *everViewedDoctors = [doctors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastViewed != nil"]];
//    NSArray<Doctor *> *recentDoctors = [everViewedDoctors sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastViewed" ascending:NO]]];
    
    if (recentDoctors.count == 0) {
        self.recentDoctor1Button.hidden = YES;
        self.recentDoctor2Button.hidden = YES;
        self.noRecentDoctorsLabel.hidden = NO;
    } else {
        self.noRecentDoctorsLabel.hidden = YES;
        
        self.recentDoctor1Button.hidden = NO;
        self.recentDoctor1 = recentDoctors[0];
        self.recentDoctor1Name.text = self.recentDoctor1.name;
        self.recentDoctor1Address.text = self.recentDoctor1.address;
        
        if (recentDoctors.count >= 2) {
            self.recentDoctor2Button.hidden = NO;
            self.recentDoctor2 = recentDoctors[1];
            self.recentDoctor2Name.text = self.recentDoctor2.name;
            self.recentDoctor2Address.text = self.recentDoctor2.address;
        } else {
            self.recentDoctor2Button.hidden = YES;
        }
    }
    
    [self.activityIndicator stopAnimating];
}

- (IBAction)showSearchView {
    [self.navigationManager navigateTo:@"/doctors-tufts/search"];
}

- (IBAction)handleTapGesture:(UIGestureRecognizer *)sender {
    Doctor *doctor;
    if (sender.view == self.favoriteDoctorButton) {
        doctor = self.favoriteDoctor;
    } else if (sender.view == self.recentDoctor1Button) {
        doctor = self.recentDoctor1;
    } else if (sender.view == self.recentDoctor2Button) {
        doctor = self.recentDoctor2;
    }
    if (doctor != nil) {
        [self.navigationManager navigateTo:@"/doctors-tufts/details" withParameters:@{
            @"doctor": doctor
        }];
    }
}

@end
