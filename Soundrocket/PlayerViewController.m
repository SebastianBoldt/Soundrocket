
// Libarys
#import <FAKFontAwesome.h>
#import <QuartzCore/QuartzCore.h>
#import <UIImageView+AFNetworking.h>
#import <MarqueeLabel.h>
#import <MediaPlayer/MediaPlayer.h>
#import <FAKIonIcons.h>
#import <SZTextView.h>
#import <SVProgressHUD.h>

// Own classe
#import "SRCommentsViewController.h"
#import "PlayerViewController.h"
#import "SRPeopleLikedTrackViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Soundrocket-SWIFT.h"
#import "SoundrocketClient.h"
#import "SRStylesheet.h"
#import "SRDownloadManager.h"
#import "SRPlayer.h"   
#import "MiniPlayer.h"
#import "SRAuthenticator.h"
#import "SRRequestModel.h"
#import "SuggestionCollectionViewCell.h"
#import "SRPlaylistTracksController.h"
#import "DescriptionViewController.h"
#import "SRWhatsNextViewController.h"
#import "CustomModalTransitionDelegate.h"
#import <DGActivityIndicatorView.h>
@interface PlayerViewController () <SRPlayerDelegate,SRRequestModelDelegate,UICollectionViewDataSource,UICollectionViewDelegate,SRTrackCollectionViewCellDelegate,SRCommentsViewControllerDelegate,SRWhatsNextViewControllerDelegate>

// Essential 
@property (nonatomic,strong)  SRPlayer * player;

// Interface builder outlets
@property (weak, nonatomic) IBOutlet UIButton *showVolumeFaderButton;
@property (nonatomic,strong)IBOutlet NSLayoutConstraint * bottomVolumeFaderConstraint;
@property (weak, nonatomic) IBOutlet UIButton *showCommentsButton;
@property (weak, nonatomic) IBOutlet UIView *contentViewofVisualEffectView;
@property (weak, nonatomic) IBOutlet UICollectionView *suggestionCollectionView;
@property (nonatomic,strong) DGActivityIndicatorView * activityView;
// Views
@property (nonatomic,strong) UIView * scrollBar;
@property (nonatomic,strong) UIView * bufferingSzone;
@property (nonatomic,strong) UIView * currentCommentView;
@property (nonatomic,strong) UIView * commentPlacerView;
@property (nonatomic,strong) IBOutlet UIView * commentingCanvas;
@property (nonatomic,strong) IBOutlet UIView * volumeControlView;
@property (nonatomic,strong) IBOutlet UIView * commentingView;
@property (nonatomic,strong) IBOutlet NSLayoutConstraint * topConstraintCommentingView;
@property (nonatomic,strong) UIImage * artworkImage;
@property (nonatomic,strong) UIView * miscView;
@property (nonatomic,strong) UIBarButtonItem * downloadButton;
@property (nonatomic,strong) IBOutlet UILabel * statsLabel;
@property (nonatomic,strong) UIBarButtonItem * repeatButton;

// Container
@property (nonatomic,strong) NSMutableArray * currentCommentViews;
@property (nonatomic,strong) NSMutableArray * currentComments;

// Flags
@property                    NSInteger currentCommentIndex;
@property (nonatomic)        BOOL runTimeDetection;
@property (nonatomic,assign) BOOL liked;
@property (nonatomic,assign) BOOL  commentingViewActive;
@property (nonatomic,assign) BOOL volumeViewActive;

// Information Controller
@property (nonatomic,strong) CustomModalTransitionDelegate * infoControllerTransitionDelegate;
// constraints
@property (nonatomic,strong) IBOutlet NSLayoutConstraint * commentsViewHeightConstraints;
@end

@implementation PlayerViewController

+(instancetype)sharedPlayerViewController {
    static PlayerViewController *_sharedPlayerController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Init Stuff
        _sharedPlayerController= [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Player"];
    });
    return _sharedPlayerController;

}

-(void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - Lifecylce

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * isEnabled  =     [defaults objectForKey:@"SoundrocketPro"];
    if (![isEnabled boolValue]) {
        self.commentsView.hidden = YES;
        self.commentsViewHeightConstraints.constant = 0;
    } else {
        self.commentsView.hidden = NO;
        self.commentsViewHeightConstraints.constant = 35;
    }
    
    self.player = [SRPlayer sharedPlayer];
    [self.player addDelegate:self];
    self.volumeViewActive = NO;

    [self setDoneButton];
    [self setNextButton];
    [self setupOptionsMenu];
    self.runTimeDetection = true;
    self.liked = false;
    self.nextCommentButton.tintColor = [SRStylesheet mainColor];
    self.lastCommentButton.tintColor = [SRStylesheet mainColor];
    self.trackIDLabel.textColor = [SRStylesheet whiteColor];
    // Setting up Scrollbar
    UIView *scrollbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, self.waveformView.frame.size.height)];
    scrollbar.backgroundColor = [SRStylesheet mainColor];
    self.scrollBar = scrollbar;
    self.scrollBar.layer.zPosition = 1000;
    [self.waveformView addSubview:self.scrollBar];
    
    self.currentCommentViews = [[NSMutableArray alloc]init];
    self.currentComments = [[NSMutableArray alloc]init];
    
    [self.artistLabel addTarget:self action:@selector(artistButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer * panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pannedWaveform:)];
    [self.waveformView addGestureRecognizer:panRecognizer];
    
    UIPanGestureRecognizer * panCommentsRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pannedComments:)];
    panCommentsRecognizer.maximumNumberOfTouches = 1;
    panCommentsRecognizer.minimumNumberOfTouches = 1;
    [self.commentsView addGestureRecognizer:panCommentsRecognizer];
    
    FAKIonIcons *starIcon = [FAKIonIcons chatboxIconWithSize:20];
    self.commentIconLabel.attributedText = [starIcon attributedString];
    
    [self.nextCommentButton setAttributedTitle:[[FAKIonIcons iosArrowRightIconWithSize:35]attributedString] forState:UIControlStateNormal];
    [self.lastCommentButton setAttributedTitle:[[FAKIonIcons iosArrowLeftIconWithSize:35]attributedString] forState:UIControlStateNormal];
    
    self.nextTrackButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.lastTrackButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.playButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self setupCommentingFunction];
    
    FAKIonIcons *volume = [FAKIonIcons volumeHighIconWithSize:20];
    FAKIonIcons *comment = [FAKIonIcons chatboxIconWithSize:20];
    [self.showCommentsButton setAttributedTitle:[comment attributedString] forState:UIControlStateNormal];
    [self.showVolumeFaderButton setAttributedTitle:[volume attributedString] forState:UIControlStateNormal];
    
    [self setupSharing];
    [self setupDownloading];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudTapped:) name:SVProgressHUDDidReceiveTouchEventNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(proplanBought:) name:@"ProPurchased" object:nil];
    
    UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpFrom:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:swipeUpGestureRecognizer];
    
    [self.suggestionCollectionView registerNib:[UINib nibWithNibName:@"SuggestionColllectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"suggestionCell"];
    
}

- (void)handleSwipeUpFrom:(UIGestureRecognizer*)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)proplanBought:(id)sender {
    self.commentsViewHeightConstraints.constant = 35;
    self.commentsView.hidden = NO;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.eaqualizerView start];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}


#pragma mark - SRDelegate 

-(void)player:(SRPlayer *)player willStartWithTrack:(Track *)track fromIndexPath:(NSIndexPath *)path {
    self.navigationItem.title = @"";
    [self setCurrentTrack:track];
}

-(void)player:(SRPlayer *)player didFinishWithTrack:(Track *)track {
    // Player did finish with playing track
}

-(void)player:(SRPlayer *)player willPlayTrack:(Track *)track {
    [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [self.eaqualizerView start];
    [self.loadingIndicator stopAnimating];
}

-(void)player:(SRPlayer *)player willPauseTrack:(Track *)track {
    [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];    // This changes the button to Play
    [self.eaqualizerView stop];
}

-(void)player:(SRPlayer *)player isReadyToPlayTrack:(Track *)track {
    [self.waveformView setUserInteractionEnabled:YES];
}

-(void)player:(SRPlayer *)player willStartWithOfflineTrack:(Track *)track {
    self.navigationItem.title = @"Offline";
}

#pragma mark - Download Stuff

-(void)hudTapped:(id)sender {
    /*
    [[SRDownloadManager sharedManager]pauseOperation];
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Cancel Download ?" message:@"Do you really want to cancel the Download ?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * resumeAction = [UIAlertAction actionWithTitle:@"Resume" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        [[SRDownloadManager sharedManager]resumeOperation];
        
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction*action){
        [[SRDownloadManager sharedManager]cancelOperation];
        [[SRDownloadManager sharedManager]removeTrack:self.player.currentTrack];
        [SVProgressHUD dismiss];
    }];
    alertController.popoverPresentationController.barButtonItem = self.downloadButton;
    [alertController addAction:resumeAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];*/

}

#pragma mark - Setup functions
-(void)setupSharing {
    FAKIonIcons *cogIcon = [FAKIonIcons iosUploadOutlineIconWithSize:25];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    cogIcon.iconFontSize = 25;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    UIBarButtonItem *sharingButton =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(sharingButtonTapped:)];
    
    NSMutableArray * items = [self.navigationItem.rightBarButtonItems mutableCopy];
    [items addObject:sharingButton];
    self.navigationItem.rightBarButtonItems = items;
}

-(void)setNextButton {
    FAKIonIcons *cogIcon = [FAKIonIcons iosMoreOutlineIconWithSize:25];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    cogIcon.iconFontSize = 25;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(optionsButtonPressed:)];
}
-(void)setDoneButton {
    
    CGFloat buttonSize = 25;
    
    UIBarButtonItem * doneButton = [SRButtonBuilder buttonForFAKIcon:[FAKIonIcons iosArrowDownIconWithSize:buttonSize]
                                                                size:buttonSize
                                                            selector:@selector(closePlayerButtonPressed:)
                                                              target:self];
    
    UIBarButtonItem * infoButton = [SRButtonBuilder buttonForFAKIcon:[FAKIonIcons iosInformationOutlineIconWithSize:buttonSize]
                                                                size:buttonSize
                                                            selector:@selector(showInfoButtonTapped:)
                                                              target:self];
    
    self.repeatButton = [SRButtonBuilder buttonForFAKIcon:[FAKIonIcons iosLoopIconWithSize:buttonSize]
                                                     size:buttonSize
                                                 selector:@selector(repeatButtonTapped:)
                                                   target:self];
    
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    BOOL repeatOn = NO;
    
    if ([defaults objectForKey:@"repeatStatus"]) {
        repeatOn = [[defaults objectForKey:@"repeatStatus"]boolValue];
    }
    
    if (repeatOn) {
        self.repeatButton.tintColor = [SRStylesheet mainColor];
    } else  {
        self.repeatButton.tintColor = [SRStylesheet whiteColor];
    }
    
    
    self.navigationItem.leftBarButtonItems =@[doneButton,infoButton,self.repeatButton];
}

-(void)repeatButtonTapped:(id)sender {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    BOOL repeatOn = NO;
    repeatOn = [[defaults objectForKey:@"repeatStatus"]boolValue];
    
    [defaults setObject:[NSNumber numberWithBool:!repeatOn] forKey:@"repeatStatus"];
    [defaults synchronize];
    
    if (!repeatOn) {
        self.repeatButton.tintColor = [SRStylesheet mainColor];
    } else {
        self.repeatButton.tintColor = [SRStylesheet whiteColor];
    }
}

-(void)showInfoButtonTapped:(id)sender {
    UINavigationController * navController = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoNavViewController"];
    
    if ([[navController viewControllers][0] isKindOfClass:[DescriptionViewController class]]) {
        DescriptionViewController * dvc = (DescriptionViewController*)[navController viewControllers][0];
        dvc.descriptionText = self.player.currentTrack.descriptionText;
        if(!self.infoControllerTransitionDelegate){
            self.infoControllerTransitionDelegate = [[CustomModalTransitionDelegate alloc]init];
        }
        navController.modalPresentationStyle = UIModalPresentationCustom;
        navController.transitioningDelegate = self.infoControllerTransitionDelegate;
        
        [self presentViewController:navController animated:YES completion:nil];
    }
}

-(void)setupDownloading {
    /*NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * isEnabled  =     [defaults objectForKey:@"SoundrocketPro"];
    if (self.player.currentTrack.downloadable && isEnabled) {
        FAKIonIcons * cogIcon = [FAKIonIcons ios7DownloadOutlineIconWithSize:25];
        [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(20, 20)];
        cogIcon.iconFontSize = 15;
        UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(15, 15)];
        
        self.downloadButton = [[UIBarButtonItem alloc] initWithImage:leftImage
                                                            landscapeImagePhone:leftLandscapeImage
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(downloadTrack)];
        
        FAKIonIcons *closeIcon = [FAKIonIcons ios7ArrowDownIconWithSize:25];
        [closeIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        UIImage *leftImageClose = [closeIcon imageWithSize:CGSizeMake(25, 25)];
        closeIcon.iconFontSize = 25;
        UIImage *leftLandscapeImageClose = [closeIcon imageWithSize:CGSizeMake(25, 25)];
        
        self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:leftImageClose
                             landscapeImagePhone:leftLandscapeImageClose
                                           style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(closePlayerButtonPressed:)],self.downloadButton];
        
    } else {
        [self setDoneButton];
    }*/

}

-(void)downloadTrack {
    /*
    NSMutableArray * downloadedTracks = [[SRDownloadManager sharedManager]downloadedTracks];
    BOOL trackAllreadyDownloaded = false;
    
    for (Track * track in downloadedTracks) {
        if ([track.id integerValue] == [self.player.currentTrack.id integerValue]) {
            trackAllreadyDownloaded = true;
        }
    }
    
    if (!trackAllreadyDownloaded) {
        
        void (^progressBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) = ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            CGFloat progressValue = (CGFloat)((CGFloat)totalBytesRead/(CGFloat)totalBytesExpectedToRead);
            [SVProgressHUD showProgress:progressValue status:@"Downloading..." maskType:SVProgressHUDMaskTypeBlack];
        };
        
        __block NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:
                                      [NSString stringWithFormat:@"%@.mp3",[[NSUUID UUID] UUIDString]]];
        void (^completionBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error;
            if (error) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Something went wrong, please try again", nil)];
            } else {
                [SVProgressHUD showSuccessWithStatus:@"Success"];
                self.player.currentTrack.local_path = fullPath;
                [[SRDownloadManager sharedManager]saveTrack:self.player.currentTrack key:fullPath];
            }
            
            
        };
        
        void(^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Something went wrong, please try again", nil)];
        };
        
        NSString * downloadPath = nil;
        if (self.player.currentTrack.download_url) {
            downloadPath = self.player.currentTrack.download_url;
        } else if (self.player.currentTrack.stream_url) {
            NSURL * url = [NSURL URLWithString:self.player.currentTrack.stream_url];
            url = [url URLByDeletingLastPathComponent];
            url = [url URLByAppendingPathComponent:@"download"];
            downloadPath = [url absoluteString];
        }
        
        NSLog(@"PATH:%@",downloadPath);
        [[SRDownloadManager sharedManager]downloadFileForURL:downloadPath withProgressBlock:progressBlock andCompletionBlockForSuccess:completionBlock andFailure:failureBlock directory:fullPath];
    
    } else {
        [SVProgressHUD showSuccessWithStatus:@"Track allready downloaded"];
    } */
}

-(void)sharingButtonTapped:(UIBarButtonItem*)button {
    
    NSString *string = [NSString stringWithFormat:@"%@ by %@ on #SoundCloud via #Soundrocket",self.player.currentTrack.title,self.player.currentTrack.user.username];
    NSURL *URL = [NSURL URLWithString:self.player.currentTrack.permalink_url];
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string,URL]
                                      applicationActivities:nil];
    activityViewController.popoverPresentationController.barButtonItem = button;

    [self presentViewController:activityViewController
                       animated:YES
                     completion:^{
                         // ...
                     }];
}

// Submit the fucking comment
-(IBAction)submitComment:(id)sender{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * isEnabled  =     [defaults objectForKey:@"SoundrocketPro"];
    if ([isEnabled boolValue]) {
        float placePosition = self.commentPlacerView.frame.origin.x; // Position auf dem Bildschirm
        float width = self.waveformView.frame.size.width;
        float timeStampOfTrack = [self.player.currentTrack.duration floatValue];
        
        float timeStamp = (placePosition/width) * timeStampOfTrack;
        int intTimeStamp = (int)timeStamp;
        
        NSNumber * postionTimeStamp = [NSNumber numberWithInt:intTimeStamp];
        UITextView * textView = (UITextView*)[self.commentingView viewWithTag:1];
        NSString * comment = textView.text;
        
        if (comment.length) {
            [SVProgressHUD showWithStatus:@"Commenting"];
            [[SoundCloudAPI sharedApi]addComment:comment toTrack:self.player.currentTrack fromUserWithAuthToken:[SRAuthenticator sharedAuthenticator].authToken atTime:postionTimeStamp whenSuccess:^(NSURLSessionTask * task,id responseObject){
                [[UIApplication sharedApplication]endIgnoringInteractionEvents];
                [self hideCommentingView];
                SZTextView * textlabel = (SZTextView*)[self.commentingView viewWithTag:1];
                textlabel.text = @"";
                [SVProgressHUD showSuccessWithStatus:@"Successfully commented"];
                [self setUpComments:self.player.currentTrack];
            } whenError:^(NSURLSessionTask* task, NSError * error){
                [[UIApplication sharedApplication]endIgnoringInteractionEvents];
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Something went wrong, please try again", nil)];
            }];
            
        } else {
            [SRHelper showError:@"Comment has no text"];
        }
        
    } else {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"This Feature is just available for Soundrocket PRO User", nil) message:NSLocalizedString(@"PRO_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * showAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Tell me more", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            self.commentsView.hidden = YES;
            [self.commentView setHidden:YES];
            __weak __block __typeof(self) weakself = self;

            [self dismissViewControllerAnimated:YES completion:^(){
                [weakself.delegate playerViewControllerDidDismissForProPlan:weakself];
            }];
            
        }];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){
        }];
        [alertController addAction:showAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];

    }

}
-(void)setupCommentingFunction {
    self.commentingViewActive = NO;
    UILongPressGestureRecognizer * pressRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTappedCommentArea:)];
    [pressRecognizer setMinimumPressDuration:0.5];
    [self.commentsView addGestureRecognizer:pressRecognizer];
}

-(void)longTappedCommentArea:(UILongPressGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if(!self.commentingViewActive){
            self.commentingViewActive = true;
            
            NSUInteger heightOfCommentingView = self.commentsView.frame.size.height;
            CGPoint pt = [recognizer locationOfTouch:0 inView:recognizer.view];
            
            self.commentPlacerView = [[UIView alloc]initWithFrame:CGRectMake(pt.x, 0, 1, heightOfCommentingView)];
            self.commentPlacerView.backgroundColor = [SRStylesheet mainColor];
            
            [self.commentingCanvas addSubview:self.commentPlacerView];
            
            [self showCommentingView];

        }
    }
}

-(IBAction)commentingCanvasPanned:(UIPanGestureRecognizer*)recognizer{
    if ([recognizer numberOfTouches] > 0) {
        NSUInteger heightOfCommentingView = self.commentsView.frame.size.height;
        CGPoint pt = [recognizer locationOfTouch:0 inView:recognizer.view];
        self.commentPlacerView.frame = CGRectMake(pt.x, 0, 1, heightOfCommentingView);
    }
}

-(void)showCommentingView {
    self.topConstraintCommentingView.constant = 0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration: .5];
    [UIView setAnimationDelegate: self];
    [self.commentingView layoutIfNeeded];
    self.commentingCanvas.hidden = NO;
    [UIView commitAnimations];
    [[self.commentingView viewWithTag:1]becomeFirstResponder];
}

-(IBAction)hideCommentingView {
    self.commentingViewActive = NO;
    [self.commentPlacerView removeFromSuperview];
    self.commentPlacerView = nil;
    [[self.commentingView viewWithTag:1]resignFirstResponder];
    self.topConstraintCommentingView.constant = -200;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration: .5];
    [UIView setAnimationDelegate: self];
    self.commentingCanvas.hidden = YES;
    [self.commentingView layoutIfNeeded];
    [UIView commitAnimations];
}

/*********************************************************************************
 Recognizes Touch Pan Events on Comments and
 than looking for neares Comment to Show in
 Comment Box.
 *********************************************************************************/

-(void)pannedComments:(UIPanGestureRecognizer*)recognizer {
    
    if ([recognizer numberOfTouches] > 0) {
        
        CGPoint pt = [recognizer locationOfTouch:0 inView:recognizer.view];
        NSDictionary * comment = [self findNearestComment:pt.x];
        
        //NSLog(@"%@",comment);
        if (comment) {
            [self.commentView setHidden:NO];
            if (comment != nil) {
                self.currentCommentLabel.text = [NSString stringWithFormat:@"%@",[comment objectForKey:@"body"]];
                self.userNameLabel.text = [NSString stringWithFormat:@"%@",[[comment objectForKey:@"user"]objectForKey:@"username"]];
            }
                
        }
        
        
    }
    
}
/*********************************************************************************
 Looking for nearest Comment and return it
 *********************************************************************************/

-(NSDictionary*)findNearestComment:(int)xPosition {
    
    // 1000 Miliskeunden = 1 Sekunde
    float durationOfTrack = [self.player.currentTrack.duration floatValue]; // Wir holen uns die Länge des Tracks
    float tolerance =  durationOfTrack * 0.1; // Setzen eines toleranzwertes
    float fingerPositionInMiliseconds = (xPosition/self.commentsView.frame.size.width) *durationOfTrack; // Umrechnung der Finger Position in duration
    
    NSArray *filteredarray = [self.currentComments filteredArrayUsingPredicate:
                              [NSPredicate predicateWithFormat:@"(timestamp >= %@) AND (timestamp <= %@)",
                               [NSNumber numberWithFloat:(fingerPositionInMiliseconds)-tolerance],
                               [NSNumber numberWithFloat:(fingerPositionInMiliseconds)+tolerance]]];
    
    if ([filteredarray firstObject]) {
        
            //float commentCorrection = xPosition /self.view.frame.size.width;
            self.currentCommentView.backgroundColor = [UIColor whiteColor];
            self.currentCommentView.layer.zPosition = 0;
        
            int index = (int)[self.currentComments indexOfObject:[filteredarray objectAtIndex:([filteredarray count]/2)]];
        
        
            // Crashlytics crash
        if (index < [self.currentCommentViews count]) {
            UIView * currentView = [self.currentCommentViews objectAtIndex:index];
            currentView.layer.zPosition = 1000;
            if (currentView) {
                currentView.backgroundColor = [SRStylesheet mainColor];
                self.currentCommentView = currentView;
                self.currentCommentIndex = index;
                
            }
        }

    }
    return [filteredarray firstObject];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closePlayerButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// This Methods setsup the AudioPlayer instance for playback Music
-(void)setupTrack {
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    [self setupDownloading];
    if (!self.optionsView.hidden) {
        [self showOrHideOptionsMenu:nil];
    }
    self.scrollBar.frame = CGRectMake(0, -3,2,70);
    [self.commentView setHidden:YES];

    [self checkLike];
}

-(void)artistButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(){
        [self.delegate playerViewControllerDidDismissWithUser:self.player.currentTrack.user];
    }];
}

#define likeButtonFontSize 100
-(void)checkLike {
        [self.likeButton setEnabled:NO];
    
    NSString * accessToken = nil;
    if ([SRAuthenticator sharedAuthenticator].authToken) {
        accessToken =  [SRAuthenticator sharedAuthenticator].authToken;
    } else {
        NSUserDefaults * standardDefaults = [NSUserDefaults standardUserDefaults];
        accessToken = [standardDefaults objectForKey:@"access_token"];
    }
    
    [[SoundCloudAPI sharedApi]checkIfUserWithAccessToken:accessToken hasFavoritedTrack:self.player.currentTrack whenSuccess:^(NSURLSessionTask * task,id responseObject){
        // everything is fine
        self.liked = true;
        FAKIonIcons *cogIcon = [FAKIonIcons iosHeartIconWithSize:likeButtonFontSize];
        cogIcon.iconFontSize = likeButtonFontSize;
        [cogIcon addAttribute:NSForegroundColorAttributeName value:[SRStylesheet redColor]];
        UIImage *heartImage = [cogIcon imageWithSize:CGSizeMake(likeButtonFontSize,likeButtonFontSize)];
        [self.likeButton setImage:heartImage forState:UIControlStateNormal];
        
        [self.likeButton setEnabled:YES];
    } whenError:^(NSURLSessionTask* task, NSError * error){
        self.liked =false;
        FAKIonIcons *cogIcon = [FAKIonIcons iosHeartOutlineIconWithSize:likeButtonFontSize];
        cogIcon.iconFontSize = likeButtonFontSize;
        [cogIcon addAttribute:NSForegroundColorAttributeName value:[SRStylesheet whiteColor]];
        UIImage *heartImage = [cogIcon imageWithSize:CGSizeMake(likeButtonFontSize,likeButtonFontSize)];
        [self.likeButton setImage:heartImage forState:UIControlStateNormal];
        [self.likeButton setEnabled:YES];
    }];
}

-(void)play {
    [self startRunTimeDetection];
    [self.player play];
}

-(void) pause {
    [self.player pause];
}

-(void)setCurrentTrack:(Track *)currentTrack {
    
    [self setupStatsLabelWithTrack:currentTrack];
    [self.likeButton setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    [self.likeButton.layer setMinificationFilter:kCAFilterTrilinear];

    self.trackIDLabel.text = currentTrack.title;
    [self.artistLabel setTitle:currentTrack.user.username forState:UIControlStateNormal];
    NSString * largeUrl = nil;
    if (currentTrack.artwork_url) {
        largeUrl = [currentTrack.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
    } else {
        largeUrl = [currentTrack.user.avatar_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
    }
    __weak __block __typeof(self) weakself = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:largeUrl]];
        UIImage * image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            weakself.artworkImage = image;
        });
        
    });
    

    __weak __block __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^(){
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:largeUrl]];
        UIImage *originalImage = [UIImage imageWithData:data];
        UIImage *flippedImage = [[UIImage alloc] initWithCGImage:originalImage.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.activityView removeFromSuperview];
            [weakSelf.mirroredCoverImageView setImage:flippedImage];
            weakSelf.coverImageView.image = originalImage;
        });
    });
    
    
    
    [self.backGroundView setImageWithURL:[NSURL URLWithString:largeUrl] placeholderImage:nil];
    [self.waveformView setupWithTrack:currentTrack];
    
    //
    [self setupTrack];
    [self setUpComments:currentTrack];
    [self play];
}

- (IBAction)lastCommentButtonPressed:(id)sender
{
    if (self.currentCommentIndex < ([self.currentComments count]- 1)) {
        // Vom letzten aktiven View farbe zurück setzen
        UIView * lastCommentView = [[self currentCommentViews]objectAtIndex:self.currentCommentIndex];
        [lastCommentView setBackgroundColor:[UIColor whiteColor]];
        self.currentCommentIndex = self.currentCommentIndex +1;
        [lastCommentView.layer setZPosition:10];
        
        
        UIView * currentCommentView = [[self currentCommentViews]objectAtIndex:self.currentCommentIndex];
        [currentCommentView setBackgroundColor:[SRStylesheet mainColor]];
        self.currentCommentLabel.text =  [[self.currentComments objectAtIndex:self.currentCommentIndex]objectForKey:@"body"];
        self.userNameLabel.text = [NSString stringWithFormat:@"%@",[[[self.currentComments objectAtIndex:self.currentCommentIndex] objectForKey:@"user"]objectForKey:@"username"]];
        [currentCommentView.layer setZPosition:1000];
        self.currentCommentView = currentCommentView;
    }
}

- (IBAction)nextCommentButtonPressed:(id)sender {
    
    // Vom letzten aktiven View farbe zurück setzen
    if (self.currentCommentIndex != 0) {
        
        UIView * lastCommentView = [[self currentCommentViews]objectAtIndex:self.currentCommentIndex];
        [lastCommentView.layer setZPosition:10];
        [lastCommentView setBackgroundColor:[UIColor whiteColor]];
        self.currentCommentIndex = self.currentCommentIndex -1;
        
        UIView * currentCommentView = [[self currentCommentViews]objectAtIndex:self.currentCommentIndex];
        [currentCommentView setBackgroundColor:[SRStylesheet mainColor]];
        self.currentCommentLabel.text =  [[self.currentComments objectAtIndex:self.currentCommentIndex]objectForKey:@"body"];
        self.userNameLabel.text = [NSString stringWithFormat:@"%@",[[[self.currentComments objectAtIndex:self.currentCommentIndex] objectForKey:@"user"]objectForKey:@"username"]];
        
        [currentCommentView.layer setZPosition:1000];
        self.currentCommentView = currentCommentView;
        
    }
    
}

- (IBAction)playPauseButtonPressed:(id)sender {
    
    // Hier noch überprüfen ob track schon geliked wurde oder nicht
    [UIView animateWithDuration:1.0
                          delay: 0
         usingSpringWithDamping: 0.4
          initialSpringVelocity: .5
                        options: 0
                     animations: ^
     {
         
         self.playButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
         self.playButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
     }
                     completion: nil
     ];
    
    [[SRPlayer sharedPlayer] togglePlayback];
}

-(void)unsubScribe{
    self.runTimeDetection = NO;
    [self pause];
}


/**
 *  Comment Stuff
 *
 */
-(void)setUpComments:(Track*)track {
    
    for (UIView * v in self.commentsView.subviews) {
        if (v != self.noCommentsLabel) {
            [v removeFromSuperview];
        }
    }
    
    [self.currentCommentViews removeAllObjects];
    
    [[SoundCloudAPI sharedApi]getCommentsOfTrack:track whenSuccess:^(NSURLSessionTask * task, id responseObject){
        NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
        NSMutableArray * array = [responseObject mutableCopy];
        for( int i = 0; i < [array count]; i ++ )
        {
            NSDictionary * comment = [array objectAtIndex:i];
            if ([[comment objectForKey:@"timestamp"]isKindOfClass:[NSNull class]]) {
                [indexes addIndex : i];
            }
            
        }
        [array removeObjectsAtIndexes:indexes];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        NSArray *sortedArray = [array sortedArrayUsingDescriptors:sortDescriptors];
        
        [self attachComments:sortedArray];
        self.currentComments = [sortedArray mutableCopy];
    }
    whenError:^(NSURLSessionTask* task, NSError * error){
        NSLog(@"Could not load Comments %@",error.localizedDescription);
    }];
}

-(void)attachComments:(NSArray *)comments {
    
    if ([comments count]) {
        self.noCommentsLabel.hidden = true;
        // Comments not sorted, so we have to do so
        dispatch_group_t commentgroup = dispatch_group_create();
        dispatch_group_wait(commentgroup, DISPATCH_TIME_FOREVER);
        dispatch_queue_t mainqueue = dispatch_get_main_queue();
        
        dispatch_queue_t uiUpdateQueue = dispatch_queue_create("AttachComments", NULL);
        dispatch_group_notify(commentgroup, uiUpdateQueue, ^{
            //[self commentsReady];
        });
        
        dispatch_group_async(commentgroup,uiUpdateQueue, ^{
            for (NSDictionary *comment in comments) {
                NSString * timeStamp = (NSString*)[comment objectForKey:@"timestamp"];
                
                // Bug OVER HERE SOMETIMES
                //float duration = CMTimeGetSeconds(self.currentAsset.duration); // we should use duration that soundcloud api returns and not something else
                float duration = [self.player.currentTrack.duration floatValue] / 1000;
                float widthOfWaveFormView = self.waveformView.layer.bounds.size.width;
                
                
                float xPosition = ((([timeStamp floatValue])/1000.0)/duration)*widthOfWaveFormView;
                
                // BUGAREA
                if (!isnan(xPosition)) {
                    
                    
                    // NAN BUG STILL EXISTS
                    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(xPosition,0, 1, 60)];
                    view.backgroundColor = [UIColor whiteColor];
                    [[self currentCommentViews]addObject:view];
                    
                    dispatch_group_async(commentgroup,mainqueue, ^{
                        [self.commentsView addSubview:view];
                        
                    });
                }
            }
        });
    }
    
    else {
        self.noCommentsLabel.hidden = false;
    }

}

/*********************************************************************************
Detects runtime Biatch
 *********************************************************************************/
-(void) startRunTimeDetection {
    
    __block float duration;
    __block float currentTime;
    __block float availableDuration;
    
    dispatch_queue_t uiUpdateQueue = dispatch_queue_create("PlayerUpdater", NULL);
    dispatch_async(uiUpdateQueue, ^{
        while (self.runTimeDetection) {
            
            
            
            
            [NSThread sleepForTimeInterval:0.2f];
            duration = CMTimeGetSeconds([self.player durationOfCurrentItem]);
            currentTime = CMTimeGetSeconds(self.player.currentTime);
            
            // Update Layer
            
            float prozentual = (float)(currentTime/ duration);
            CGRect newFrame = CGRectMake(self.waveformView.layer.bounds.size.width * prozentual,0 ,2 ,70);
            
            // Calculate buffering Width
            availableDuration = [self.player availableDuration];
            float  prozentualBuffering = (float)(availableDuration/duration);
            CGFloat widthOfBufferingSzone = (self.waveformView.frame.size.width * (1.0-prozentualBuffering)) ;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                @try {
                    // Update Buffering zone
                    if (!self.bufferingSzone) {
                        self.bufferingSzone = [[UIView alloc]initWithFrame:CGRectMake(self.waveformView.frame.origin.x, self.waveformView.frame.origin.y-2,widthOfBufferingSzone, 2)];
                        self.bufferingSzone.backgroundColor = [SRStylesheet mainColor];
                        self.bufferingSzone.userInteractionEnabled =NO;
                        self.waveformView.layer.zPosition = 200;
                        self.bufferingSzone.layer.zPosition = 100;
                        [self.contentViewofVisualEffectView addSubview:self.bufferingSzone];

                    } else {
                        self.bufferingSzone.frame = CGRectMake(self.waveformView.frame.size.width-widthOfBufferingSzone, self.waveformView.frame.origin.y-2,widthOfBufferingSzone, 2);
                    };
                } @catch(NSException *exception) {
                    // Do something
                }

                
                // Setze das Zeit label
                
                NSUInteger h_current = (NSUInteger)currentTime / 3600;
                NSUInteger m_current = ((NSUInteger)currentTime / 60) % 60;
                NSUInteger s_current = (NSUInteger)currentTime % 60;
                
                NSUInteger h_duration = (NSUInteger)duration / 3600;
                NSUInteger m_duration= ((NSUInteger)duration/ 60) % 60;
                NSUInteger s_duration = (NSUInteger)duration % 60;
                
                NSString *formattedCurrent;
                NSString *formattedDuration;
                if (h_duration == 0) {
                    formattedCurrent = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)m_current, (unsigned long)s_current];
                    formattedDuration = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)m_duration, (unsigned long)s_duration];
                } else {
                    formattedCurrent = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)h_current, (unsigned long)m_current, (unsigned long)s_current];
                    formattedDuration = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)h_duration, (unsigned long)m_duration, (unsigned long)s_duration];
                }
                
                self.expiredLabel.text = [NSString stringWithFormat:@"%@",formattedCurrent];
                self.durationLabel.text = [NSString stringWithFormat:@"%@",formattedDuration];

                NSMutableArray * keys = [[NSMutableArray alloc]init];
                NSMutableArray * values = [[NSMutableArray alloc]init];
                
                [keys addObject:MPMediaItemPropertyPlaybackDuration];
                [values addObject:[NSNumber numberWithFloat:duration]];
                
                [keys addObject:MPNowPlayingInfoPropertyElapsedPlaybackTime];
                [values addObject:[NSNumber numberWithFloat:currentTime]];

                if (self.player.currentTrack.title) {
                    [keys addObject:MPMediaItemPropertyTitle];
                    [values addObject:self.player.currentTrack.title];
                }
                if (self.player.currentTrack.user.username) {
                    [keys addObject:MPMediaItemPropertyArtist];
                    [values addObject:self.player.currentTrack.user.username];
                }
                if (true) {
                    MPMediaItemArtwork * image = nil;
                    if (self.artworkImage) {
                        image  =  [[MPMediaItemArtwork alloc]initWithImage:self.artworkImage];
                    } else {
                        image = [[MPMediaItemArtwork alloc]initWithImage:[UIImage imageNamed:@"music"]];
                    }
                    [keys addObject: MPMediaItemPropertyArtwork];
                    [values addObject:image];
                }

                
                NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                //CLS_LOG(@"Media Info %@", mediaInfo);
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
                
                @try {
                    [self.scrollBar setFrame:newFrame];
                    [[MiniPlayer sharedMiniPlayer].scrollbarMiniPlayer setFrame:CGRectMake(0, 0, [MiniPlayer sharedMiniPlayer].layer.bounds.size.width * prozentual, 2)];
                } @catch(NSException *exception) {
                    // Do something
                }
            }); // dispatch Block
        }
        
    });
}

- (void)tappedWaveform:(UITapGestureRecognizer *)recognizer {

    if (self.player.streamingStatus == AVPlayerItemStatusReadyToPlay) {
        
        [self.loadingIndicator startAnimating];
        self.runTimeDetection = false;
        CGPoint location = [recognizer locationInView:[recognizer.view superview]];
        CGFloat width = self.waveformView.layer.bounds.size.width;
        float prozentual = (float)(location.x / width);
        CGRect newFrame = CGRectMake(0, -3, self.waveformView.layer.bounds.size.width * prozentual, self.scrollBar.layer.bounds.size.height);
        
        [self.scrollBar setFrame:newFrame];
        float secondsOfTrack = CMTimeGetSeconds(([self.player durationOfCurrentItem]));
        float timeAfterScrub = prozentual * secondsOfTrack;
        [self.player seekToTime:CMTimeMake((int)timeAfterScrub, 1) completionHandler:^(BOOL finished){
            self.runTimeDetection = true;
            [self startRunTimeDetection];
            [self.loadingIndicator stopAnimating];
        }];

    }
    
}

- (void)pannedWaveform:(UIPanGestureRecognizer *)recognizer {
    
    if (self.player.streamingStatus == AVPlayerItemStatusReadyToPlay) {
        
        self.runTimeDetection = false;
        CGPoint location = [recognizer locationInView:[recognizer.view superview]];
        CGFloat width = self.waveformView.layer.bounds.size.width;
        float prozentual = (float)(location.x / width);
        CGRect newFrame = CGRectMake(self.waveformView.layer.bounds.size.width * prozentual, 0, 2, self.scrollBar.layer.bounds.size.height);
        
        [self.scrollBar setFrame:newFrame];
        float secondsOfTrack = CMTimeGetSeconds([self.player durationOfCurrentItem]);
        float timeAfterScrub = prozentual * secondsOfTrack;
        
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self.loadingIndicator startAnimating];
            [self.player seekToTime:CMTimeMake((int)timeAfterScrub, 1) completionHandler:^(BOOL finished){
                    self.runTimeDetection = true;
                    [self startRunTimeDetection];
                    [self.loadingIndicator stopAnimating];
            }];
        }
    
    }
    
}

// Like and dislike stuff
-(IBAction)favButtonPressed:(id)sender{
    [self.likeButton setEnabled:NO];
    // Hier noch überprüfen ob track schon geliked wurde oder nicht
    [UIView animateWithDuration:1.0
                          delay: 0
         usingSpringWithDamping: 0.4
          initialSpringVelocity: .5
                        options: 0
                     animations: ^
     {
         
         self.likeButton.transform = CGAffineTransformMakeScale(0.2, 0.2);
         self.likeButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
     }
                     completion: nil
     ];
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
    
    if (self.liked) {
        
        [[SoundCloudAPI sharedApi]removeTrack:self.player.currentTrack fromFavoritesForUserWithAccessToke:[SRAuthenticator sharedAuthenticator].authToken whenSuccess:^(NSURLSessionTask * task, id responseObject){
            FAKIonIcons *cogIcon = [FAKIonIcons iosHeartOutlineIconWithSize:likeButtonFontSize];
            cogIcon.iconFontSize = likeButtonFontSize;
            [cogIcon addAttribute:NSForegroundColorAttributeName value:[SRStylesheet whiteColor]];
            UIImage *heartImage = [cogIcon imageWithSize:CGSizeMake(likeButtonFontSize, likeButtonFontSize)];
            [self.likeButton setImage:heartImage forState:UIControlStateNormal];
            [self.likeButton setEnabled:YES];
            self.liked = NO;
            NSLog(@"DISLIKED");
        } whenError:^(NSURLSessionTask* task, NSError * error){
            [self.likeButton setEnabled:YES];

        }];

    } else {
        
        [[SoundCloudAPI sharedApi]addTrack:self.player.currentTrack toFavoritesForUserWithAccessToke:[SRAuthenticator sharedAuthenticator].authToken whenSuccess:^(NSURLSessionTask * task, id responseObject){
            FAKIonIcons *cogIcon = [FAKIonIcons iosHeartIconWithSize:likeButtonFontSize];
            cogIcon.iconFontSize = likeButtonFontSize;
            [cogIcon addAttribute:NSForegroundColorAttributeName value:[SRStylesheet redColor]];
            UIImage *heartImage = [cogIcon imageWithSize:CGSizeMake(likeButtonFontSize, likeButtonFontSize)];
            [self.likeButton setImage:heartImage forState:UIControlStateNormal];
            [self.likeButton setEnabled:YES];
            self.liked = YES;
            NSLog(@"LIKED");
        } whenError:^(NSURLSessionTask* task, NSError * error){
            [self.likeButton setEnabled:YES];

        }];
    }
}

-(void)showNext:(id)sender {
    [self performSegueWithIdentifier:@"showNext" sender:self];
}

- (IBAction)lastTrackButtonPressed:(id)sender {
    if (self.activityView) {
        [self.activityView removeFromSuperview];
    }
    
    self.coverImageView.image = nil;
    self.activityView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallClipRotate  tintColor:[UIColor whiteColor] size:50.0f];
    self.activityView.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    self.activityView.center = self.coverImageView.center;
    [self.coverImageView addSubview:self.activityView];
    [self.activityView startAnimating];
    
    [UIView animateWithDuration:1.0
                          delay: 0
         usingSpringWithDamping: 0.4
          initialSpringVelocity: .5
                        options: 0
                     animations: ^
     {
         
         self.lastTrackButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
         self.lastTrackButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
     }
                     completion: nil
     ];
    
    [self.player playLastTrack];
    
    
}
- (IBAction)nextTrackButtonPressed:(id)sender {
    if (self.activityView) {
        [self.activityView removeFromSuperview];
    }
    
    self.coverImageView.image = nil;
    self.activityView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallClipRotate  tintColor:[UIColor whiteColor] size:50.0f];
    self.activityView.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    self.activityView.center = self.coverImageView.center;
    [self.coverImageView addSubview:self.activityView];
    [self.activityView startAnimating];
    
    [UIView animateWithDuration:1.0
                          delay: 0
         usingSpringWithDamping: 0.4
          initialSpringVelocity: .5
                        options: 0
                     animations: ^
     {
         
         self.nextTrackButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
         self.nextTrackButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
     }
                     completion: nil
     ];
    
    [self.player playNextTrack];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showCommentsSegue"]) {
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSNumber * isEnabled  =     [defaults objectForKey:@"SoundrocketPro"];
        if (isEnabled) {
            UINavigationController * nav = (UINavigationController*)segue.destinationViewController;
            SRCommentsViewController * dc = (SRCommentsViewController*)nav.viewControllers.firstObject;
            dc.delegate = self;
            dc.currentTrack = self.player.currentTrack;
        } else {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"This Feature is just available for Soundrocket PRO User", nil) message:NSLocalizedString(@"PRO_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * showAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Tell me more", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
                __weak __block __typeof(self) weakself = self;

                [self dismissViewControllerAnimated:YES completion:^(){
                    [weakself.delegate playerViewControllerDidDismissForProPlan:weakself];
                }];
                
            }];
            UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){
            }];
            [alertController addAction:showAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else  if ([segue.identifier isEqualToString:@"showTracksOfPlaylist"]) {
        SRPlaylistTracksController * dc = (SRPlaylistTracksController*)segue.destinationViewController;
        if ([sender class] == [Playlist class]) {
            Playlist * list = (Playlist*)sender;
            list.tracks_uri = [list.uri stringByAppendingString:@"/tracks"];
            dc.currentPlaylist = list;
        }
    } else if ([segue.identifier isEqualToString:@"showNext"]) {
        SRWhatsNextViewController * cvc = (SRWhatsNextViewController*)(((UINavigationController*)segue.destinationViewController).viewControllers.firstObject);
        cvc.title = @"Next";
        cvc.delegate = self;
        cvc.requestModel = [SRPlayer sharedPlayer].model;
        [cvc.requestModel addDelegate:cvc];
    }
}
- (IBAction)showVolumeFaceButtonPressed:(id)sender {
        if (self.volumeViewActive) {
            [self hideVolumeView];
        }
        else {
            [self showVolumeFaderView];
        }

}

-(void)showVolumeFaderView{
    self.bottomVolumeFaderConstraint.constant = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [self.volumeControlView layoutIfNeeded];
    self.volumeViewActive = YES;
    [UIView commitAnimations];
}
-(IBAction)hideVolumeView{
    self.volumeViewActive = NO;
    self.bottomVolumeFaderConstraint.constant = -50;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [self.volumeControlView layoutIfNeeded];
    [UIView commitAnimations];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        /* Reorganize views, or move child view controllers */
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.suggestionCollectionView reloadData];
    }];
}

#pragma mark -options menu

-(void)setupOptionsMenu {
    self.containerView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHideOptionsMenu:)];
    [self.containerView addGestureRecognizer:tapGesture];
}

-(void)showOrHideOptionsMenu:(id)sender {
    [UIView transitionWithView:self.containerView
                      duration:0.2
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        // Show optionsmenu
                        if (self.optionsView.hidden) {
                            self.optionsView.hidden = NO;
                            self.coverImageView.hidden = YES;
                            self.likeButton.hidden = NO;
                            
                        } else {
                            self.optionsView.hidden = YES;
                            self.coverImageView.hidden = NO;
                            self.likeButton.hidden = YES;
                            
                        }
                    }
                    completion:^(BOOL success){
                        
                    }];
}


#pragma mark - RequestModel
-(void)requestModelDidFailWithLoading:(SRRequestModel *)requestModel withError:(NSError *)error {
    
}

-(void)requestModelDidFinishLoading:(SRRequestModel *)requestModel {
    [self.suggestionCollectionView reloadData];
}

-(void)requestModelDidStartLoading:(SRRequestModel *)requestModel {
    
}

-(void)setRequestModel:(SRRequestModel *)requestModel {
    if (_requestModel != requestModel) {
        [self.requestModel removeDelegate:self];
        _requestModel = requestModel;
        [_requestModel addDelegate:self];
        [self.suggestionCollectionView reloadData];
    }
}
#pragma mark - CollectionViewDelegate and Datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.requestModel) {
        if (self.requestModel.justTracksAndReposts.count > 1) {
            return self.requestModel.justTracksAndReposts.count;
        }
        return 0;
    } else {
        if ([SRPlayer sharedPlayer].upNext.count > 1) {
            return [SRPlayer sharedPlayer].upNext.count;
        }
        return 0;
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    id trackOrPlaylist = nil;
    if (self.requestModel) {
        if (indexPath.row == self.requestModel.justTracksAndReposts.count-1) {
            [self.requestModel load];
        }
        trackOrPlaylist = [self.requestModel.results objectAtIndex:indexPath.row];
    } else {
        trackOrPlaylist = [[SRPlayer sharedPlayer].upNext objectAtIndex:indexPath.row];
    }
    
    SuggestionCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"suggestionCell" forIndexPath:indexPath];
    cell.object = trackOrPlaylist;
    cell.delegate = self;
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak __block __typeof(self) weakself = self;
    [[SRPlayer sharedPlayer] setPlayingIndex:[NSIndexPath indexPathForItem:indexPath.row inSection:0]];
    id object = [self.requestModel.results objectAtIndex:indexPath.row];
    if (self.requestModel) {
        if ([object isKindOfClass:[Track class]]) {
            if (self.activityView) {
                [self.activityView removeFromSuperview];
            }
            
            self.coverImageView.image = nil;
            self.activityView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallClipRotate  tintColor:[UIColor whiteColor] size:50.0f];
            self.activityView.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
            self.activityView.center = self.coverImageView.center;
            [self.coverImageView addSubview:self.activityView];
            [self.activityView startAnimating];
            [[SRPlayer sharedPlayer] setCurrentTrack:object];
        } else if ([object isKindOfClass:[TrackRepost class]]) {
            self.coverImageView.image = nil;
            self.activityView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallClipRotate  tintColor:[UIColor whiteColor] size:50.0f];
            self.activityView.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
            self.activityView.center = self.coverImageView.center;
            [self.coverImageView addSubview:self.activityView];
            [self.activityView startAnimating];
            Track * track = [[Track alloc]initWithTrackRespost:[self.requestModel.results objectAtIndex:indexPath.row]];
            [[SRPlayer sharedPlayer] setCurrentTrack:track];
        } else if ([object isKindOfClass:[Playlist class]]) {
            [self dismissViewControllerAnimated:YES completion:^(){
                [weakself.delegate playerViewControllerDidDismissWithPlaylist:object];
            }];
        } else if ([object isKindOfClass:[PlaylistRepost class]]) {
            Playlist * list = [[Playlist alloc]initWithPlayListRepost:object];
            [self dismissViewControllerAnimated:YES completion:^(){
                [self.delegate playerViewControllerDidDismissWithPlaylist:list];
            }];
            
        }
    } else {
        [[SRPlayer sharedPlayer] setCurrentTrack:[[SRPlayer sharedPlayer].upNext objectAtIndex:indexPath.row]];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(self.suggestionCollectionView.frame.size.width/4, self.suggestionCollectionView.frame.size.height);
    } else {
        return CGSizeMake(self.suggestionCollectionView.frame.size.width/2, self.suggestionCollectionView.frame.size.height);
    }
}

- (void)dealloc
{
    [self.requestModel removeDelegate:self];
}

-(IBAction)closeCommentingView:(id)sender {
    self.commentView.hidden = YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - BasictracktableViewCellDelegate
-(void)userButtonPressedWithUser:(User *)user{
    [self dismissViewControllerAnimated:YES completion:^(){
        [self.delegate playerViewControllerDidDismissWithUser:user];
    }];
}


-(void)setupStatsLabelWithTrack:(Track*)track {
    FAKIonIcons *playIcon = [FAKIonIcons playIconWithSize:10];
    NSMutableAttributedString * playbackcount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.playback_count integerValue]]];
    [playbackcount appendAttributedString:[playIcon attributedString]];
    
    FAKIonIcons *likeIcon = [FAKIonIcons heartIconWithSize:10];
    NSMutableAttributedString * likecount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.favoritings_count integerValue]]];
    [likecount appendAttributedString:[likeIcon attributedString]];
    
    FAKIonIcons *commentIcon = [FAKIonIcons chatboxIconWithSize:10];
    NSMutableAttributedString * commentCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.comment_count integerValue]]];
    [commentCount  appendAttributedString:[commentIcon attributedString]];
    
    [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
    [playbackcount appendAttributedString:likecount];
    [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
    [playbackcount appendAttributedString:commentCount];
    
    if (track.reposts_count) {
        FAKFontAwesome *repostIcon = [FAKFontAwesome retweetIconWithSize:10];
        NSMutableAttributedString * repostCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.reposts_count integerValue]]];
        [repostCount appendAttributedString:[repostIcon attributedString]];
        [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
        [playbackcount appendAttributedString:repostCount];
    }
    
    self.statsLabel.attributedText = playbackcount;
}

#pragma mark - Options Dialog

-(IBAction)optionsButtonPressed:(id)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Options" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction * showNext = [UIAlertAction actionWithTitle:@"Show Next" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        [self performSegueWithIdentifier:@"showNext" sender:nil];
    }];
    
    [alertController addAction:showNext];
    
    UIAlertAction * showPeople = [UIAlertAction actionWithTitle:@"Show Favoriters" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        [self dismissViewControllerAnimated:YES completion:^(){
            [self.delegate playerViewControllerDidDismissWithTrackForFavoriters:[[SRPlayer sharedPlayer].currentTrack copy]];
        }];
    }];
    
    [alertController addAction:showPeople];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - CommentsViewController Delegate 
-(void)commentsViewControllerDidDismissWithUser:(User *)user {
    [self.navigationController dismissViewControllerAnimated:YES completion:^(){
        [self.delegate playerViewControllerDidDismissWithUser:user];
    }];
}

#pragma mark - Whats next delegate
-(void)nextControllerDidSelectPlaylist:(Playlist *)playlist {
    [self.navigationController dismissViewControllerAnimated:YES completion:^(){
        [self.delegate playerViewControllerDidDismissWithPlaylist:playlist];
    }];
}
@end
