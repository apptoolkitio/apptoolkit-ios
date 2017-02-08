<p align="center"><img src="https://s3.amazonaws.com/images.1776productions.com/apptoolkit/images/configicon.png" width="100" alt="AppToolkit Cloud Config Logo"/></p>

# AppToolkit Cloud Config Setup

### Step 1: Install and Configure AppToolkit iOS SDK

If it is not already, [install the AppToolkit iOS SDK](https://github.com/AppToolkitIO/apptoolkit-ios/blob/master/README.md) in your app.

### Step 2: Add Some Keys For Your App

AppToolkit Cloud Config works like a simple key-value system. [Go and add some config keys for your app on AppToolkit's website](https://apptoolkit.io/config/onboard).

### Step 3: Access Those Keys with the SDK

Replace hardcoded settings in your code with calls to access config using the AppToolkit SDK.

## Usage
AppToolkit Cloud Config allows you to store config as Booleans, Integers, Doubles, and Strings. Here are examples on what the code would look like:

### Booleans
# 
Use `ATKConfigBool(key, defaultValue)`

Swift:

```swift
let showGoogleLogin = ATKConfigBool("showGoogleLogin", false);
```

Objective C:

```objc
BOOL showGoogleLogin = ATKConfigBool(@"showGoogleLogin", NO);
```




### Integers
# 
Use `ATKConfigInteger(key, defaultValue)`

Swift:

```swift
let maxCharactersAllowed = ATKConfigInteger("maxCharactersAllowed", 400);
```

Objective C:

```objc
NSInteger maxCharactersAllowed = ATKConfigInteger(@"maxCharactersAllowed", 400);
```




### Doubles
# 
Use `ATKConfigDouble(key, defaultValue)`

Swift:

```swift
let maxVideoDuration = ATKConfigDouble("maxVideoDuration", 15.0);
```

Objective C:

```objc
NSTimeInterval maxVideoDuration = ATKConfigDouble(@"maxVideoDuration", 15.0);
```




### Strings
# 
Use `ATKConfigString(key, defaultValue)`

Swift:

```swift
let paymentProviderIdToUse = ATKConfigString("paymentProviderId", "stripe");
```

Objective C:

```objc
NSString *paymentProviderIdToUse = ATKConfigString(@"paymentProviderId", @"stripe");
```

## Default Values

Immediately upon app launch, AppToolkit will retrieve the current configuration for your app and store it on disk. It will also periodically ping the AppToolkit server for new config (such as when the app returns from the background).

There is always the unlikely chance that AppToolkit can't get the _any_ configuration. Each SDK call to read a config requires that you provide a **reasonable default value** for that key. This could be the value you previously had hard-coded. The default value is returned if (and only if) that configuration key is not available locally (i.e. config that includes the key was _never_ retrieved and persisted). If a cached value for that key is available, that is returned instead.

Since some form of configuration is always available locally, the SDK doesn't require a callback-based retrieval of each configuration value. You can simple access it using the methods above.

## Ready Handler

In some cases, you might want to update some settings at the launch (or very close to launch) of your app. For that, the SDK has the `ATKConfigReady(callback)` function. You can pass in an Objective C block or Swift closure:

Swift:

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    // Configure and start AppToolkit
    AppToolkit.launchWithToken(appToolkitToken)
    
    // Add ready-handler
    ATKConfigReady({
        print("Config is ready")
    })
    
    return true
}

```

Objective C:

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Configure and start AppToolkit
	[AppToolkit launchWithToken:appToolkitToken];
	
	// Add ready-handler
	ATKConfigReady(^{
		NSLog(@"Config is ready");
	});	
	
	return YES;
}

```

This callback is called only once per app session, when AppToolkit has first retrieved the configuration over the network. Note that the configuration may be the same as what is already cached locally. This gives you the assurance that the config is the _newest_ available to the SDK.

If you'd like to be notified whenever AppToolkit has the newest config available _and subsequent changes_, you should use the `ATKConfigRefreshed()` method instead.

---
#### Author

AppToolkit, Inc., info@apptoolkit.io

#### License

AppToolkit is available under the Apache 2.0 license. See the LICENSE file for more info.
