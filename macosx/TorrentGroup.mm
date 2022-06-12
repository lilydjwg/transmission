// This file Copyright © 2008-2022 Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#include <libtransmission/transmission.h>
#include <libtransmission/utils.h> // tr_getRatio()

#import "TorrentGroup.h"
#import "GroupsController.h"
#import "Torrent.h"

@implementation TorrentGroup

- (instancetype)initWithGroup:(NSInteger)group
{
    if ((self = [super init]))
    {
        _groupIndex = group;
        _torrents = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Torrent Group %ld: %@", self.groupIndex, self.torrents];
}

- (NSInteger)groupOrderValue
{
    return [GroupsController.groups rowValueForIndex:self.groupIndex];
}

- (CGFloat)ratio
{
    uint64_t uploaded = 0, total_size = 0;
    for (Torrent* torrent in self.torrents)
    {
        uploaded += torrent.uploadedTotal;
        total_size += torrent.totalSizeSelected;
    }

    return tr_getRatio(uploaded, total_size);
}

- (uint64_t)uploadRateBps
{
    auto sum = uint64_t{};

    for (Torrent* torrent in self.torrents)
    {
        sum += torrent.uploadRateBps;
    }

    return sum;
}

- (uint64_t)downloadRateBps
{
    auto sum = uint64_t{};

    for (Torrent* torrent in self.torrents)
    {
        sum += torrent.downloadRateBps;
    }

    return sum;
}

@end
