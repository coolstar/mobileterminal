// MobileTerminalViewController.m
// MobileTerminal

#import "MobileTerminalViewController.h"

#import "Terminal/TerminalKeyboard.h"
#import "Terminal/TerminalGroupView.h"
#import "Terminal/TerminalView.h"
#import "Preferences/Settings.h"
#import "Preferences/TerminalSettings.h"
#import "VT100/ColorMap.h"
#import "MenuView.h"
#import "GestureResponder.h"
#import "GestureActionRegistry.h"

@implementation MobileTerminalViewController

@synthesize contentView;
@synthesize terminalGroupView;
@synthesize terminalSelector;
@synthesize preferencesButton;
@synthesize menuButton;
@synthesize interfaceDelegate;
@synthesize menuView;
@synthesize gestureResponder;
@synthesize gestureActionRegistry;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (void)awakeFromNib
{
  terminalKeyboard = [[TerminalKeyboard alloc] init];
  keyboardShown = NO;  
    
  // Copy and paste is off by default
  copyPasteEnabled = NO;
}

- (void)registerForKeyboardNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)unregisterForKeyboardNotifications
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
}

// TODO(allen): Fix the deprecation of UIKeyboardBoundsUserInfoKey
// below -- it requires more of a change because the replacement
// is not available in 3.1.3

- (void)keyboardWillShow:(NSNotification*)aNotification
{
  if (keyboardShown) {
    return;
  }
  keyboardShown = YES;

    [UIView animateWithDuration:[[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] delay:0 options:[[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
        // Get the size of the keyboard.
        NSValue* aValue = [aNotification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
        CGSize keyboardSize = [aValue CGRectValue].size;
        
        // Resize to the original height of the screen with the keyboard
        CGRect viewFrame = contentView.frame;
        viewFrame.size.height -= keyboardSize.height;
        contentView.frame = viewFrame;
    } completion:NULL];
}

-(IBAction)esc:(id)sender {
    [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c",0x1b] dataUsingEncoding:NSASCIIStringEncoding]];
}

-(IBAction)tab:(id)sender {
    [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c",0x9] dataUsingEncoding:NSASCIIStringEncoding]];
}

-(IBAction)up:(id)sender {
    [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c%c%c",(char)0x1B,(char)0x5B,(char)0x41] dataUsingEncoding:NSASCIIStringEncoding]];
}

-(IBAction)down:(id)sender {
    [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c%c%c",(char)0x1B,(char)0x5B,(char)0x42] dataUsingEncoding:NSASCIIStringEncoding]];
}

-(IBAction)left:(id)sender {
    [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c%c%c",(char)0x1B,(char)0x5B,(char)0x44] dataUsingEncoding:NSASCIIStringEncoding]];
}

-(IBAction)right:(id)sender {
    [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c%c%c",(char)0x1B,(char)0x5B,(char)0x43] dataUsingEncoding:NSASCIIStringEncoding]];
}

-(IBAction)showfn:(id)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [specialscroller setAlpha:0];
    [UIView commitAnimations];
}

-(IBAction)hidefn:(id)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [specialscroller setAlpha:1];
    [UIView commitAnimations];
}

-(IBAction)fn:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"F1"]){
        [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%cOP",0x1B] dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([sender.title isEqualToString:@"F2"]){
        [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%cOQ",0x1B] dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([sender.title isEqualToString:@"F3"]){
        [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%cOR",0x1B] dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([sender.title isEqualToString:@"F4"]){
        [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%cOS",0x1B] dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([sender.title isEqualToString:@"F5"]){
        [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c[15~",0x1B] dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([sender.title isEqualToString:@"F6"]){
        [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c[17~",0x1B] dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([sender.title isEqualToString:@"F7"]){
        [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c[18~",0x1B] dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([sender.title isEqualToString:@"F8"]){
        [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c[19~",0x1B] dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([sender.title isEqualToString:@"F9"]){
        [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c[20~",0x1B] dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([sender.title isEqualToString:@"F10"]){
        [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c[21~",0x1B] dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([sender.title isEqualToString:@"F11"]){
        [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c[22~",0x1B] dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([sender.title isEqualToString:@"F12"]){
        [[terminalGroupView terminalAtIndex:[terminalSelector currentPage]] receiveKeyboardInput:[[NSString stringWithFormat:@"%c[23~",0x1B] dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
  if (!keyboardShown) {
    return;
  }
  keyboardShown = NO;

    [UIView animateWithDuration:[[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] delay:0 options:[[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
        // Get the size of the keyboard.
        NSValue* aValue = [aNotification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
        CGSize keyboardSize = [aValue CGRectValue].size;
        
        // Resize to the original height of the screen without the keyboard
        CGRect viewFrame = contentView.frame;
        viewFrame.size.height += keyboardSize.height;
        contentView.frame = viewFrame;
    } completion:NULL];
}

- (void)setShowKeyboard:(BOOL)showKeyboard
{
  if (showKeyboard) {
    [terminalKeyboard becomeFirstResponder];
  } else {
    [terminalKeyboard resignFirstResponder];
  }
}

- (void)toggleKeyboard:(id)sender
{
  BOOL isShown = keyboardShown;
  [self setShowKeyboard:!isShown];
}

- (void)toggleCopyPaste:(id)sender;
{
  copyPasteEnabled = !copyPasteEnabled;
  [gestureResponder setSwipesEnabled:!copyPasteEnabled];
  for (int i = 0; i < [terminalGroupView terminalCount]; ++i) {
    TerminalView* terminal = [terminalGroupView terminalAtIndex:i];
    [terminal setCopyPasteEnabled:copyPasteEnabled];
  }
}

// Invoked when the page control is clicked to make a new terminal active.  The
// keyboard events are forwarded to the new active terminal and it is made the
// front-most terminal view.
- (void)terminalSelectionDidChange:(id)sender 
{
  TerminalView* terminalView =
      [terminalGroupView terminalAtIndex:[terminalSelector currentPage]];
  terminalKeyboard.inputDelegate = terminalView;
  gestureActionRegistry.terminalInput = terminalView;
  [terminalGroupView bringTerminalToFront:terminalView];
}

// Invoked when the preferences button is pressed
- (void)preferencesButtonPressed:(id)sender 
{
  // Remember the keyboard state for the next reload and don't listen for
  // keyboard hide/show events
  shouldShowKeyboard = keyboardShown;
  [self unregisterForKeyboardNotifications];

  [interfaceDelegate preferencesButtonPressed:sender];
}

// Invoked when the menu button is pressed
- (void)menuButtonPressed:(id)sender 
{
  [menuView setHidden:![menuView isHidden]];
}

// Invoked when a menu item is clicked, to run the specified command.
- (void)selectedCommand:(NSString*)command
{
  TerminalView* terminalView = [terminalGroupView frontTerminal];
  [terminalView receiveKeyboardInput:[command dataUsingEncoding:NSUTF8StringEncoding]];
  
  // Make the menu disappear
  [menuView setHidden:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  // User clicked the Exit button below
  exit(0);
}

- (void)viewDidLoad {
  [super viewDidLoad];

  @try {
    [terminalGroupView startSubProcess];
  } @catch (NSException* e) {
    NSLog(@"Caught %@: %@", [e name], [e reason]);
    if ([[e name] isEqualToString:@"ForkException"]) {
      // This happens if we fail to fork for some reason.
      // TODO(allen): Provide a helpful hint -- a kernel patch?
      UIAlertView* view =
      [[UIAlertView alloc] initWithTitle:[e name]
                                 message:[e reason]
                                delegate:self
                       cancelButtonTitle:@"Exit"
                       otherButtonTitles:NULL];
      [view show];
      return;
    }
    [e raise];
    return;
  }

  // TODO(allen):  This should be configurable
  shouldShowKeyboard = YES;

  // Adding the keyboard to the view has no effect, except that it is will
  // later allow us to make it the first responder so we can show the keyboard
  // on the screen.
  [[self view] addSubview:terminalKeyboard];

  // The menu button points to the right, but for this context it should point
  // up, since the menu moves that way.
  menuButton.transform = CGAffineTransformMakeRotation(-90.0f * M_PI / 180.0f);
  [menuButton setNeedsLayout];  
  
  // Setup the page control that selects the active terminal
  [terminalSelector setNumberOfPages:[terminalGroupView terminalCount]];
  [terminalSelector setCurrentPage:0];
  // Make the first terminal active
  [self terminalSelectionDidChange:self];
    
    CGRect frame = terminalGroupView.frame;
    frame.origin.y += 49;
    frame.size.height -= 49;
    frame.size.height -= 19;
    terminalGroupView.frame = frame;
    //specialkeys.layer.zPosition = 999999;
    fnscroller.contentSize = CGSizeMake(600, 43);
    specialscroller.contentSize = CGSizeMake(467, 43);
    
    //[((UIToolbar *)[specialscroller.subviews objectAtIndex:0]) items];
}

- (void)viewDidAppear:(BOOL)animated
{
  [interfaceDelegate rootViewDidAppear];
  [self registerForKeyboardNotifications];
  [self setShowKeyboard:shouldShowKeyboard];
  
  // Reset the font in case it changed in the preferenes view
  TerminalSettings* settings = [[Settings sharedInstance] terminalSettings];
  UIFont* font = [settings font];
  for (int i = 0; i < [terminalGroupView terminalCount]; ++i) {
    TerminalView* terminalView = [terminalGroupView terminalAtIndex:i];
    [terminalView setFont:font];
    [terminalView setNeedsLayout];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // This supports everything except for upside down, since upside down is most
  // likely accidental.
  switch (interfaceOrientation) {
    case UIInterfaceOrientationPortrait:
    case UIInterfaceOrientationLandscapeLeft:
    case UIInterfaceOrientationLandscapeRight:
      return YES;
    default:
      return NO;
  }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{  
  // We rotated, and almost certainly changed the frame size of the text view.
  [[self view] layoutSubviews];
}

- (void)didReceiveMemoryWarning {
	// TODO(allen): Should clear scrollback buffers to save memory? 
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  [terminalKeyboard release];
  [super dealloc];
}

@end
