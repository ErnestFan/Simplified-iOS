#import "NSDate+NYPLDateAdditions.h"
#import "NYPLConfiguration.h"
#import "NYPLLinearView.h"
#import "NYPLRoundedButton.h"
#import "UIView+NYPLViewAdditions.h"

#import "NYPLBookDetailNormalView.h"

@interface NYPLBookDetailNormalView ()

@property (nonatomic) UIView *backgroundView;
@property (nonatomic) NYPLRoundedButton *deleteButton;
@property (nonatomic) NYPLRoundedButton *downloadButton;
@property (nonatomic) NYPLLinearView *deleteReadLinearView;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) NYPLRoundedButton *readButton;

@end

@implementation NYPLBookDetailNormalView

#pragma mark UIView

- (instancetype)initWithWidth:(CGFloat)width
{
  self = [super initWithFrame:CGRectMake(0, 0, width, 70)];
  if(!self) return nil;
  
  self.backgroundView = [[UIView alloc] init];
  self.backgroundView.backgroundColor = [NYPLConfiguration mainColor];
  [self addSubview:self.backgroundView];
  
  self.downloadButton = [NYPLRoundedButton button];
  [self.downloadButton addTarget:self
                          action:@selector(didSelectDownload)
                forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:self.downloadButton];
  
  self.deleteButton = [NYPLRoundedButton button];
  [self.deleteButton setTitle:NSLocalizedString(@"Delete", nil)
                     forState:UIControlStateNormal];
  [self.deleteButton addTarget:self
                        action:@selector(didSelectReturn)
              forControlEvents:UIControlEventTouchUpInside];
  
  self.messageLabel = [[UILabel alloc] init];
  self.messageLabel.font = [UIFont systemFontOfSize:12];
  self.messageLabel.textColor = [NYPLConfiguration backgroundColor];
  [self addSubview:self.messageLabel];
  
  self.readButton = [NYPLRoundedButton button];
  [self.readButton setTitle:NSLocalizedString(@"Read", nil)
                   forState:UIControlStateNormal];
  [self.readButton addTarget:self
                      action:@selector(didSelectRead)
            forControlEvents:UIControlEventTouchUpInside];
  
  self.deleteReadLinearView = [[NYPLLinearView alloc] init];
  self.deleteReadLinearView.padding = 5.0;
  [self.deleteReadLinearView addSubview:self.deleteButton];
  [self.deleteReadLinearView addSubview:self.readButton];
  [self addSubview:self.deleteReadLinearView];
  
  return self;
}

#pragma mark UIView

- (void)layoutSubviews
{
  self.backgroundView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 30);
  
  [self.messageLabel sizeToFit];
  self.messageLabel.center = self.backgroundView.center;
  [self.messageLabel integralizeFrame];
  
  [self.downloadButton sizeToFit];
  self.downloadButton.center = self.center;
  self.downloadButton.frame = CGRectMake(CGRectGetMinX(self.downloadButton.frame),
                                         (CGRectGetHeight(self.frame) -
                                          CGRectGetHeight(self.downloadButton.frame)),
                                         CGRectGetWidth(self.downloadButton.frame),
                                         CGRectGetHeight(self.downloadButton.frame));
  [self.downloadButton integralizeFrame];
  
  [self.deleteButton sizeToFit];
  
  [self.readButton sizeToFit];
  
  [self.deleteReadLinearView sizeToFit];
  self.deleteReadLinearView.center = self.center;
  self.deleteReadLinearView.frame = CGRectMake(CGRectGetMinX(self.deleteReadLinearView.frame),
                                               (CGRectGetHeight(self.frame) -
                                                CGRectGetHeight(self.deleteReadLinearView.frame)),
                                               CGRectGetWidth(self.deleteReadLinearView.frame),
                                               CGRectGetHeight(self.deleteReadLinearView.frame));
  [self.deleteReadLinearView integralizeFrame];
}

#pragma mark -

- (void)setState:(NYPLBookDetailNormalViewState const)state
{
  _state = state;
  
  // TODO: These strings must be localized!
  
  switch(state) {
    case NYPLBookDetailNormalViewStateCanBorrow:
      self.messageLabel.text = NSLocalizedString(@"BookDetailViewControllerAvailableToBorrowTitle", nil);
      self.deleteReadLinearView.hidden = YES;
      self.downloadButton.hidden = NO;
      [self.downloadButton setTitle:NSLocalizedString(@"Borrow", nil)
                           forState:UIControlStateNormal];
      [self.downloadButton sizeToFit];
      break;
    case NYPLBookDetailNormalViewStateCanHold:
      self.messageLabel.text = NSLocalizedString(@"BookDetailViewControllerCanHoldTitle", nil);
      self.deleteReadLinearView.hidden = YES;
      self.downloadButton.hidden = NO;
      [self.downloadButton setTitle:NSLocalizedString(@"Hold", nil)
                           forState:UIControlStateNormal];
      [self.downloadButton sizeToFit];
      break;
    case NYPLBookDetailNormalViewStateCanKeep:
      self.messageLabel.text = NSLocalizedString(@"BookDetailViewControllerCanKeepTitle", nil);
      self.deleteReadLinearView.hidden = YES;
      self.downloadButton.hidden = NO;
      [self.downloadButton setTitle:NSLocalizedString(@"Download", nil)
                           forState:UIControlStateNormal];
      [self.downloadButton sizeToFit];
      break;
    case NYPLBookDetailNormalViewStateDownloadNeeded:
      self.messageLabel.text = NSLocalizedString(@"BookDetailViewControllerDownloadNeededTitle", nil);
      self.deleteReadLinearView.hidden = YES;
      self.downloadButton.hidden = NO;
      [self.downloadButton setTitle:NSLocalizedString(@"Download", nil)
                           forState:UIControlStateNormal];
      break;
    case NYPLBookDetailNormalViewStateDownloadSuccessful:
      self.messageLabel.text = NSLocalizedString(@"BookDetailViewControllerDownloadSuccessfulTitle", nil);
      self.deleteReadLinearView.hidden = NO;
      self.downloadButton.hidden = YES;
      break;
    case NYPLBookDetailNormalViewStateHolding:
      self.messageLabel.text = [NSString stringWithFormat:NSLocalizedString(@"BookDetailViewControllerHoldingTitleFormat", nil),
                                [self.date longTimeUntilString]];
      self.downloadButton.hidden = YES;
      self.readButton.hidden = YES;
      self.deleteReadLinearView.hidden = NO;
      self.deleteButton.hidden = NO;
      [self.deleteButton setTitle:NSLocalizedString(@"CancelHold", nil)
                         forState:UIControlStateNormal];
      break;
    case NYPLBookDetailNormalViewStateHoldingFOQ:
      self.messageLabel.text = [NSString stringWithFormat:NSLocalizedString(@"BookDetailViewControllerReservedTitleFormat", nil),
                                [self.date longTimeUntilString]];
      self.deleteReadLinearView.hidden = YES;
      self.downloadButton.hidden = NO;
      // TODO: Make cancel hold button fit here (it currently overlaps)
      //[self.deleteButton setTitle:NSLocalizedString(@"CancelHold", nil)
      //                   forState:UIControlStateNormal];
      //[self.downloadButton sizeToFit];
      [self.downloadButton setTitle:NSLocalizedString(@"Borrow", nil)
                           forState:UIControlStateNormal];
      [self.downloadButton sizeToFit];
      break;
    case NYPLBookDetailNormalViewStateUsed:
      self.messageLabel.text = NSLocalizedString(@"BookDetailViewControllerDownloadSuccessfulTitle", nil);
      self.deleteReadLinearView.hidden = NO;
      self.downloadButton.hidden = YES;
      break;
  }
  
  [self.messageLabel sizeToFit];
  self.messageLabel.center = self.backgroundView.center;
  [self.messageLabel integralizeFrame];
}

- (void)didSelectReturn
{
  [self.delegate didSelectReturnForBookDetailNormalView:self];
}

- (void)didSelectDownload
{
  [self.delegate didSelectDownloadForBookDetailNormalView:self];
}

- (void)didSelectRead
{
  [self.delegate didSelectReadForBookDetailNormalView:self];
}

@end
