// This file Copyright © 2006-2022 Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "Badger.h"
#import "BadgeView.h"
#import "NSStringAdditions.h"
#import "Torrent.h"

@interface Badger ()

@property(nonatomic, readonly) tr_session* fLib;

@property(nonatomic, readonly) NSMutableSet* fHashes;

@end

@implementation Badger

- (instancetype)initWithLib:(tr_session*)lib
{
    if ((self = [super init]))
    {
        _fLib = lib;

        BadgeView* view = [[BadgeView alloc] initWithLib:lib];
        NSApp.dockTile.contentView = view;

        _fHashes = [[NSMutableSet alloc] init];
    }

    return self;
}

- (void)updateBadgeWithDownload:(uint64_t)dlRateBps upload:(uint64_t)ulRateBps
{
    uint64_t const displayDlRateBps = [NSUserDefaults.standardUserDefaults boolForKey:@"BadgeDownloadRate"] ? dlRateBps : 0;
    uint64_t const displayUlRateBps = [NSUserDefaults.standardUserDefaults boolForKey:@"BadgeUploadRate"] ? ulRateBps : 0;

    //only update if the badged values change
    if ([(BadgeView*)NSApp.dockTile.contentView setRatesWithDownload:displayDlRateBps upload:displayUlRateBps])
    {
        [NSApp.dockTile display];
    }
}

- (void)addCompletedTorrent:(Torrent*)torrent
{
    NSParameterAssert(torrent != nil);

    [self.fHashes addObject:torrent.hashString];
    NSApp.dockTile.badgeLabel = [NSString formattedUInteger:self.fHashes.count];
}

- (void)removeTorrent:(Torrent*)torrent
{
    if ([self.fHashes member:torrent.hashString])
    {
        [self.fHashes removeObject:torrent.hashString];
        if (self.fHashes.count > 0)
        {
            NSApp.dockTile.badgeLabel = [NSString formattedUInteger:self.fHashes.count];
        }
        else
        {
            NSApp.dockTile.badgeLabel = @"";
        }
    }
}

- (void)clearCompleted
{
    if (self.fHashes.count > 0)
    {
        [self.fHashes removeAllObjects];
        NSApp.dockTile.badgeLabel = @"";
    }
}

@end
