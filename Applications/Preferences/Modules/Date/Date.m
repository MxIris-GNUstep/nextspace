/* -*- mode: objc -*- */
//
// Project: Preferences
//
// Copyright (C) 2014-2019 Sergii Stoian
// Copyright (C) 2022-2023 Andres Morales
//
// This application is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License as published by the Free Software Foundation; either
// version 2 of the License, or (at your option) any later version.
//
// This application is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Library General Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with this library; if not, write to the Free
// Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
//

#import "Date.h"
#include "ClockView.h"

@implementation Date

- (id)init
{
  NSString *imagePath;
  NSBundle *bundle;

  self = [super init];

  bundle = [NSBundle bundleForClass:[self class]];
  imagePath = [bundle pathForResource:@"Date" ofType:@"tiff"];
  image = [[NSImage alloc] initWithContentsOfFile:imagePath];

  defaults = [NXTDefaults globalUserDefaults];

  return self;
}

- (void)dealloc
{
  NSLog(@"Date -dealloc");
  [image release];

  if (view) {
    [view release];
  }

  [super dealloc];
}

- (void)awakeFromNib
{
  NSDictionary *cvdisplayRects;
  NSCalendarDate *nowDate = [NSCalendarDate now];

  [view retain];
  [window release];

  // Clock view
  cvdisplayRects = @{
    @"DayOfWeek" : NSStringFromRect(NSMakeRect(14, 33, 33, 6)),
    @"Day" : NSStringFromRect(NSMakeRect(14, 15, 33, 17)),
    @"Month" : NSStringFromRect(NSMakeRect(14, 9, 31, 6)),
    @"Time" : NSStringFromRect(NSMakeRect(5, 46, 53, 11))
  };
  [clockView setTileImage:[NSImage imageNamed:@"ClockViewTile"]];
  [clockView setDisplayRects:cvdisplayRects];
  [clockView setYearVisible:NO];
  [clockView setCalendarDate:nowDate];

  [hour24Button setIntValue:[clockView is24HourFormat] ? 1 : 0];

  [timeField
      setStringValue:[NSString stringWithFormat:@"%lu:%lu:%lu", nowDate.hourOfDay,
                                                nowDate.minuteOfHour, nowDate.secondOfMinute]];
}

- (NSView *)view
{
  if (view == nil) {
    if (![NSBundle loadNibNamed:@"Date" owner:self]) {
      NSLog(@"Date.preferences: Could not load NIB, aborting.");
      return nil;
    }
  }
  return view;
}

- (NSString *)buttonCaption
{
  return @"Date & Time Preferences";
}

- (NSImage *)buttonImage
{
  return image;
}

- (void)change24Hour:(id)sender
{
  BOOL flag = [sender integerValue] ? YES : NO;

  [defaults setBool:flag forKey:NXTClockView24HourFormat];
}

- (void)increaseFieldAction:(id)sender
{
}

- (void)decreaseFieldAction:(id)sender
{
}

- (void)changeClockFaceAction:(id)sender
{
}

- (void)selectRegionAction:(id)sender
{
}

- (void)setTimeAction:(id)sender
{
}

- (void)timeManuallyChangedAction:(id)sender
{
}

@end
