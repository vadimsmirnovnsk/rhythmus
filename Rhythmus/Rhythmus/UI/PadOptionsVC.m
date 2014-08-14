
#import "PadOptionsVC.h"
#import "UIColor+iOS7Colors.h"
#import "SELibrary.h"
#import "SETableViewCell.h"

static NSString *const cellId = @"PadsTableViewCell";


#pragma mark PadOptionsVC Extension

@interface PadOptionsVC ()

@property (nonatomic,strong) SELibrary* library;
@property (nonatomic, weak) IBOutlet UITableView *colorTableView;

- (IBAction)processCancel:(UIButton *)sender;

@end


#pragma mark PadOptionsVC Implementation

@implementation PadOptionsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.library = [SELibrary sharedLibrary];
    [self.colorTableView registerNib:[UINib nibWithNibName:@"SETableViewCell" bundle:[NSBundle mainBundle]]
     forCellReuseIdentifier:cellId];
    
    self.colorTableView.dataSource = self;
    self.colorTableView.delegate = self;
    
    self.colorTableView.backgroundColor = [UIColor rhythmusBackgroundColor];
}

- (void)processCancel:(UIButton *)sender
{
    [self.delegate optionsControllerDidCanceled:self];
}

// CR: Why don't you use the view controller's layouting features?
// Will make it some later)
// TODO: Use the view controller's layouting features
- (void)layoutSubviews {
  [UIView animateWithDuration:0.5 animations:^{
      [self.colorTableView setNeedsLayout];
      [self.colorTableView layoutIfNeeded];
  }];
}


#pragma mark UITableViewDataSource Protocol methods

- (UITableViewCell *)tableView:(UITableView *)tableView
    cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *tableViewCell =
        [tableView dequeueReusableCellWithIdentifier:cellId];
    
    ((SETableViewCell*)tableViewCell).nameLabel.text =
        [NSString stringWithFormat:@"%@",self.library.sampleCache[indexPath.row][kLibraryFileName]];
    
    return tableViewCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.library.sampleCache count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark UITableViewDelegate Protocol methods

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"fileURL : %@",self.library.sampleCache[indexPath.row][kLibraryFileURL]);
}



@end
