//
//  IntroViewController.m
//  StumbleSound
//
//  Created by Sebastian Boldt on 30.05.14.
//  Copyright (c) 2014 Sebastian Boldt. All rights reserved.
//

#import "IntroViewController.h"
#import "PageContentViewController.h"
#import <FAKIonIcons.h>
@interface IntroViewController ()
@property(nonatomic)bool twitterAvailable;
@property(nonatomic)bool facebookAvailable;
@property(nonatomic,strong)NSUserDefaults * sharedDefaults;
@end

@implementation IntroViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    FAKIonIcons *cogIcon = [FAKIonIcons iosCloseEmptyIconWithSize:30];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(30, 30)];
    cogIcon.iconFontSize = 15;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(30, 30)];
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(close:)];
    
    self.title = @"Tips";
    self.navigationController.navigationBar.translucent=NO;

	// Create the data model
    _pageTitles = @[NSLocalizedString(@"page0",nil),NSLocalizedString(@"page1",nil),NSLocalizedString(@"page2",nil), NSLocalizedString(@"page3",nil), NSLocalizedString(@"page4",nil), NSLocalizedString(@"page5",nil)];
    _pageImages = @[@"page0.jpg",@"page1.jpg",@"page2.jpg", @"page3.jpg", @"page4.jpg", @"page5.jpg"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

}

-(void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}
- (IBAction)startApp:(id)sender {
    
    UIStoryboard *mainStoryboard = self.storyboard;
    
    IntroViewController *controller = (IntroViewController *)[mainStoryboard
                                                              instantiateViewControllerWithIdentifier: @"SRTabbarController"];
    [self presentViewController:controller animated:YES completion:nil];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startWalkthrough:(id)sender {
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)refreshButtonPressed:(id)sender {
    /*[self rescan];
    
    if ([[self.sharedDefaults objectForKey:@"twitter"]boolValue] == true) {
        [SVProgressHUD showSuccessWithStatus:@"Twitter-App found"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Twitter-App not found, Webpage will be openend instead"];
    }
    
    [self performSelector:@selector(checkFacebook) withObject:nil afterDelay:2.0];
     */
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
