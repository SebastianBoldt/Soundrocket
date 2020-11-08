//
//  ClientIDTableViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 20.06.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STTweetLabel.h>
@interface ClientIDTableViewController : UITableViewController
@property (nonatomic,strong) IBOutlet UITextField * clientTextField;
@property (nonatomic,strong) IBOutlet STTweetLabel * linkLabel;
@property (nonatomic,strong) IBOutlet UILabel * yourAppsLabel;
@property (nonatomic,strong) IBOutlet UILabel * pasteLabel;
@property (nonatomic,strong) IBOutlet UIButton * saveClientIDButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;


-(IBAction)saveClientIDPressed:(id)sender;
@end
