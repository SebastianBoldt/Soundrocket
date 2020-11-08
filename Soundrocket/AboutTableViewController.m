//
//  AboutTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <FAKFontAwesome.h>
#import "AboutTableViewController.h"
#import <FAKIonIcons.h>
#import "SRStylesheet.h"
#import <SupportKit/SupportKit.h>
#import "SRUserController.h"

@interface AboutTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *poweredBySoundcloudLabel;
@property (weak, nonatomic) IBOutlet UILabel *supportLabel;
@property (weak, nonatomic) IBOutlet UILabel *getSoundrocketProLabel;


@end

@implementation AboutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.poweredByLabel.textColor = [SRStylesheet mainColor];
    self.getSoundrocketProLabel.text = NSLocalizedString(@"ABOUT_PAGE_GET_SOUNDROCKET_PRO_LABEL", nil).uppercaseString;
    NSAttributedString *attributedString =
    [[NSAttributedString alloc]
     initWithString:@"Soundrocket"
     attributes:
     @{
       NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:45],
       NSForegroundColorAttributeName : [SRStylesheet mainColor],
       NSKernAttributeName : @(-4.0f)
       }];
    
    self.soundrocketNameLabel.attributedText = attributedString;
    [self.navigationItem setTitle:@"About"];
    [self.logoImageView.layer setMinificationFilter:kCAFilterTrilinear];

    NSMutableAttributedString * websiteIcon = [[[FAKIonIcons earthIconWithSize:14]attributedString]mutableCopy];
    NSMutableAttributedString * contactIcon = [[[FAKIonIcons iosEmailIconWithSize:14]attributedString]mutableCopy];
    NSMutableAttributedString * starIcon = [[[FAKIonIcons iosStarIconWithSize:14]attributedString]mutableCopy];
    NSMutableAttributedString * supportIcon = [[[FAKIonIcons iosPeopleIconWithSize:14]attributedString]mutableCopy];
    NSMutableAttributedString * myProfileIcon = [[[FAKIonIcons iosMusicalNoteIconWithSize:14]attributedString]mutableCopy];
    NSMutableAttributedString * facebookIcon = [[[FAKFontAwesome facebookIconWithSize:14]attributedString]mutableCopy];


    [websiteIcon appendAttributedString:[[NSAttributedString alloc]initWithString:NSLocalizedString(@"Developers Website", nil)]];
    [contactIcon appendAttributedString:[[NSAttributedString alloc]initWithString:NSLocalizedString(@"Contact me", nil)]];
    [starIcon appendAttributedString:[[NSAttributedString alloc]initWithString:NSLocalizedString(@"Rate this App",nil)]];
    [supportIcon appendAttributedString:[[NSAttributedString alloc]initWithString:NSLocalizedString(@"Support", nil)]];
    [myProfileIcon appendAttributedString:[[NSAttributedString alloc]initWithString:NSLocalizedString(@"My Soundcloud Profile", nil)]];
    [facebookIcon appendAttributedString:[[NSAttributedString alloc]initWithString:NSLocalizedString(@"Like Soundrocket on Facebook", nil)]];


    self.webSiteLabel.attributedText =  websiteIcon;
    self.contactLabel.attributedText =  contactIcon;
    self.rateThisAppLabel.attributedText = starIcon;
    self.supportLabel.attributedText = supportIcon;
    self.mySoundCloudProfileLabel.attributedText = myProfileIcon;
    self.facebookLabel.attributedText = facebookIcon;
    
    // Build Number
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * versionBuildString = [NSString stringWithFormat:@"Version: %@ (%@)", appVersionString, appBuildString];
    self.versionLabel.text = versionBuildString;
    // App name
    //self.appNameLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
}

-(void)showSupport {
    [SupportKit show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%li",(long)indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        // Do nothing
    }
    else if (indexPath.row == 2) {
        [self showMyProfile];
    } else if (indexPath.row == 3) {
        [self facebookPressed];
    } else if (indexPath.row == 4) {
        [self rateThisAppPressed];
    } else if (indexPath.row == 5) {
        [self websitePressed];
    } else if(indexPath.row == 6){
        [self feedbackPressed];
    } else {
        [self showSupport];
    }
}

-(void)facebookPressed {
    NSURL * url = [NSURL URLWithString:@"https://www.facebook.com/soundrocketapp"];
    [[UIApplication sharedApplication]openURL:url];
}
-(void)rateThisAppPressed {
    NSURL * url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id957116901"];
    [[UIApplication sharedApplication]openURL:url];
}
-(void)feedbackPressed {
    NSURL * url = [NSURL URLWithString:@"mailto:sebastian.boldt.1989@googlemail.com"];
    [[UIApplication sharedApplication]openURL:url];
    
}

-(void)websitePressed {
    NSURL * url = [NSURL URLWithString:@"http://sebastianboldt.com"];
    [[UIApplication sharedApplication]openURL:url];
}

-(void)showMyProfile{
    SRUserController * controller = [self.storyboard instantiateViewControllerWithIdentifier:@"user"];
    controller.user_ID = @(167066);
    [self.navigationController pushViewController:controller animated:YES];
}
@end
