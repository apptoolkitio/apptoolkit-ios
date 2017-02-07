//
//  RootViewController.swift
//  AppToolkitSampleSwift
//
//  Created by Rizwan Sattar on 7/23/15.
//  Copyright (c) 2015 Cluster Labs, Inc. All rights reserved.
//

import UIKit
import AppToolkit

enum FirstLaunchUI {
    case releaseNotes
    case ratingPrompt
}

class RootViewController: UIViewController {

    @IBOutlet weak var showAppReleaseNotesButton: UIButton!

    let firstLaunchUI = FirstLaunchUI.ratingPrompt

    override func viewDidLoad() {
        super.viewDidLoad()
        ATKUIManifestRefreshed { () -> Void in
            // If App Release Notes are not available, disable the button
            self.showAppReleaseNotesButton.enabled = AppToolkit.sharedInstance().appReleaseNotesAvailable()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        switch firstLaunchUI {
        case .releaseNotes:
            AppToolkit.sharedInstance().presentAppReleaseNotesIfNeededFromViewController(self) { (success) -> Void in
                print("Release notes finished with success: \(success)")
            }
        case .ratingPrompt:
            AppToolkit.sharedInstance().presentAppRatingPromptIfNeededFromViewController(self) { (didPresent, flowResult) -> Void in
                print("App rating prompt finished with flow result: \(NSStringFromViewControllerFlowResult(flowResult))")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onShowAppReleaseNotesButtonTriggered(sender: UIButton) {
        AppToolkit.sharedInstance().forcePresentationOfAppReleaseNotesFromViewController(self) { (success) -> Void in
            print("Release notes shown on demand, finished with success: \(success)")
        }
    }
}

