#import "HSHelpStack.h"
#import "HSZenDeskGear.h"
#import "NYPLConfiguration.h"
#import "NYPLBookRegistry.h"
#import "NYPLReaderSettings.h"
#import "NYPLRootTabBarController.h"
#import "NYPLEULAViewController.h"
#import "NYPLSettings.h"
#import "Heap.h"

// TODO: Remove these imports and move handling the "open a book url" code to a more appropriate handler
#import "NYPLXML.h"
#import "NYPLOPDSEntry.h"
#import "NYPLBook.h"
#import "NYPLBookDetailViewController.h"
#import "NSURL+NYPLURLAdditions.h"

#import "NYPLAppDelegate.h"

@implementation NYPLAppDelegate

#pragma mark UIApplicationDelegate

- (BOOL)application:(__attribute__((unused)) UIApplication *)application
didFinishLaunchingWithOptions:(__attribute__((unused)) NSDictionary *)launchOptions
{
  // This is normally not called directly, but we put all programmatic appearance setup in
  // NYPLConfiguration's class initializer.
  [NYPLConfiguration initialize];
  
  [[HSHelpStack instance] setThemeFrompList:@"HelpStackTheme"];
  HSZenDeskGear *zenDeskGear  = [[HSZenDeskGear alloc]
                                 initWithInstanceUrl : @"https://nypl.zendesk.com"
                                 staffEmailAddress   : @"johannesneuer@nypl.org"
                                 apiToken            : @"P6aFczYFc4al6o2riRBogWLi5D0M0QCdrON6isJi"];
  
  HSHelpStack *helpStack = [HSHelpStack instance];
  helpStack.gear = zenDeskGear;
  
  if ([NYPLConfiguration heapEnabled]) {
//    [Heap setAppId:@"3245728259"]; // This is the production environment app ID
    [Heap setAppId:@"1848989408"]; // This is the development environment app ID
#ifdef DEBUG
    [Heap enableVisualizer];
#endif
  }
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.tintColor = [NYPLConfiguration mainColor];
  self.window.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
  [self.window makeKeyAndVisible];
  
  if ([[NYPLSettings sharedSettings] userAcceptedEULA]) {
    self.window.rootViewController = [NYPLRootTabBarController sharedController];
    
  } else {
    NYPLRootTabBarController *mainViewController = [NYPLRootTabBarController sharedController];
    UIViewController *eulaViewController = [[NYPLEULAViewController alloc] initWithCompletionHandler:^(void) {
      [UIView transitionWithView:self.window
                        duration:0.5
                         options:UIViewAnimationOptionTransitionCurlUp
                      animations:^() {self.window.rootViewController = mainViewController; }
                      completion:nil];
    }];
    self.window.rootViewController = eulaViewController;
  }
  
  return YES;
}

- (BOOL)application:(__attribute__((unused)) UIApplication *)application handleOpenURL:(NSURL *)url
{
  // The url has the simplifiedapp scheme; we want to give it the http scheme
  NSURL *entryURL = [url URLBySwappingForScheme:@"http"];
  
  // Get XML from the url, which should be a permalink to a feed URL
  NSData *data = [NSData dataWithContentsOfURL:entryURL];
  
  // Turn the raw data into a real XML
  NYPLXML *xml = [NYPLXML XMLWithData:data];
  
  // Throw that xml at a NYPLOPDSEntry
  NYPLOPDSEntry *entry = [[NYPLOPDSEntry alloc] initWithXML:xml];
  
  // Create a book from the entry
  NYPLBook *book = [NYPLBook bookWithEntry:entry];
  
  // Finally (we hope) launch the book modal view
  NYPLBookDetailViewController *modalBookController = [[NYPLBookDetailViewController alloc] initWithBook:book];
  NYPLRootTabBarController *tbc = (NYPLRootTabBarController *) self.window.rootViewController;
  
  if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    if ([tbc.selectedViewController isKindOfClass:[UINavigationController class]])
      [tbc.selectedViewController pushViewController:modalBookController animated:YES];
  } else {
    [tbc.selectedViewController presentViewController:modalBookController animated:YES completion:nil];
  }
  
  return YES;
}

- (void)applicationDidEnterBackground:(__attribute__((unused)) UIApplication *)application
{
  [[NYPLBookRegistry sharedRegistry] save];
  [[NYPLReaderSettings sharedSettings] save];
}

@end
