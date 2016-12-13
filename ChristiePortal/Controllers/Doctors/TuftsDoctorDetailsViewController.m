//
//  TuftsDoctorDetailsViewController.m
//  ChristiePortal
//
//  Created by Sergey on 11/01/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

#import "Doctor.h"
#import "TuftsDoctorDetailsViewController.h"

@interface TuftsDoctorDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *specialityLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (nonatomic) Doctor *doctor;

@end

@implementation TuftsDoctorDetailsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.doctor = self.navigationParameters[@"doctor"];
    
    self.nameLabel.text = self.doctor.name;
    self.specialityLabel.text = self.doctor.type;
    self.addressLabel.text = self.doctor.address;
}

@end
