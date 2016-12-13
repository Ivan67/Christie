#import <Foundation/Foundation.h>

@interface User : NSObject

/**
 * Whether the user is currently logged in.
 */
@property (nonatomic, getter=isLoggedIn) BOOL loggedIn;

/**
 * The unique ID of the user.
 */
@property (nonatomic) NSInteger id;

/**
 * The student ID of the user.
 */
@property (nonatomic) NSInteger studentID;

/**
 * The username (login) of the user.
 */
@property (nonatomic, copy) NSString *username;

/**
 * User's first name.
 */
@property (nonatomic, copy) NSString *firstName;

/**
 * User's last name.
 */
@property (nonatomic, copy) NSString *lastName;

/**
 * The first address line.
 */
@property (nonatomic, copy) NSString *address1;

/**
 * The second second address line.
 */
@property (nonatomic, copy) NSString *address2;

/**
 * User's phone number.
 */
@property (nonatomic, copy) NSString *phone;

/**
 * E-mail address.
 */
@property (nonatomic, copy) NSString *email;

/**
 * Physical country.
 */
@property (nonatomic, copy) NSString *country;

/**
 * The old member ID of the user.
 */
@property (nonatomic, copy) NSString *oldMemberID;

/**
 * User's birth date.
 */
@property (nonatomic, copy) NSDate *birthDate;

/**
 * Returns the shared User object.
 *
 * @return User singleton.
 */
+ (instancetype)sharedUser;

@end
