#import <AFNetworkActivityIndicatorManager.h>
#import <AFNetworkActivityLogger.h>
#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>
#import <FMDB.h>
#import <MessageUI/MessageUI.h>
#import <SWRevealViewController.h>
#import "AccountViewController.h"
#import "AppDelegate.h"
#import "AuthenticationManager.h"
#import "CignaSearchViewController.h"
#import "CignaViewController.h"
#import "ClaimsViewController.h"
#import "CVSDatabaseImporter.h"
#import "CVSDatabaseReader.h"
#import "DataManager.h"
#import "DentalViewController.h"
#import "CignaSpecialitiesViewController.h"
#import "Environment.h"
#import "EuropAssistViewController.h"
#import "HealthPlanDetector.h"
#import "LegalDocumentsViewController.h"
#import "LoadingViewController.h"
#import "LoginViewController.h"
#import "LocationMonitor.h"
#import "MenuViewController.h"
#import "MyChristieViewController.h"
#import "NavigationController.h"
#import "NearbyPharmacyMonitor.h"
#import "NotificationManager.h"
#import "PharmaciesViewController.h"
#import "Pharmacy.h"
#import "PharmacyDetailsViewController.h"
#import "PlanDocumentsViewController.h"
#import "SecurityQuestionViewController.h"
#import "SettingsManager.h"
#import "SettingsViewController.h"
#import "TuftsDoctorDetailsViewController.h"
#import "TuftsViewController.h"
#import "TuftsSearchViewController.h"
#import "VerificationCodeViewController.h"
#import "VisionViewController.h"
#import "WelcomeViewController.h"
@import GoogleMaps;

@interface AppDelegate ()

@property (nonatomic) SettingsManager *settingsManager;
@property (nonatomic) AuthenticationManager *authenticationManager;
@property (nonatomic) NavigationManager *rootNavigationManager;
@property (nonatomic) NavigationManager *navigationManager;
@property (nonatomic) NotificationManager *notificationManager;
@property (nonatomic) NearbyPharmacyMonitor *nearbyPharmacyMonitor;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([Environment isRunningTests]) {
        return YES;
    }
    
    [Fabric with:@[[Crashlytics class]]];

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[AFNetworkActivityLogger sharedLogger] startLogging];
#ifdef DEBUG
    [AFNetworkActivityLogger sharedLogger].level = AFLoggerLevelDebug;
#endif
    
    self.settingsManager = [[SettingsManager alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
    [self.settingsManager registerDefaults];
    
    LAContext *authenticationContext = [[LAContext alloc] init];
    self.authenticationManager = [[AuthenticationManager alloc] initWithContext:authenticationContext];
    
    NavigationController *rootNavigationController = [[NavigationController alloc] init];
    rootNavigationController.navigationBar.hidden = YES;
    rootNavigationController.hidesStatusBar = YES;
    self.rootNavigationManager = [[NavigationManager alloc] initWithNavigationController:rootNavigationController];
    
    NavigationController *navigationController = [[NavigationController alloc] init];
    navigationController.statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationManager = [[NavigationManager alloc] initWithNavigationController:navigationController parentNavigationManager:self.rootNavigationManager];
    
    self.notificationManager = [[NotificationManager alloc] initWithApplication:application navigationManager:self.navigationManager];
    [self.notificationManager registerUserNotificationSettings];
    
    LocationMonitor *locationMonitor = [LocationMonitor sharedMonitor];
    self.nearbyPharmacyMonitor = [[NearbyPharmacyMonitor alloc] initWithLocationMonitor:locationMonitor regionRadius:50 settingsManager:self.settingsManager notificationManager:self.notificationManager];
    [locationMonitor startMonitoringForLocationChanges];
    
    [self setUpGoogleMaps];
    [self registerViewControllers];
    [self.navigationManager navigateTo:@"/home"];

    if (self.settingsManager.importedCVSData) {
        [self.rootNavigationManager navigateTo:@"/home"];
    } else {
        [self.rootNavigationManager navigateTo:@"/loading"];
        LoadingViewController *loadingViewController = [self.rootNavigationManager viewControllerForPath:@"/loading"];

        [self importCVSDatabaseUsingProgressBlock:^(float progress) {
            loadingViewController.progress = progress;
        } completion:^{
            loadingViewController.progress = 1.0;
            self.settingsManager.importedCVSData = YES;
            [self.rootNavigationManager navigateTo:@"/home"];
        }];
    }

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = rootNavigationController;
    [self.window makeKeyAndVisible];
    
#ifdef DEBUG
    if ([Environment isDebuggingNotifications]) {
        Pharmacy *pharmacy = [[DataManager sharedManager] fetchPharmacyWithID:1];
        [self.notificationManager presentLocalNotification:[self.notificationManager notificationForNearbyPharmacy:pharmacy]];
    }
#endif
    
    return YES;
}

- (void)setUpGoogleMaps {
    [GMSServices provideAPIKey:@"AIzaSyCO9cF88sHLsHwcUeqkBUoTxFsIJZ3OSsg"];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LocationMonitorLocationDidChangeNotification object:nil];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self.notificationManager handleLocalNotification:notification];
}

- (void)importCVSDatabaseUsingProgressBlock:(void(^)(float progress))progressHandler completion:(void(^)())completionHandler {
    FMDatabase *database = [FMDatabase databaseWithPath:nil];
    if (![database open]) {
        NSLog(@"Failed to create im-memory database for CVS stores: %@", database.lastError);
        return;
    }

    NSError *error;
    NSString *SQLPath = [[NSBundle mainBundle] pathForResource:@"CVS" ofType:@"sql"];
    NSString *SQL = [NSString stringWithContentsOfFile:SQLPath encoding:NSUTF8StringEncoding error:&error];

    if (error != nil) {
        NSLog(@"Failed to open CVS database dump: %@", error);
        return;
    }

    if (![database executeStatements:SQL]) {
        NSLog(@"Failed to import CVS dump into SQLite database: %@", database.lastErrorMessage);
        return;
    }

    NSManagedObjectContext *managedObjectContext = [DataManager sharedManager].managedObjectContext;
    NSManagedObjectContext *privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateManagedObjectContext.parentContext = managedObjectContext;

    CVSDatabaseReader *reader = [[CVSDatabaseReader alloc] initWithDatabase:database];
    CVSDatabaseImporter *importer = [[CVSDatabaseImporter alloc] initWithDatabaseReader:reader managedObjectContext:managedObjectContext privateManagedObjectContext:privateManagedObjectContext];

    [importer importCVSDataUsingProgressBlock:progressHandler completion:completionHandler];
}

- (void)registerViewControllers {
    MenuViewController *menuViewController = [[MenuViewController alloc] initWithNavigationManager:self.navigationManager];
    SWRevealViewController *revealViewController = [[SWRevealViewController alloc] initWithRearViewController:menuViewController frontViewController:self.navigationManager.navigationController];

    LoginViewController *loginViewController = [[LoginViewController alloc] initWithSettingsManager:self.settingsManager authenticationManager:self.authenticationManager];
    WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] init];

    [self.rootNavigationManager registerPath:@"/loading" forViewController:[[LoadingViewController alloc] init]];
    [self.rootNavigationManager registerPath:@"/home" forBlock:^UIViewController *{
        if (!self.settingsManager.completedRegistration && self.settingsManager.username.length == 0) {
            return welcomeViewController;
        } else {
            return loginViewController;
        }
    }];
    [self.rootNavigationManager registerPath:@"/login" forViewController:loginViewController];
    [self.rootNavigationManager registerPath:@"/welcome" forViewController:welcomeViewController];
    [self.rootNavigationManager registerPath:@"/welcome/verification-code" forViewController:[[VerificationCodeViewController alloc] init]];
    [self.rootNavigationManager registerPath:@"/welcome/verification-code/account" forViewController:[[AccountViewController alloc] init]];
    [self.rootNavigationManager registerPath:@"/welcome/verification-code/account/security-questions" forViewController:[[SecurityQuestionViewController alloc] init]];
    [self.rootNavigationManager registerPath:@"/start" forViewController:revealViewController];

    MyChristieViewController *myChristieViewController = [[MyChristieViewController alloc] init];
    [self.navigationManager registerPath:@"/home" forViewController:myChristieViewController];
    [self.navigationManager registerPath:@"/my-christie" forViewController:myChristieViewController];
    [self.navigationManager registerPath:@"/my-christie/claims" forViewController:[[ClaimsViewController alloc] init]];
    [self.navigationManager registerPath:@"/pharmacies" forViewController:[[PharmaciesViewController alloc] init]];
    [self.navigationManager registerPath:@"/pharmacies/details" forViewController:[[PharmacyDetailsViewController alloc] init]];

    CignaViewController *cignaViewController = [[CignaViewController alloc] init];
    TuftsViewController *tuftsViewController = [[TuftsViewController alloc] init];
    [self.navigationManager registerPath:@"/doctors" forBlock:^UIViewController *{
        HealthPlan plan = [HealthPlanDetector healthPlanFromLocation:[LocationMonitor sharedMonitor].location];
        switch (plan) {
            case HealthPlanTufts:
                return tuftsViewController;
            case HealthPlanCigna:
            case HealthPlanBoth:
            case HealthPlanUnknown:
                return cignaViewController;
            default:
                return nil;
        }
    }];
    [self.navigationManager registerPath:@"/doctors-cigna" forViewController:cignaViewController];
    [self.navigationManager registerPath:@"/doctors-cigna/search" forViewController:[[CignaSearchViewController alloc] initWithGeocoder:[[CLGeocoder alloc] init]]];
    [self.navigationManager registerPath:@"/doctors-cigna/specialities" forViewController:[[CignaSpecialitiesViewController alloc] init]];
    [self.navigationManager registerPath:@"/doctors-tufts" forViewController:tuftsViewController];
    [self.navigationManager registerPath:@"/doctors-tufts/details" forViewController:[[TuftsDoctorDetailsViewController alloc] init]];
    [self.navigationManager registerPath:@"/doctors-tufts/search" forViewController:[[TuftsSearchViewController alloc] init]];
    
    [self.navigationManager registerPath:@"/vision" forViewController:[[VisionViewController alloc] init]];
    [self.navigationManager registerPath:@"/dental" forViewController:[[DentalViewController alloc] init]];
    [self.navigationManager registerPath:@"/europ-assist" forViewController:[[EuropAssistViewController alloc] init]];
    [self.navigationManager registerPath:@"/plan-documents" forViewController:[[PlanDocumentsViewController alloc] init]];
    [self.navigationManager registerPath:@"/legal-documents" forViewController:[[LegalDocumentsViewController alloc] init]];
    [self.navigationManager registerPath:@"/settings" forViewController:[[SettingsViewController alloc] initWithSettingsManager:self.settingsManager authenticationManager:self.authenticationManager]];
}

@end