#import "MenubarController.h"
#import "StatusItemView.h"

@implementation MenubarController

@synthesize statusItemView = _statusItemView;

#pragma mark -

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        // Install status item into the menu bar
        NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
        _statusItemView = [[StatusItemView alloc] initWithStatusItem:statusItem];
        _statusItemView.image = [NSImage imageNamed:@"Status"];
        _statusItemView.alternateImage = [NSImage imageNamed:@"StatusHighlighted"];
        _statusItemView.action = @selector(togglePanel:);
		
		// set up websocket
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080"]];
		self.webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
		self.webSocket.delegate = self;
		
		[self.webSocket open];
    }
    return self;
}

- (void)dealloc
{
	[self.webSocket close];
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

#pragma mark -
#pragma mark Public accessors

- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}

#pragma mark - web socket stuff

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
	NSString *json = (NSString *)message;
	NSDictionary *msg = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
	
	NSString *sensorState = msg[@"event"][@"data"][@"sensor"][@"state"];
	if ([@"open" isEqualToString:sensorState]) {
		self.statusItemView.image = [NSImage imageNamed:@"Status"];
	} else {
		self.statusItemView.image = [NSImage imageNamed:@"StatusOccupied"];
	}
	
	NSLog(@"%@", sensorState);
}

#pragma mark -

- (BOOL)hasActiveIcon
{
    return self.statusItemView.isHighlighted;
}

- (void)setHasActiveIcon:(BOOL)flag
{
    self.statusItemView.isHighlighted = flag;
}

@end
