
#import "SELibraryVC.h"
#import "UIColor+iOS7Colors.h"
#import "SETableViewCell.h"
#import "SELibrary.h"
#import "SEPatternSaver.h"

static NSString *const cellId = @"LibraryTableViewCell";

@interface SELibraryVC () <UITableViewDataSource, UITableViewDelegate, SEPatternSaver>
@property (nonatomic,strong) SELibrary* library;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SELibraryVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.library = [SELibrary sharedLibrary];
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"SETableViewCell" bundle:[NSBundle mainBundle]]
              forCellReuseIdentifier:cellId];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
    self.tableView.backgroundColor = [UIColor rhythmusBackgroundColor];
}

#pragma mark UITableViewDataSource Protocol methods

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *tableViewCell =
    [tableView dequeueReusableCellWithIdentifier:cellId];
    
    ((SETableViewCell*)tableViewCell).nameLabel.text =
    [NSString stringWithFormat:@"%@",self.library.patternCache[indexPath.row][kLibraryFileName]];
    
    return tableViewCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.library.patternCache count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark UITableViewDelegate Protocol methods

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"FileURL : %@",self.library.patternCache[indexPath.row][kLibraryFileURL]);
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSURL* fileURL = self.library.patternCache[indexPath.row][kLibraryFileURL];
        if ([[NSFileManager defaultManager] removeItemAtPath: [fileURL path] error: NULL]  == YES){
            [self.library.patternCache removeObjectAtIndex:indexPath.row];
            NSLog (@"Remove successful");
        } else{
            NSLog (@"Remove failed");
        }
    }
    [self.tableView reloadData];
}

-(void)savePattern:(id)pattern
{
    NSLog(@"write to file");
    /*
     * TODO self.library add pattern
     */
}

@end
