
#import "PadOptionsVC.h"
#import "UIColor+iOS7Colors.h"
#import "SELibrary.h"
#import "SETableViewCell.h"
#import "DTCustomColoredAccessory.h"

static NSString*const sampleCellId = @"SampleCellId";
static NSString*const colorCellId = @"ColorCellId";



#pragma mark PadOptionsVC Extension

@interface PadOptionsVC ()

@property (nonatomic,strong) SELibrary* library;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableIndexSet *expandedSections;

- (IBAction)processCancel:(UIButton *)sender;

@end


#pragma mark PadOptionsVC Implementation

@implementation PadOptionsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.library = [SELibrary sharedLibrary];
    [self.tableView registerNib:[UINib nibWithNibName:@"SETableViewCell" bundle:[NSBundle mainBundle]]
              forCellReuseIdentifier:sampleCellId];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:colorCellId];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.expandedSections = [[NSMutableIndexSet alloc] init];
    
    self.tableView.backgroundColor = [UIColor rhythmusBackgroundColor];
}

- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    return YES;
}

- (void)processCancel:(UIButton *)sender
{
    [self.delegate optionsControllerDidCanceled:self];
}


#pragma mark UITableViewDataSource Protocol methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* tableViewCell;
    if(indexPath.section == 0){
        tableViewCell = [tableView dequeueReusableCellWithIdentifier:colorCellId];
    } else {
        tableViewCell = [tableView dequeueReusableCellWithIdentifier:sampleCellId];
    }
    
    if ([self tableView:tableView canCollapseSection:indexPath.section])
    {
        if (!indexPath.row)
        {
            if(indexPath.section == 0){
                tableViewCell.textLabel.text = @"Colors";
            } else {
                tableViewCell.textLabel.text = @"Samples";
            }
            if ([self.expandedSections containsIndex:indexPath.section])
            {
                tableViewCell.accessoryView = [DTCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:DTCustomColoredAccessoryTypeUp];
            }
            else
            {
                tableViewCell.accessoryView = [DTCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:DTCustomColoredAccessoryTypeDown];
            }
        }
        else
        {
            if(indexPath.section == 0){
                tableViewCell.textLabel.text = @"";
                NSString *message = [UIColor sharedColorNames][indexPath.row-1];
                SEL s = NSSelectorFromString(message);
                tableViewCell.backgroundColor = objc_msgSend([UIColor class], s);
            } else {
                ((SETableViewCell*)tableViewCell).nameLabel.text =
                [NSString stringWithFormat:@"%@",self.library.sampleCache[indexPath.row-1][kLibraryFileName]];
                
                ((SETableViewCell*)tableViewCell).buttonBlock = ^(){
                    [self processCancel:nil];
                };
            }
        }
    }
    
    return tableViewCell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self tableView:tableView canCollapseSection:section])
    {
        if ([self.expandedSections containsIndex:section])
        {
            if(section == 0){
                return [[UIColor sharedColorNames]count];
            }
            return [self.library.sampleCache count];
        }
            
        return 1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark UITableViewDelegate Protocol methods


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self tableView:tableView canCollapseSection:indexPath.section])
    {
        if (!indexPath.row)
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSInteger section = indexPath.section;
            BOOL currentlyExpanded = [self.expandedSections containsIndex:section];
            NSInteger rows;
            
            NSMutableArray *tmpArray = [NSMutableArray array];
            
            if (currentlyExpanded)
            {
                rows = [self tableView:tableView numberOfRowsInSection:section];
                [self.expandedSections removeIndex:section];
                
            }
            else
            {
                [self.expandedSections addIndex:section];
                rows = [self tableView:tableView numberOfRowsInSection:section];
            }
            
            for (int i=1; i<rows; i++)
            {
                NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i
                                                               inSection:section];
                [tmpArray addObject:tmpIndexPath];
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (currentlyExpanded)
            {
                [tableView deleteRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationFade];
                
                cell.accessoryView = [DTCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:DTCustomColoredAccessoryTypeDown];
                
            }
            else
            {
                [tableView insertRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationFade];
                cell.accessoryView =  [DTCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:DTCustomColoredAccessoryTypeUp];
                
            }
        } else {
            if(indexPath.section == 0){
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                self.pad.backgroundColor = [tableView cellForRowAtIndexPath:indexPath].backgroundColor;
                [self processCancel:nil];
            } else {
                NSLog(@"fileURL : %@",self.library.sampleCache[indexPath.row][kLibraryFileURL]);
            }
        }
    }
}



@end
