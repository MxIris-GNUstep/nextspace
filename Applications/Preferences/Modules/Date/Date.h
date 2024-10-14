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

#import <AppKit/AppKit.h>
#import <Preferences.h>
#import <DesktopKit/NXTClockView.h>

@interface Date : NSObject <PrefsModule>
{
  IBOutlet NSWindow *window;
  IBOutlet NSView *view;
  IBOutlet NXTClockView *clockView;
  IBOutlet NSImageView *clockViewBackground;
  id timeZoneSelectorView;
  id timeZoneRegionSelectorPopUpButton;
  NSImage *image;
  NSImage *handImage;
}

- (void)change24Hour:(id)sender;

- (void)increaseFieldAction:(id)sender;
- (void)decreaseFieldAction:(id)sender;
- (void)changeClockFaceAction:(id)sender;
- (void)selectRegionAction:(id)sender;
- (void)setTimeAction:(id)sender;
- (void)timeManuallyChangedAction:(id)sender;

@end
