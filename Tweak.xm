#import "_UILegibilityImageSet.h"

static UIColor *backColor = [UIColor colorWithWhite:0.0 alpha:0.57];
static UIColor *foreColor = [UIColor colorWithWhite:0.86 alpha:1.0];

static UIView *statusBarBackgroundView;

@interface UIApplication (memes)
-(id)statusBar;
@end

@interface UIStatusBar
-(CGRect)frame;
-(BOOL)isDoubleHeight;
-(id)_backgroundView;
-(void)setForegroundColor:(UIColor *)arg1 ;
@end

static BOOL isPad()
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

//Credit to @coolstarorg for original font code
static UIImage *generateLegacyFontWithTextAndSize(NSString *text, CGFloat fontSize) {
	UIFont *font = [UIFont fontWithName:@"Helvetica Bold" size:fontSize];
	CGSize size  = [text sizeWithAttributes:@{NSFontAttributeName: font}];
	UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
	NSDictionary *textAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: foreColor};
	[text drawAtPoint:CGPointMake(0.0, 0.0) withAttributes:textAttributes];
	UIImage *generatedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return generatedImage;
}

//New way of the SixBar
%hook UIStatusBar
-(void)layoutSubviews {
	%orig();
	if (self.isDoubleHeight) {
		statusBarBackgroundView.hidden = YES;
	}
	else {
		if (statusBarBackgroundView.hidden) {
			statusBarBackgroundView.hidden = NO;
		}
		statusBarBackgroundView = [[UIView alloc] initWithFrame:self.frame];
		statusBarBackgroundView.backgroundColor = backColor;
		[self._backgroundView addSubview:statusBarBackgroundView];
	}
	HBLogError(@"Panic!!! We're leaking!!!");
}
-(UIColor *)foregroundColor {
	return foreColor;
}
%end

%hook UIViewController
-(void)willRotateToInterfaceOrientation:(long long)arg1 duration:(CGFloat)arg2 {
	[statusBarBackgroundView removeFromSuperview];
	%orig(arg1, arg2);
}
%end

%hook UIApplicationDelegate 
-(void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
	[statusBarBackgroundView removeFromSuperview];
	%orig(application, newStatusBarFrame);
}
%end

%hook SBIconListView
-(CGFloat) topIconInset {
	return (!isPad()) ? 12.0f : %orig;
}
%end

%hook SBRootIconListView
-(CGFloat) topIconInset {
	return (!isPad()) ? 12.0f : %orig;
}
%end

%hook UIStatusBarItemView
- (_UILegibilityImageSet *)imageWithText:(NSString *)text {
	_UILegibilityImageSet *set = %orig;
	[set setImage:generateLegacyFontWithTextAndSize(text, 14.0)];
	return set;
}
%end

%hook UIStatusBarServiceItemView
-(_UILegibilityImageSet *)_contentsImageFromString:(NSString *)text withWidth:(double)arg2 letterSpacing:(double)arg3 {
	_UILegibilityImageSet *set = %orig;
	[set setImage:generateLegacyFontWithTextAndSize(text, 12.0)];
	return set;
}
%end