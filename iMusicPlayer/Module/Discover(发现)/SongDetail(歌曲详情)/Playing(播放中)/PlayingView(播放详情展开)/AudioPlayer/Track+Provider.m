/* vim: set ft=objc fenc=utf-8 sw=2 ts=2 et: */
/*
 *  DOUAudioStreamer - A Core Audio based streaming audio player for iOS/Mac:
 *
 *      https://github.com/douban/DOUAudioStreamer
 *
 *  Copyright 2013-2016 Douban Inc.  All rights reserved.
 *
 *  Use and distribution licensed under the BSD license.  See
 *  the LICENSE file for full text.
 *
 *  Authors:
 *      Chongyu Zhu <i@lembacon.com>
 *
 */

#import "Track+Provider.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation Track (Provider)

+ (void)load
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [self remoteTracks];
  });

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [self musicLibraryTracks];
  });
}

+ (NSArray *)remoteTracks
{
  static NSArray *tracks = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
//    http://cache.musicz.co/youtube/0c624df9-035a-4591-a4d7-c7f26b06a106_MMC5uPURHUs.mp3
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://douban.fm/j/mine/playlist?type=n&channel=1004693&from=mainsite"]];
//      NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://cache.musicz.co/youtube/0c624df9-035a-4591-a4d7-c7f26b06a106_MMC5uPURHUs.mp3"]];
      
//    NSData *data = [NSURLConnection sendSynchronousRequest:request
//                                         returningResponse:NULL
//                                                     error:NULL];
//    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
//
//    NSMutableArray *allTracks = [NSMutableArray array];
//    for (NSDictionary *song in [dict objectForKey:@"song"]) {
//      Track *track = [[Track alloc] init];
//      [track setArtist:[song objectForKey:@"artist"]];
//      [track setTitle:[song objectForKey:@"title"]];
//      [track setAudioFileURL:[NSURL URLWithString:[song objectForKey:@"url"]]];
//      [allTracks addObject:track];
//    }
//
//    tracks = [allTracks copy];
      
    Track *track = [[Track alloc] init];
    [track setArtist: @"artist"];
    [track setTitle: @"title"];
    [track setAudioFileURL:[NSURL URLWithString: @"http://cache.musicz.co/youtube/0c624df9-035a-4591-a4d7-c7f26b06a106_MMC5uPURHUs.mp3"]];
    
      
      Track *track1 = [[Track alloc] init];
      [track1 setArtist: @"artist1"];
      [track1 setTitle: @"title1"];
      [track1 setAudioFileURL:[NSURL URLWithString: @"http://cache.musicfm.co/music/mp3/83416058585175011040690740145157.mp3"]];
      
      NSMutableArray *allTracks = [NSMutableArray array];
      [allTracks addObject:track];
      [allTracks addObject:track1];
      tracks = [allTracks copy];
      
  });

  return tracks;
}

+ (NSArray *)musicLibraryTracks
{
  static NSArray *tracks = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSMutableArray *allTracks = [NSMutableArray array];
    for (MPMediaItem *item in [[MPMediaQuery songsQuery] items]) {
      if ([[item valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]) {
        continue;
      }

      Track *track = [[Track alloc] init];
      [track setArtist:[item valueForProperty:MPMediaItemPropertyArtist]];
      [track setTitle:[item valueForProperty:MPMediaItemPropertyTitle]];
      [track setAudioFileURL:[item valueForProperty:MPMediaItemPropertyAssetURL]];
      [allTracks addObject:track];
    }

    for (NSUInteger i = 0; i < [allTracks count]; ++i) {
      NSUInteger j = arc4random_uniform((u_int32_t)[allTracks count]);
      [allTracks exchangeObjectAtIndex:i withObjectAtIndex:j];
    }

    tracks = [allTracks copy];
  });

  return tracks;
}

@end
