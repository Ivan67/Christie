#import <BlocksKit/BlocksKit.h>
#import <MJNIndexView.h>
#import "CignaViewController.h"
#import "CignaSpecialitiesViewController.h"
#import "DoctorSpeciality.h"
#import "DoctorSpecialityCell.h"
#import "JSONReader.h"

static NSString *const Alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";

@interface CignaSpecialitiesViewController () <UITableViewDataSource, UITableViewDelegate, MJNIndexViewDataSource>

@property (nonatomic) NSArray<DoctorSpeciality *> *specialities;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MJNIndexView *indexView;

- (void)didTapSpecialityCellTitle:(UITapGestureRecognizer *)sender;

@end

@implementation CignaSpecialitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Specialities" image:@"menu_doctors"];
    
    self.specialities = [[JSONReader readJSONFromFile:[[NSBundle mainBundle] pathForResource:@"DoctorSpecialities" ofType:@"json"]] bk_map:^id(NSDictionary *specialityInfo) {
        return [[DoctorSpeciality alloc] initWithTitle:specialityInfo[@"title"] definition:specialityInfo[@"definition"]];
    }];

    [self.tableView registerNib:[UINib nibWithNibName:[DoctorSpecialityCell nibName] bundle:nil] forCellReuseIdentifier:[DoctorSpecialityCell reuseIdentifier]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.indexView.dataSource = self;
    self.indexView.getSelectedItemsAfterPanGestureIsFinished = YES;
    self.indexView.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
    self.indexView.selectedItemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40.0];
    self.indexView.curtainColor = nil;
    self.indexView.curtainFade = 5.0;
    self.indexView.curtainStays = NO;
    self.indexView.curtainMoves = YES;
    self.indexView.curtainMargins = NO;
    self.indexView.ergonomicHeight = NO;
    self.indexView.rightMargin = 0.0;
    self.indexView.itemsAligment = NSTextAlignmentCenter;
    self.indexView.maxItemDeflection = 50.0;
    self.indexView.rangeOfDeflection = 5;
    self.indexView.fontColor = [UIColor whiteColor];
    self.indexView.selectedItemFontColor = [UIColor colorWithRed: (240.0/255.0) green:(240.0/255.0) blue:(40.0/255.0) alpha:1];
    self.indexView.darkening = NO;
    self.indexView.fading = YES;
    
    [self refreshTable];
}

- (void)refreshTable {
    [self.tableView reloadData];
    [self.tableView reloadSectionIndexTitles];
    [self.indexView refreshIndexItems];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.specialities.count;
}

- (NSString *)firstLetter:(NSInteger)section {
    return [[Alphabet substringFromIndex:(NSUInteger)section] substringToIndex:1];
}

- (NSArray *)sectionIndexTitlesForMJNIndexView:(MJNIndexView *)indexView {
    NSMutableArray *titles = [NSMutableArray array];
    for (NSUInteger i = 0; i < Alphabet.length; i++) {
        [titles addObject:[Alphabet substringWithRange:NSMakeRange(i, 1)]];
    }
    return titles;
}

- (void)sectionForSectionMJNIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSUInteger cellIndex = [self.specialities indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DoctorSpeciality *speciality = (DoctorSpeciality *)obj;
        return [speciality.title hasPrefix:[self firstLetter:index]];
    }];
    if (cellIndex != NSNotFound) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:(NSInteger)cellIndex inSection:0] atScrollPosition: UITableViewScrollPositionTop animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DoctorSpecialityCell *cell = [tableView dequeueReusableCellWithIdentifier:[DoctorSpecialityCell reuseIdentifier]];

    DoctorSpeciality *speciality = (DoctorSpeciality *)self.specialities[(NSUInteger)indexPath.row];
    cell.titleLabel.text = speciality.title;
    cell.definitionLabel.text = speciality.definition;

    UITapGestureRecognizer *titleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSpecialityCellTitle:)];
    [cell.titleLabel addGestureRecognizer:titleTapRecognizer];

    CGSize boundingSize = CGSizeMake(cell.frame.size.width, CGFLOAT_MAX);
    CGSize oldTitleSize = cell.titleLabel.frame.size;
    CGRect titleFrame = cell.titleLabel.frame;
    titleFrame.size = [cell.titleLabel sizeThatFits:boundingSize];
    cell.titleLabel.frame = titleFrame;

    CGRect definitionFrame = cell.definitionLabel.frame;
    definitionFrame.origin.y += (titleFrame.size.height - oldTitleSize.height);
    definitionFrame.size = [cell.definitionLabel sizeThatFits:boundingSize];
    cell.definitionLabel.frame = definitionFrame;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static DoctorSpecialityCell *dummyCell;
    if (dummyCell == nil) {
        dummyCell = [[NSBundle mainBundle] loadNibNamed:[DoctorSpecialityCell nibName]  owner:nil options:nil][0];
    }
    
    DoctorSpeciality *speciality = self.specialities[(NSUInteger)indexPath.row];
    dummyCell.titleLabel.text = speciality.title;
    dummyCell.definitionLabel.text = speciality.definition;
    
    CGSize boundingSize = CGSizeMake(dummyCell.frame.size.width, CGFLOAT_MAX);
    CGFloat cellHeight = dummyCell.frame.size.height;
    cellHeight += [dummyCell.titleLabel sizeThatFits:boundingSize].height - dummyCell.titleLabel.frame.size.height;
    cellHeight += [dummyCell.definitionLabel sizeThatFits:boundingSize].height - dummyCell.definitionLabel.frame.size.height;
    return cellHeight;
}

- (void)didTapSpecialityCellTitle:(UITapGestureRecognizer *)sender {
    [self.navigationManager navigateTo:@"/doctors-cigna" withParameters:@{
        @"doctor": ((UILabel *)sender.view).text
    }];
}

@end
