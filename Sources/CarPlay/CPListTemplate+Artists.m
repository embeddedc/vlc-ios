/*****************************************************************************
 * CPListTemplate+Artists.m
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2022 VideoLAN. All rights reserved.
 * $Id$
 *
 * Author: Felix Paul Kühne <fkuehne # videolan.org>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import "CPListTemplate+Artists.h"
#import "VLC-Swift.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"

@implementation CPListTemplate (Artists)

+ (CPListTemplate *)artistList
{

    CPListSection *listSection = [[CPListSection alloc] initWithItems:[self listOfArtists]];
    CPListTemplate *template = [[CPListTemplate alloc] initWithTitle:NSLocalizedString(@"ARTISTS", nil)
                                                            sections:@[listSection]];
    template.tabTitle = NSLocalizedString(@"ARTISTS", nil);
    template.tabImage = [UIImage imageNamed:@"cp-Artist"];
    return template;
}

+ (NSArray *)listOfArtists
{
    NSArray *artists = [[VLCAppCoordinator sharedInstance].mediaLibraryService artistsWithSortingCriteria:VLCMLSortingCriteriaDefault
                                                                                                     desc:NO
                                                                                                  listAll:YES];

    NSUInteger count = artists.count;
    NSMutableArray *itemList = [[NSMutableArray alloc] initWithCapacity:count];

    for (NSUInteger x = 0; x < count; x++) {
        CPListImageRowItem *listItem;

        VLCMLArtist *iter = artists[x];
        NSArray *albums = iter.albums;
        NSMutableArray *albumImages = [NSMutableArray array];

        for (VLCMLAlbum *album in albums) {
            UIImage *artworkImage = [VLCThumbnailsCache thumbnailForURL:album.artworkMRL];
            if (!artworkImage) {
                artworkImage = [UIImage imageNamed:@"cp-Artist"];
            }
            [albumImages addObject:artworkImage];
        }

        listItem = [[CPListImageRowItem alloc] initWithText:iter.name images:albumImages];

        listItem.userInfo = iter;
        listItem.handler = ^(id <CPSelectableListItem> item,
                             dispatch_block_t completionBlock) {
            VLCPlaybackService *playbackService = [VLCPlaybackService sharedInstance];
            VLCMLArtist *artist = item.userInfo;
            [playbackService playMediaAtIndex:0 fromCollection:[artist tracks]];
            completionBlock();
        };
        listItem.listImageRowHandler = ^(CPListImageRowItem * item, NSInteger index, dispatch_block_t completionBlock) {
            VLCMLArtist *artist = item.userInfo;
            NSArray *albums = artist.albums;
            if (index < artist.albumsCount) {
                VLCPlaybackService *playbackService = [VLCPlaybackService sharedInstance];
                [playbackService playMediaAtIndex:0 fromCollection:[albums[index] tracks]];
            }
            completionBlock();
        };
        [itemList addObject:listItem];
    }

    return itemList;
}

@end

#pragma clang diagnostic pop
