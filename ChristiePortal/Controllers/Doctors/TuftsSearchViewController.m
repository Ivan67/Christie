#import <BlocksKit/BlocksKit.h>
#import "APIClient.h"
#import "Doctor.h"
#import "DoctorCell.h"
#import "DoctorSpeciality.h"
#import "DoctorsDropdownCell.h"
#import "JSONReader.h"
#import "LocationMonitor.h"
#import "TuftsSearchViewController.h"

@interface TuftsSearchViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *doctorsTableView;
@property (weak, nonatomic) IBOutlet UITableView *searchSuggestionsTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@property (nonatomic) NSArray<DoctorSpeciality *> *doctorSpecialities;
@property (nonatomic) NSArray<Doctor *> *doctors;
@property (nonatomic) NSArray<NSString *> *searchSuggestions;

@property (nonatomic) CGFloat suggestionsDropdownCellHeight;

@end

@implementation TuftsSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Doctors" image:@"menu_doctors"];
    
    UIButton *cignaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat cignaButtonHeight = self.navigationController.navigationBar.frame.size.height * 0.6;
    CGFloat cignaButtonWidth = self.navigationController.navigationBar.frame.size.height + cignaButtonHeight/2;
    cignaButton.frame = CGRectMake(0, 0, cignaButtonWidth, cignaButtonHeight);
    cignaButton.adjustsImageWhenHighlighted = NO;
    [cignaButton setTitle:@"Cigna" forState:UIControlStateNormal];
    cignaButton.layer.cornerRadius = 3;
    cignaButton.layer.borderWidth = 1;
    cignaButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [cignaButton addTarget:self action:@selector(showCignaView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cignaButton];

    [self.doctorsTableView registerNib:[UINib nibWithNibName:[DoctorCell nibName] bundle:nil] forCellReuseIdentifier:[DoctorCell reuseIdentifier]];
    [self.searchSuggestionsTableView registerNib:[UINib nibWithNibName:[DoctorsDropdownCell nibName] bundle:nil] forCellReuseIdentifier:[DoctorsDropdownCell reuseIdentifier]];

    self.searchField.text = nil;
    [self.searchField addTarget:self action:@selector(searchFieldDidChange) forControlEvents:UIControlEventEditingChanged];

    NSArray *dropdownNib = [[NSBundle mainBundle] loadNibNamed:[DoctorsDropdownCell nibName] owner:self options:nil];
    self.suggestionsDropdownCellHeight = [[dropdownNib objectAtIndex:0] bounds].size.height;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkInternetAccess];
    self.doctors = [[APIClient sharedClient] fetchDoctors];
    self.doctorSpecialities = [[JSONReader readJSONFromFile:[[NSBundle mainBundle] pathForResource:@"DoctorSpecialities" ofType:@"json"]] bk_map:^id(NSDictionary *specialityInfo) {
        return [[DoctorSpeciality alloc] initWithTitle:specialityInfo[@"title"] definition:specialityInfo[@"definition"]];
    }];
}

- (void)showCignaView {
    [self.navigationManager navigateTo:@"/doctors-cigna"];
}

- (void)loadSearchSuggestionsForTerm:(NSString *)term {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", term];
    self.searchSuggestions = [[self.doctorSpecialities filteredArrayUsingPredicate:predicate] bk_map:^id(DoctorSpeciality *speciality) {
        return speciality.title;
    }];
    [self.searchSuggestionsTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.doctorsTableView) {
        return (NSInteger)self.doctors.count;
    }
    if (tableView == self.searchSuggestionsTableView) {
        return (NSInteger)self.searchSuggestions.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.doctorsTableView) {
        DoctorCell *cell = [tableView dequeueReusableCellWithIdentifier:[DoctorCell reuseIdentifier]];
        Doctor *doctor = self.doctors[(NSUInteger)indexPath.row];
        cell.nameLabel.text = doctor.name;
        cell.addressLabel.text = doctor.address;
        return cell;
    }
    if (tableView == self.searchSuggestionsTableView) {
        DoctorsDropdownCell *cell = [tableView dequeueReusableCellWithIdentifier:[DoctorsDropdownCell reuseIdentifier]];
        cell.dropdownTextLabel.text = self.searchSuggestions[(NSUInteger)indexPath.row];
        return cell;
    }
    return nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self updateSuggestionsDropdownHeight];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.searchField) {
        [self updateSuggestionsDropdownHeight:0];
    }
}

- (void)searchFieldDidChange {
    if (self.searchField.text.length == 0) {
        [self animateSuggestionsDropdown:0];
    }
    [self loadSearchSuggestionsForTerm:self.searchField.text];
    [self updateSuggestionsDropdownHeight];
}

- (void)updateSuggestionsDropdownHeight {
    CGFloat height = MIN(self.searchSuggestions.count, 5u) * self.suggestionsDropdownCellHeight;
    [self animateSuggestionsDropdown:height];
}

- (void)updateSuggestionsDropdownHeight:(CGFloat)height {
    [self animateSuggestionsDropdown:height];
}

- (void)animateSuggestionsDropdown:(CGFloat)height {
    [UIView animateWithDuration:0.1 animations:^{
        CGRect frame = self.searchSuggestionsTableView.frame;
        frame.size.height = height;
        self.searchSuggestionsTableView.frame = frame;
    }];
}

@end
