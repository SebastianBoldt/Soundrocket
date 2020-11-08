//
//  AppDelegate_SWIFT.swift
//  Soundrocket
//
//  Created by Sebastian Boldt on 05.09.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

import UIKit
import Crashlytics

class AppDelegate: UIResponder, UIApplicationDelegate, SRAuthenticatorDelegate {

    var window: UIWindow?
    var mockModeEnabled : Bool = false
    
    internal var rootController : SRTabbarViewController?
    
    // MARK: Application Delegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if (ProcessInfo.processInfo.arguments.contains("enableMockupMode")){
            
            // enable soundrocket pro
            let defaults = UserDefaults.standard;
            defaults.set(NSNumber(value: true as Bool), forKey: "SoundrocketPro");
            defaults.synchronize()
            
            URLProtocol.registerClass(SRMockURLProtocol.self)
            self.mockModeEnabled = true
        }
        
        if (ProcessInfo.processInfo.arguments.contains("shouldLogout")){
            SRAuthenticator.shared().logout()
        }

        
        #if !DEBUG
           Fabric.with([Crashlytics()])
        #endif
            
        JSONModel.setGlobalKeyMapper(JSONKeyMapper(dictionary: ["description":"descriptionText"]))
        let sharedApi : SoundCloudAPI =  SoundCloudAPI.shared();
        sharedApi.clientSecret = Constants.SoundCloud.SoundcloudClientSecret;
        sharedApi.clientID = Constants.SoundCloud.SoundcloudClientID;
        
        SRAuthenticator.shared().add(self)
        
        let settings : UIUserNotificationSettings = UIUserNotificationSettings(types: [.sound,.alert,.badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        
        iRate.sharedInstance().daysUntilPrompt = 5
        iRate.sharedInstance().usesUntilPrompt = 15
        
        self.setupMixPanel()
        self.setupUI()
        self.setupAudioPlayback()
        self.setFirstViewController()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        
        SRTweakHelper().setupTweaks()
        
        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        /*if (SRAuthenticator.sharedAuthenticator().handleURL(url)) {
            return true;
        }*/
        return true;
    }
    
    @objc
    func getRoot()->SRTabbarViewController {
        return rootController!;
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Remote Notification Handling
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: SRAuthenticatorDelegate
    func authenticatorDidAuthenticate(_ authenticator: SRAuthenticator, with user: User) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let root: SRTabbarViewController = storyBoard.instantiateViewController(withIdentifier: "SRTabbarController") as! SRTabbarViewController
        self.rootController = root;
        self.flipToViewController(root)
        self.setupSupportKit()
    }
    
    func authenticator(_ authenticator: SRAuthenticator!, didNotAuthenticateWithError error: Error!) {
        let currentVC = self.window?.rootViewController;
        guard !(currentVC is LoginTableViewController) else {
            return
        }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootLogin : UIViewController?;
        rootLogin = storyBoard.instantiateViewController(withIdentifier: "Login")
  
        self.window!.rootViewController = rootLogin
        SRHelper.showGeneralError()
    }
    
    func authenticatorDidLogout(_ authenticator: SRAuthenticator) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var rootLogin: UIViewController? = nil
        rootLogin = storyboard.instantiateViewController(withIdentifier: "Login")
        self.flipToViewController(rootLogin!)
    }
    
    // MARK: Helper
    
    func setFirstViewController() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if SRAuthenticator.shared().isLoggedIn {
            let rootLogin: UIViewController = storyBoard.instantiateViewController(withIdentifier: "loggingIn")
            self.window!.rootViewController = rootLogin
            SRAuthenticator.shared().getUserData()
        }
        else {
            let rootLogin : UIViewController?;
            rootLogin = storyBoard.instantiateViewController(withIdentifier: "Login")
            self.window!.rootViewController = rootLogin
        }
    }
    
    func flipToViewController(_ newRoot: UIViewController) {
        UIView.transition(from: self.window!.rootViewController!.view, to: newRoot.view, duration: 0.65, options:[UIView.AnimationOptions.curveEaseIn], completion:
            {(finished: Bool) in  self.window!.rootViewController = newRoot })
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event!.type == UIEvent.EventType.remoteControl {
            if event?.subtype == UIEvent.EventSubtype.remoteControlPlay {
                SRPlayer.shared().play()
            } else if event?.subtype == UIEvent.EventSubtype.remoteControlPause {
                SRPlayer.shared().pause()
            } else if event?.subtype == UIEvent.EventSubtype.remoteControlPlay {
                SRPlayer.shared().play()
            } else if event?.subtype == UIEvent.EventSubtype.remoteControlNextTrack {
                SRPlayer.shared().playNextTrack()
            } else if event?.subtype == UIEvent.EventSubtype.remoteControlPreviousTrack {
                SRPlayer.shared().playLastTrack()
            } else if event?.subtype == UIEvent.EventSubtype.remoteControlTogglePlayPause {
                if(SRPlayer.shared().rate() == 0.0){
                    SRPlayer.shared().play()
                } else {
                    SRPlayer.shared().pause()
                }
            }
        }
    }
    
    // MARK: Setup Methods
    
    func setupUI() {
        
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)

        let dic = ProcessInfo.processInfo.environment
        if dic["DEBUG"] != nil {
            self.window = FBTweakShakeWindow(frame: (UIScreen.main.bounds).insetBy(dx: 2,dy: 2))
        } else {
            self.window = UIWindow(frame: UIScreen.main.bounds.insetBy(dx: 2,dy: 2))
        }
        
        self.window?.layer.masksToBounds = true;
        self.window?.layer.cornerRadius = 8;
        self.window?.tintColor = SRStylesheet.mainColor()
        self.window?.frame = UIScreen.main.bounds
        self.window?.backgroundColor = SRStylesheet.whiteColor()
        
        SVProgressHUD.setForegroundColor(SRStylesheet.whiteColor())
        SVProgressHUD.setBackgroundColor(SRStylesheet.mainColor())
        
        let pageControl :UIPageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor =  SRStylesheet.darkGrayColor()
        pageControl.backgroundColor = UIColor.clear;
        pageControl.currentPageIndicatorTintColor = SRStylesheet.mainColor()
    }
    
    func setupMixPanel () {
        let mixpanel = Mixpanel.sharedInstance(withToken: Constants.Mixpanel.mixPanelToken)
        // Call .identify to flush the People record to Mixpanel
        mixpanel?.identify(mixpanel?.distinctId)
    }
    
    func setupAudioPlayback() {
        // Setup Audio Stuff for  App
        let audioSession : AVAudioSession = AVAudioSession.sharedInstance();
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.allowBluetooth)
            try audioSession.setActive(true)
        } catch {
            // handle error
        }
    }

    func setupSupportKit() {
        SupportKit.initWith(SKTSettings(appToken: Constants.SupportKit.supportKitToken))
        let name : String = SRAuthenticator.shared().currentUser.username
        SupportKit.setUserFirstName(name, lastName: name)
    }
    
}
