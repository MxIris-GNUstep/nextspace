/*
  Class:               NXAlert
  Inherits from:       NSObject
  Class descritopn:    This implementation of alert panel was created
                       in attempt to mimic the behaviour of OPENSTEP's one.
                       This behaviour can be described as following:
                       - panel width is not changing on autosizing;
                       - panel height is automatically changed but cannot be
                         more than half of screen (2/4 of screen);
                       - top edge of panel automatically placed on the center
                         of topmost 1/4 of screen height;
                       - panel brings application in front of other applications;
                       Such hard limits of panel resizing was set up to push
                       developers make some attention to desing of attantion
                       panels conforming to "NeXT User Interface Guidelines".

  Copyright (C) 2016 Sergii Stoian

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#import <NXSystem/NXScreen.h>
#import "NXAlert.h"

@implementation NXAlert

// For exceptions loading GORM file is not an option (test in progress)
- (void)createPanel
{
  NSBox *horizontalLine;

  panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(100,100,360,193)
                                     styleMask:NSTitledWindowMask
                                       backing:NSBackingStoreRetained
                                         defer:NO];
  [panel setReleasedWhenClosed:YES];
  // [panel setAutoresizingMask:(NSViewMaxXMargin | NSViewMinYMargin
  //                             | NSViewWidthSizable)];
  
  icon = [[NSImageView alloc] initWithFrame:NSMakeRect(8,106,48,48)];
  [icon setAutoresizingMask:(NSViewMaxXMargin | NSViewMaxYMargin)];
  [icon setImage:[NSApp applicationIconImage]];
  [[panel contentView] addSubview:icon];
  [icon release];
  
  titleField = [[NSTextField alloc] initWithFrame:NSMakeRect(64,119,289,22)];
  [titleField setAutoresizingMask:(NSViewMaxYMargin | NSViewWidthSizable)];
  [titleField setStringValue:@"Your attention needed"];
  [titleField setFont:[NSFont systemFontOfSize:20.0]];
  [titleField setEditable:NO];
  [titleField setSelectable:YES];
  [titleField setBezeled:NO];
  [titleField setBordered:NO];
  [[panel contentView] addSubview:titleField];
  [titleField release];

  horizontalLine = [[NSBox alloc] initWithFrame:NSMakeRect(-2,96,364,2)];
  [horizontalLine setTitlePosition:NSNoTitle];
  [[panel contentView] addSubview:horizontalLine];
  [horizontalLine release];
  
  messageField = [[NSTextField alloc] initWithFrame:NSMakeRect(8,56,344,17)];
  [messageField setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
  [messageField setStringValue:@"Do you really want to do something serious?"];
  [messageField setFont:[NSFont systemFontOfSize:14.0]];
  [messageField setEditable:NO];
  [messageField setSelectable:YES];
  [messageField setBezeled:NO];
  [messageField setBordered:NO];
  [[panel contentView] addSubview:messageField];
  [messageField release];
  
  defaultButton = [[NSButton alloc] initWithFrame:NSMakeRect(280,8,72,24)];
  [defaultButton setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
  [defaultButton setTarget:panel];
  [defaultButton setAction:@selector(performClose:)];
  [[panel contentView] addSubview:defaultButton];
  [defaultButton release];
  
  alternateButton = [[NSButton alloc] initWithFrame:NSMakeRect(203,8,72,24)];
  [alternateButton setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
  [alternateButton setTarget:panel];
  [alternateButton setAction:@selector(performClose:)];
  [[panel contentView] addSubview:alternateButton];
  [alternateButton release];
  
  otherButton = [[NSButton alloc] initWithFrame:NSMakeRect(126,8,72,24)];
  [otherButton setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
  [otherButton setTarget:panel];
  [otherButton setAction:@selector(performClose:)];
  [[panel contentView] addSubview:otherButton];
  [otherButton release];

  [panel setDefaultButtonCell:[defaultButton cell]];

  [self awakeFromNib];
}

- (void)setTitle:(NSString *)titleText
         message:(NSString *)messageText
       defaultBT:(NSString *)defaultText
     alternateBT:(NSString *)alternateText
         otherBT:(NSString *)otherText
{
  NSLog(@"NXAlert: setTitle... START");
  [titleField setStringValue:titleText];
  [defaultButton setTitle:defaultText];

  if (alternateText == nil)
    [alternateButton removeFromSuperview];
  else
    [alternateButton setTitle:alternateText];

  if (otherText == nil)
    [otherButton removeFromSuperview];
  else
    [otherButton setTitle:otherText];

  [messageField setStringValue:messageText];
  if ([messageText rangeOfString: @"\n"].location != NSNotFound)
    {
      [messageField setAlignment:NSLeftTextAlignment];
    }
  else
    {
      [messageField setAlignment:NSCenterTextAlignment];
    }
  NSLog(@"NXAlert: setTitle... START");
}

- (void)show
{
  [panel makeKeyAndOrderFront:self];
}

//--- Normal Altert Panel

- (id)initWithTitle:(NSString *)titleText
            message:(NSString *)messageText
      defaultButton:(NSString *)defaultText
    alternateButton:(NSString *)alternateText
        otherButton:(NSString *)otherText
{
  if ([super init] == nil)
    {
      return nil;
    }
  
  if (![NSBundle loadNibNamed:@"NXAlertPanel" owner:self])
    {
      NSLog(@"Cannot open NXAlertPanel model file!");
      return nil;
    }
  
  [titleField setStringValue:titleText];
  [icon setImage:[NSApp applicationIconImage]];
  [defaultButton setTitle:defaultText];

  if (alternateText == nil)
    [alternateButton removeFromSuperview];
  else
    [alternateButton setTitle:alternateText];

  if (otherText == nil)
    [otherButton removeFromSuperview];
  else
    [otherButton setTitle:otherText];

  [messageField setStringValue:messageText];
  if ([messageText rangeOfString: @"\n"].location != NSNotFound)
    {
      [messageField setAlignment:NSLeftTextAlignment];
    }
  else
    {
      [messageField setAlignment:NSCenterTextAlignment];
    }
  
  return self;
}

- (void)awakeFromNib
{
  [titleField setRefusesFirstResponder:YES];
  [messageField setRefusesFirstResponder:YES];
}

- (void)sizeToFit
{
  NSRect panelFrame = [panel frame];
  // Buttons

  // Message field
  // NSArray  *messageLines = [[messageField stringValue] componentsSeparatedByString:@"\n"];
  // NSString *s1, *s2;
  CGFloat  fieldWidth, textWidth;
  NSInteger linesNum;
  NSFont   *font = [messageField font];
  // CGFloat  lineHeight = [font boundingRectForFont].size.height + 2;
  CGFloat  lineHeight = [font defaultLineHeightForFont] + 1;
  
  fieldWidth = [messageField bounds].size.width;
  textWidth = [font widthOfString:[messageField stringValue]];
  linesNum = (textWidth/fieldWidth);

  // Set height of panel to the minimum size
  panelFrame.size.height = 0;
  [panel setFrame:panelFrame display:NO];
  panelFrame = [panel frame];
  
  if (linesNum > 1)
    {
      NSRect frame = [messageField frame];
      frame.origin.y -= lineHeight/2;
      frame.size.height += lineHeight;
      [messageField setFrame:frame];
      [messageField setAlignment:NSLeftTextAlignment];
      
      panelFrame.size.height += (lineHeight * (linesNum - 1));
      [panel setFrame:panelFrame display:NO];
    }
  else
    {
      [messageField setAlignment:NSCenterTextAlignment];      
    }
  
  // for (NSString *l in messageLines)
  //   {
  //     if ([font widthOfString:l] > fieldWidth)
  //       {
  //         while ([font widthOfString:l] > fieldWidth)
  //           {
  //             s1 = [l substringWithRange:NSMakeRange(0, [l length]/2)];
  //             s2 = [l substringWithRange:NSMakeRange([l length]/2, [l length]/2 - 1)];
  //           }
  //         // found line wider then message field
  //       }
  //   }

  // Buttons
  // [defaultButton sizeToFit];
  // [alternateButton sizeToFit];
  // [otherButton sizeToFit];
}

- (NSInteger)runModal
{
  NSInteger result;
  NSSize  screenSize = [[NXScreen sharedScreen] sizeInPixels];
  NSPoint panelOrigin;
  
  [self sizeToFit];
  [panel center];

  // Place panel at top half of main display
  panelOrigin = [panel frame].origin;
  panelOrigin.y =
    (screenSize.height - screenSize.height/4) - [panel frame].size.height;
  [panel setFrameOrigin:panelOrigin];
  [panel makeFirstResponder:defaultButton];
  
  [panel makeKeyAndOrderFront:self];
  result = [NSApp runModalForWindow:panel];
  [panel orderOut:self];
  
  return result;
}

- (void)buttonPressed:(id)sender
{
  if ([NSApp modalWindow] != panel)
    {
      NSLog(@"NXAalert panel button pressed when not in modal loop.");
      return;
    }
  
  [NSApp stopModalWithCode:[sender tag]];
}

@end

void NXRunExceptionPanel(NSString *title,
                         NSString *msg,
                         NSString *defaultButton,
                         NSString *alternateButton,
                         NSString *otherButton, ...)
{
  va_list    ap;
  NSString  *message;
  NXAlert   *excPanel;
  NSInteger result;

  va_start(ap, otherButton);
  message = [NSString stringWithFormat:msg arguments:ap];
  va_end(ap);

  if (NSApp == nil)
    {
      // No NSApp ... not running in a gui application so just log.
      NSLog(@"%@", message);
      return;
    }
  
  if (defaultButton == nil)
    {
      defaultButton = @"OK";
    }

  excPanel = [[NXAlert alloc] init];
  [excPanel createPanel];
  [excPanel setTitle:title
             message:msg
           defaultBT:defaultButton
         alternateBT:alternateButton
             otherBT:otherButton];
  [excPanel show];
}

NSInteger NXRunAlertPanel(NSString *title,
                          NSString *msg,
                          NSString *defaultButton,
                          NSString *alternateButton,
                          NSString *otherButton, ...)
{
  va_list    ap;
  NSString  *message;
  NXAlert   *alrtPanel;
  NSInteger result;

  va_start(ap, otherButton);
  message = [NSString stringWithFormat:msg arguments:ap];
  va_end(ap);

  if (NSApp == nil)
    {
      // No NSApp ... not running in a gui application so just log.
      NSLog(@"%@", message);
      return NSAlertDefaultReturn;
    }
  
  if (defaultButton == nil)
    {
      defaultButton = @"OK";
    }

  alrtPanel = [[NXAlert alloc] initWithTitle:title
                                     message:message
                               defaultButton:defaultButton
                             alternateButton:alternateButton
                                 otherButton:otherButton];

  result = [alrtPanel runModal];
  [alrtPanel release];
  
  return result;
}
