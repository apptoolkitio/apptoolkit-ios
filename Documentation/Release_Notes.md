<p align="center"><img src="https://s3.amazonaws.com/images.1776productions.com/apptoolkit/images/onboardingicon.png" width="100" alt="AppToolkit Cloud Config Logo"/></p>

# AppToolkit Release Notes

### Step 1: Install and Configure AppToolkit iOS SDK

If it is not already, [install the AppToolkit iOS SDK](https://github.com/apptoolkitio/apptoolkit-ios/blob/master/README.md) in your app.



### Step 2: Show Your Release Notes Card

A good time to show the card is after the user logs in, on the main screen of the application, in `viewDidAppear`.

Swift:

```
import AppToolkit

...
override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    AppToolkit.sharedInstance().presentAppReleaseNotesIfNeededFromViewController(self) { (didPresent) -> Void in
        if didPresent {
            print("Woohoo, we showed the release notes card!")
        }
    }
}
```

Objective C:

```
#import <AppToolkit/AppToolkit.h>

...
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AppToolkit sharedInstance] presentAppReleaseNotesIfNeededFromViewController:self completion:^(BOOL didPresent) {
        if (didPresent) {
            NSLog(@"Woohoo, we showed the release notes card!");
        }
    }];
}
```

That's pretty much it! AppToolkit will show you release notes in your app if:

* You _have_ release notes available for this particular version of your app, and
* You _haven't_ shown those release notes before, on that device.

#### Debugging
If you'd like to _always_ present the release notes card (ignoring whether AppToolkit has shown them before, while debugging), you can set a debug flag:

Swift:

```
AppToolkit.sharedInstance().debugAlwaysPresentAppReleaseNotes = true
```

Objective C:

```
[AppToolkit sharedInstance].debugAlwaysPresentAppReleaseNotes = YES;
```

---
#### Author

AppToolkit, Inc., info@apptoolkit.io

#### License

AppToolkit is available under the Apache 2.0 license. See the LICENSE file for more info.
