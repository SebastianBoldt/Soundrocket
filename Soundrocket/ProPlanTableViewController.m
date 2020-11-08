//
//  ProPlanTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 03.06.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "ProPlanTableViewController.h"
#import <FAKIonIcons.h>
#import "SRStylesheet.h"
#import <StoreKit/StoreKit.h>
#import <SVProgressHUD.h>
#import <FAKIonIcons.h>
@interface ProPlanTableViewController()<SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (strong, nonatomic) SKProduct *product;

@property (strong, nonatomic) NSString *productID;

@property (strong, nonatomic) SKProductsRequest * productRequest;

@end

@implementation ProPlanTableViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    [self.waveFormView setup];
    NSMutableAttributedString * crossIcon = [[[FAKIonIcons iosCloseIconWithSize:25]attributedString]mutableCopy];
    [crossIcon addAttributes:@{NSForegroundColorAttributeName:[SRStylesheet redColor]} range:NSMakeRange(0, 1)];
    
    __weak __block __typeof(self) weakself = self;

    [UIView animateWithDuration:1.0 delay:2.0 options:0 animations:^(){
        weakself.commentsEnabledLabel.attributedText = crossIcon;
        weakself.historyFunctionEnabledLabel.attributedText = crossIcon;
        weakself.bannerFunctionEnabledLabel.attributedText = crossIcon;
    }
                     completion:^(BOOL success){}];
    
    NSAttributedString *attributedString =
    [[NSAttributedString alloc]
     initWithString:@"PRO"
     attributes:
     @{
       NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-HeavyItalic" size:40],
       NSForegroundColorAttributeName : [SRStylesheet mainColor],
       NSKernAttributeName : @(-4.0f)
       }];
    
    self.soundrocketNameLabel.attributedText = attributedString;
    self.productID = @"SOUNDROCKET_PRO";
    
    [[SKPaymentQueue defaultQueue]
     addTransactionObserver:self];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * isEnabled  =     [defaults objectForKey:@"SoundrocketPro"];
    
    self.buyButton.hidden = YES;
    self.loadingView.hidden = NO;
    
    if ([isEnabled boolValue]) {
        [self setupButtonPurchased];
        [self setupLabelsPurchased:YES];
    
    } else {
        [self requestProducts];
    }
    
    [self setupNavigationbar];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(applicationDidBecomeActive:)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    self.commentsDescriptionLabel.text = NSLocalizedString(@"Read and write comments",nil);
    self.historyDescriptionLabel.text = NSLocalizedString(@"See your playback history",nil);
    self.bannerDescriptionLabel.text = NSLocalizedString(@"Remove Get PRO Banner",nil);

    //self.downloadDescriptionLabel.text = NSLocalizedString(@"Download downloadable Track", nil);
}

-(void)applicationDidBecomeActive:(id)sender {
    [self.waveFormView setup];
}

-(void)setupNavigationbar {
    UIView *backView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];// Here you can set View width and height as per your requirement for displaying titleImageView position in navigationbar
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    titleImageView.frame = backView.frame; // Here I am passing origin as (45,5) but can pass them as your requirement.
    [backView addSubview:titleImageView];
    //titleImageView.contentMode = UIViewContentModeCenter;
    self.navigationItem.titleView = backView;
}
-(void)setupLabelsPurchased:(BOOL)enabled {
    __weak __block __typeof(self) weakself = self;

    if (enabled) {
        NSMutableAttributedString * checkMark = [[[FAKIonIcons iosCheckmarkIconWithSize:25]attributedString]mutableCopy];
        [checkMark addAttributes:@{NSForegroundColorAttributeName:[SRStylesheet mainColor]} range:NSMakeRange(0, 1)];

        [UIView animateWithDuration:1.0 delay:2.0 options:0 animations:^(){
            weakself.commentsEnabledLabel.attributedText = checkMark;
            weakself.historyFunctionEnabledLabel.attributedText = checkMark;
            weakself.bannerFunctionEnabledLabel.attributedText = checkMark;
        }
                         completion:^(BOOL success){}];

    } else {
        NSMutableAttributedString * crossIcon = [[[FAKIonIcons iosCloseIconWithSize:25]attributedString]mutableCopy];
        [crossIcon addAttributes:@{NSForegroundColorAttributeName:[SRStylesheet redColor]} range:NSMakeRange(0, 1)];
        [UIView animateWithDuration:1.0 delay:2.0 options:0 animations:^(){
            weakself.commentsEnabledLabel.attributedText = crossIcon;
            weakself.historyFunctionEnabledLabel.attributedText = crossIcon;
            weakself.bannerFunctionEnabledLabel.attributedText = crossIcon;
        }
        completion:^(BOOL success){}];

    }

}
-(void)setupRestoreButton {
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStylePlain target:self action:@selector(restoreNoAdsUpgrade)];
}

-(void)setupButtonPurchased {
    NSMutableAttributedString * purchasedString = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"Active", nil)];
    NSMutableAttributedString * websiteIcon = [[[FAKIonIcons iosCheckmarkIconWithSize:14]attributedString]mutableCopy];
    [purchasedString appendAttributedString:websiteIcon];
    [purchasedString setAttributes:@{NSForegroundColorAttributeName:[SRStylesheet darkGrayColor]} range:NSRangeFromString([purchasedString string])];
    [self.buyButton setAttributedTitle:purchasedString forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.loadingView stopAnimating];
    self.buyButton.hidden = NO;
    self.buyButton.enabled = NO;

}
-(void)dealloc {
    
    if(self.productRequest) {
        self.productRequest.delegate = nil;
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)requestProducts {
    if ([SKPaymentQueue canMakePayments])
    {
        self.productRequest = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:self.productID]];
        self.productRequest.delegate = self;
        
        [self.productRequest start];
    }
    else
        [SVProgressHUD showErrorWithStatus:@"Please enable In App Purchase in Settings"];
}

- (IBAction)purchaseProPlan:(id)sender {
    [SVProgressHUD showWithStatus:@"Purchasing ..." maskType:SVProgressHUDMaskTypeBlack];
    SKPayment *payment = [SKPayment paymentWithProduct:_product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    
    if (products.count != 0)
    {
        // Product found, set things up here
        _product = products[0];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:self.product.priceLocale];
        NSString * currencyString = [formatter stringFromNumber:self.product.price];
        [self.buyButton setTitle:[NSString stringWithFormat:@"%@",currencyString] forState:UIControlStateNormal];
        self.buyButton.hidden = NO;
        [self.loadingView stopAnimating];
        [self setupRestoreButton];
        
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Something went wrong, please try again", nil)];
    }
    
    // NSlog errors
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products)
    {
        NSLog(@"Product not found: %@", product);
    }
}


#pragma mark SKPaymentTransactionObserver

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self unLockFeature];
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Something went wrong, please try again", nil)];
                [self setupLabelsPurchased:NO];
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                [self unLockFeature];
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

// Do the feature unlocking stuff
-(void)unLockFeature {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ProPurchased" object:nil];
    [self.waveFormView start];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Thank you for purchasing Soundrocket PRO", nil)];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"SoundrocketPro"];
    [defaults synchronize];
    [self setupButtonPurchased];
    [self setupLabelsPurchased:YES];
}

- (IBAction)restoreNoAdsUpgrade{
    [SVProgressHUD showWithStatus:@"Restoring ..." maskType:SVProgressHUDMaskTypeBlack];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

-(void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        //[self performSegueWithIdentifier:@"showCommentDescription" sender:nil];
    } else {
        //[self performSegueWithIdentifier:@"showHistoryDescription" sender:nil];
    }
}

@end
