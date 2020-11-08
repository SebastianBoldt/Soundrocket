//
//  LoginTableViewController.swift
//  Soundrocket
//
//  Created by Sebastian Boldt on 13.02.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

import UIKit

class LoginTableViewController: UITableViewController, SRAuthenticatorDelegate {

    @IBOutlet weak var emailTextField               : UITextField!
    @IBOutlet weak var passWordTextField            : UITextField!
    @IBOutlet weak var loginButton                  : UIButton!
    @IBOutlet weak var loginWithFacebookButton      : UIButton!
    @IBOutlet weak var activityIndicatorLoggingIn   : UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorFacebook    : UIActivityIndicatorView!
    @IBOutlet weak var soundrocketNameLabel         : UILabel!
    @IBOutlet weak var poweredByLabel               : UILabel!
    @IBOutlet weak var loginButtonBackgroundView    : UIView!

    
    // MARK : Private actions 
    
    @IBAction func loginButtonPressed(_ sender:AnyObject?) {
        
        if self.emailTextField.hasText || self.passWordTextField.hasText {
            
            self.loginButton.isHidden = true
            self.loginButton.isHidden = false
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.activityIndicatorLoggingIn.startAnimating()
            
            SRAuthenticator.shared().authenticateUser(forEmailOrUsername: self.emailTextField.text, andPassword: self.passWordTextField.text)

        } else {
            
            let errorString = NSLocalizedString("Please enter email and password first", comment: "")
            SVProgressHUD.showError(withStatus: errorString)
            self.restoreUI()
        }
    }
    
    @IBAction func loginWithFacebook(){
        self.loginWithFacebookButton.isHidden = true
        self.loginWithFacebookButton.isEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.activityIndicatorFacebook.startAnimating()
        
        let loginURL = "https://soundcloud.com/connect?client_id=3ceea65b3d83ab630bc818ce1d179a82&response_type=code"
        let redirectURL = "soundrocket://soundcloud/callback"
        let loginNav = SoundCloudLoginWebViewController.instantiate(withLoginURL: loginURL, redirectURL: redirectURL, resultBlock:
            {
                (result: Bool,code :String?) in
                
                if let unwrappedCode = code {
                    SRAuthenticator.shared().authenticate(usingCode: unwrappedCode)
                } else {
                    SRHelper.showGeneralError()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.activityIndicatorFacebook.stopAnimating()
                    self.loginWithFacebookButton.isEnabled = true
                    self.loginWithFacebookButton.isHidden = false
                }
        })
        
        
        self.present(loginNav!, animated: true, completion: nil)
    }
    

    
    // MARK : NSObject
    
    deinit {
        SRAuthenticator.shared().removeDelegate(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK : UITableViewController
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // Dirty iPad Fix
        if (indexPath.row == 0) {
            cell.backgroundColor = UIColor.clear
        }
    }
    
    // MARK : UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        SRAuthenticator.shared().add(self);

        // Configuring the Login Button
        
        let loginButtonTitle = NSLocalizedString("sign in with SoundCloud", comment:"sign in title")
        
        self.loginButton.setTitleColor(SRStylesheet.mainColor(), for:.normal)
        self.loginButton.setTitle(loginButtonTitle, for: UIControl.State())
        self.loginButton.backgroundColor = UIColor.clear
        
        // Configure Facebook Button
        
        let loginWithFacebookButtonTitle = NSLocalizedString("sign in with Facebook", comment:"facebook sign in")
        self.loginWithFacebookButton.setTitle(loginWithFacebookButtonTitle, for: UIControl.State())
        
        self.emailTextField.placeholder = NSLocalizedString("email",comment: "email placeholder")
        self.passWordTextField.placeholder = NSLocalizedString("password", comment:"email placeholder")
        
        
        // Configuring Table View
        
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.isOpaque = false
        let backgroundImageView = UIImageView(image: UIImage(named:"background-image.png"))
        backgroundImageView.contentMode = .scaleAspectFill
        self.tableView.backgroundView = backgroundImageView
        
        // Setup Logo
        
        let attributes : [NSAttributedString.Key : AnyObject]? = [
            NSAttributedString.Key.font : UIFont(name: "Helvetica-Bold", size: 50)!,
            NSAttributedString.Key.foregroundColor : SRStylesheet.mainColor(),
            NSAttributedString.Key.kern : -4.0 as AnyObject]
        
        let attributedSoundrocketLogoString = NSAttributedString(string: "Soundrocket", attributes: attributes)

        
        self.soundrocketNameLabel.attributedText = attributedSoundrocketLogoString;
        self.poweredByLabel.textColor = SRStylesheet.whiteColor()
        self.loginButtonBackgroundView.backgroundColor = UIColor.clear
    
    }
    
    // MARK : SRAuthenticatorDelegate
    
    func authenticatorDidAuthenticate(_ authenticator: SRAuthenticator!, with user: User!) {
        self.restoreUI()
    }
    
    func authenticator(_ authenticator: SRAuthenticator!, didNotAuthenticateWithError error: Error!) {
        self.restoreUI()
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
    
    // MARK : Helper
    
    func restoreUI() {
        self.activityIndicatorLoggingIn.stopAnimating();
        self.activityIndicatorFacebook.stopAnimating();
        self.loginButton.isHidden = false;
        self.loginWithFacebookButton.isHidden = false;
        UIApplication.shared.isNetworkActivityIndicatorVisible = false;
    }
    
}
