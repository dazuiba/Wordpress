//
//  ReplyToCommentViewController.m
//  WordPress
//
//  Created by John Bickerstaff on 12/20/09.
//  
//

#import "ReplyToCommentViewController.h"
#import "BlogDataManager.h"
#import "WPProgressHUD.h"
#import "Reachability.h"

NSTimeInterval kAnimationDuration2 = 0.3f;

@interface ReplyToCommentViewController (Private)

- (BOOL)isConnectedToHost;
- (void)initiateSaveCommentReply:(id)sender;
- (void)saveReplyBackgroundMethod:(id)sender;
- (void)callBDMSaveCommentReply:(SEL)selector;
- (void)endTextEnteringButtonAction:(id)sender;
- (void)testStringAccess;
-(void) receivedRotate: (NSNotification*) notification;


@end



@implementation ReplyToCommentViewController

@synthesize commentViewController, commentDetails, currentIndex, saveButton, doneButton, comment;
@synthesize leftView, cancelButton, label, hasChanges, textViewText;

//TODO: Make sure to give this class a connection to commentDetails and currentIndex from CommentViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


- (void)testStringAccess{
	//NSLog(@"%@",foo);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	//foo = [[NSString alloc] initWithString: textView.text];
	
	comment = [[NSMutableDictionary alloc] init];
	
	if (!saveButton) {
	saveButton = [[UIBarButtonItem alloc] 
				  initWithTitle:@"Save" 
				  style:UIBarButtonItemStyleDone
				  target:self 
				  action:@selector(initiateSaveCommentReply:)];
	}
	
	
	if (!leftView) {
        leftView = [WPNavigationLeftButtonView createCopyOfView];
        [leftView setTitle:@"Comment"];
	}
	
}


- (void)viewWillAppear:(BOOL)animated {
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(receivedRotate:) name: UIDeviceOrientationDidChangeNotification object: nil];

	
	self.hasChanges = NO;
	//foo = textView.text;//so we can compare to set hasChanges correctly
	textViewText = [[NSString alloc] initWithString: textView.text];
	NSLog(@"waga this is the text from textViewString %@", textViewText);

	[leftView setTarget:self withAction:@selector(cancelView:)];
	cancelButton = [[UIBarButtonItem alloc] initWithCustomView:leftView];
	self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
	
	comment = [commentDetails objectAtIndex:currentIndex];
	if ([[comment valueForKey:@"status"] isEqualToString:@"hold"]) {
		NSLog(@"inside if of vwappear");
		label.backgroundColor = PENDING_COMMENT_TABLE_VIEW_CELL_BACKGROUND_COLOR;
		label.hidden = NO;
	} else {
		label.hidden = YES;
		//TODO: JOHNB - code movement of text view upward if this is not a pending comment
		
	}
	
	[textView becomeFirstResponder];
	[self testStringAccess];
	

	
	
	
}

-(void) viewWillDisappear: (BOOL) animated{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[saveButton release];
	[doneButton release];
	[comment release];
	[commentDetails release];
	[textViewText release];
	[leftView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Button Override Methods

- (void)cancelView:(id)sender {
    [commentViewController cancelView:sender];
	NSLog(@"inside replyToCommentViewController cancelView");
	
//    if (!hasChanges) {
//        //[self stopTimer];
        //[commentViewController.navigationController popViewControllerAnimated:YES];
	//[commentViewController.navigationController popViewControllerAnimated:YES];
//        return;
//    }
//	
//	
//	
//    //[postSettingsController endEditingAction:nil];
//    //[postDetailEditController endEditingAction:nil];
//	
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"You have unsaved changes."
//															 delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Discard"
//													otherButtonTitles:nil];
//    actionSheet.tag = 401;
//    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
//    [actionSheet showInView:self.view];
//    WordPressAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//    [delegate setAlertRunning:YES];
//	
//    [actionSheet release];
}

#pragma mark -
#pragma mark Helper Methods

- (void) test{
	NSLog(@"inside replyTOCommentViewController:test");
}

- (void)endTextEnteringButtonAction:(id)sender {
	
    [textView resignFirstResponder];
	//UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
	//if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
		//[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationPortrait];
	//}
	
	
}

- (void)setTextViewHeight:(float)height {
	NSLog(@"inside setTextViewHeight %f", height);
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kAnimationDuration2];
    CGRect frame = textView.frame;
    frame.size.height = height;
    textView.frame = frame;
	[UIView commitAnimations];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	NSLog(@"inside ReplyToCommentViewController's should autorotate");
		return YES;
}

-(void) receivedRotate: (NSNotification*) notification
{
	UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
		if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
			NSLog(@"inside RTCVC new method - landscape");
			[self setTextViewHeight:130];
		}else {
			NSLog(@"inside RTCVC newmethod - portriat");
			[self setTextViewHeight:225];
		}
}
#pragma mark -
#pragma mark Text View Delegate Methods




- (void)textViewDidEndEditing:(UITextView *)aTextView {
	NSString *textString = textView.text;
	//set hasChanges only if a change was made using textViewString
	NSLog(@"just before accessing textViewString in did end editing");
	NSLog(@"textviewText inside did end editing %@", self.textViewText);
	if (![textString isEqualToString:textViewText]) {
		self.hasChanges=YES;
	}
	
	//make the text view longer !!!! 
	[self setTextViewHeight:460];
	

	[leftView setTitle:@"Cancel"];
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
	self.navigationItem.leftBarButtonItem = barItem;	
}

- (void)textViewDidBeginEditing:(UITextView *)aTextView {
	
	
	
	self.navigationItem.rightBarButtonItem = saveButton;
	doneButton = [[UIBarButtonItem alloc] 
								   initWithTitle:@"Done" 
								   style:UIBarButtonItemStyleDone 
								   target:self 
								   action:@selector(endTextEnteringButtonAction:)];
	
	[self.navigationItem setLeftBarButtonItem:doneButton];

}


//replace "&nbsp" with a space @"&#160;" before Apple's broken TextView handling can do so and break things
//this enables the "http helper" to work as expected
//important is capturing &nbsp BEFORE the semicolon is added.  Not doing so causes a crash in the textViewDidChange method due to array overrun
- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	//if nothing has been entered yet, return YES to prevent crash when hitting delete
	
    if (text.length == 0) {
		return YES;
    }
	
    // create final version of textView after the current text has been inserted
    NSMutableString *updatedText = [[NSMutableString alloc] initWithString:aTextView.text];
    [updatedText insertString:text atIndex:range.location];
	
    NSRange replaceRange = range, endRange = range;
	
    if (text.length > 1) {
        // handle paste
        replaceRange.length = text.length;
    } else {
        // handle normal typing
        replaceRange.length = 6;  // length of "&#160;" is 6 characters
        replaceRange.location -= 5; // look back one characters (length of "&#160;" minus one)
    }
	
    // replace "&nbsp" with "&#160;" for the inserted range
    int replaceCount = [updatedText replaceOccurrencesOfString:@"&nbsp" withString:@"&#160;" options:NSCaseInsensitiveSearch range:replaceRange];
	
    if (replaceCount > 0) {
        // update the textView's text
        aTextView.text = updatedText;
		
        // leave cursor at end of inserted text
        endRange.location += text.length + replaceCount * 1; // length diff of "&nbsp" and "&#160;" is 1 character
        aTextView.selectedRange = endRange; 
		
        [updatedText release];
		
        // let the textView know that it should ingore the inserted text
        return NO;
    }
	
    [updatedText release];
	
    // let the textView know that it should handle the inserted text
    return YES;
}





#pragma mark -
#pragma mark Comment Handling Methods

- (BOOL)isConnectedToHost {
    if (![[Reachability sharedReachability] remoteHostStatus] != NotReachable) {
        UIAlertView *connectionFailAlert = [[UIAlertView alloc] initWithTitle:@"No connection to host."
																	  message:@"Operation is not supported now."
																	 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [connectionFailAlert show];
        [connectionFailAlert release];
        return NO;
    }
	
    return YES;
}

- (void)initiateSaveCommentReply:(id)sender {

    progressAlert = [[WPProgressHUD alloc] initWithLabel:@"Saving Reply..."];
    [progressAlert show];
	comment = [commentDetails objectAtIndex:currentIndex];
	[comment setValue:textView.text forKey:@"content"];	
    [self performSelectorInBackground:@selector(saveReplyBackgroundMethod:) withObject:nil];
	
	[self.navigationController popViewControllerAnimated:YES];
	

}

- (void)saveReplyBackgroundMethod:(id)sender {
	[self callBDMSaveCommentReply:@selector(replyToComment:forBlog:)];
	NSLog(@"after callBDMSaveCommentReply");
}

- (void)callBDMSaveCommentReply:(SEL)selector {
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

if ([self isConnectedToHost]) {
	BlogDataManager *sharedDataManager = [BlogDataManager sharedDataManager];
	[sharedDataManager performSelector:selector withObject:[self comment] withObject:[sharedDataManager currentBlog]];
	[sharedDataManager loadCommentTitlesForCurrentBlog];
}

[progressAlert dismissWithClickedButtonIndex:0 animated:YES];
[progressAlert release];
[pool release];
}


@end
