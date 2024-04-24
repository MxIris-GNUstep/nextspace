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

#import "Services.h"

@implementation Services

static NSBundle *bundle = nil;

- (id)init
{
  self = [super init];
  
  bundle = [NSBundle bundleForClass:[self class]];
  NSString *imagePath = [bundle pathForResource:@"Services" ofType:@"tiff"];
  image = [[NSImage alloc] initWithContentsOfFile:imagePath];
      
  return self;
}

- (void)dealloc
{
  [image release];
  [super dealloc];
}

- (void)_updateAllServices
{
  NSString *_servicesPath;
  NSDictionary *_allServices = nil;

  _servicesPath = [NSHomeDirectory() stringByAppendingString:@"/Library/Services/.GNUstepServices"];

  if ([[NSFileManager defaultManager] fileExistsAtPath:_servicesPath]) {
    NSData *data = [NSData dataWithContentsOfFile:_servicesPath];

    if (data) {
      id plist = [NSDeserializer deserializePropertyListFromData:data mutableContainers:YES];
      if (plist) {
        [[NSDictionary dictionaryWithDictionary:plist] writeToFile:@"SERVICES.plist"
                                                        atomically:YES];
        _allServices =
            [[NSDictionary alloc] initWithDictionary:[plist valueForKeyPath:@"ByService.default"]];
        ASSIGN(allServices, _allServices);
        [_allServices release];
      }
    }
  }

  return;
}

- (void)_updateDisabledServices
{
  NSString *_disabledPath;
  NSArray *_disabledServices = nil;

  _disabledPath = [NSHomeDirectory() stringByAppendingString:@"/Library/Services/.GNUstepDisabled"];

  if ([[NSFileManager defaultManager] fileExistsAtPath:_disabledPath]) {
    NSData *data = [NSData dataWithContentsOfFile:_disabledPath];

    if (data) {
      id plist = [NSDeserializer deserializePropertyListFromData:data mutableContainers:NO];
      if (plist) {
        NSLog(@"Disabled SERVICES: %@", plist);
        _disabledServices = [[NSArray alloc] initWithArray:plist];
        ASSIGN(disabledServices, _disabledServices);
        [_disabledServices release];
      }
    }
  }
}


- (void)_fetchServices
{
  NSString *appName;
  NSMutableDictionary *applications = [NSMutableDictionary new];
  NSMutableArray *appServicesList;

  [self _updateAllServices];
  [self _updateDisabledServices];

  for (NSDictionary *svc in [allServices allValues]) {
    appName = [svc valueForKey:@"NSPortName"];
    appServicesList = [applications objectForKey:appName];

    if (appServicesList == nil) {
      appServicesList = [NSMutableArray new];
      [appServicesList addObject:svc];
      [applications setObject:appServicesList forKey:appName];
      [appServicesList release];
    } else {
      [appServicesList addObject:svc];
      [applications setObject:appServicesList forKey:appName];
    }
  }

  ASSIGN(services, applications);
  [applications release];
}

- (void)awakeFromNib
{
  [view retain];
  [window release];

  serviceManager = [GSServicesManager manager];
  [serviceManager rebuildServices];
  [self _fetchServices];
  [servicesList loadColumnZero];
}

- (NSView *)view
{
  if (view == nil) {
    if (![NSBundle loadNibNamed:@"Services" owner:self]) {
      NSLog(@"Services.preferences: Could not load NIB, aborting.");
      return nil;
    }
  }

  return view;
}

- (NSString *)buttonCaption
{
  return @"Services Preferences";
}

- (NSImage *)buttonImage
{
  return image;
}

//
// Action methods
//

#pragma mark - Button

- (void)setServiceState:(id)sender
{
  NSString *selected = nil;
  NSString *selectedPath = [servicesList path];

  if ([servicesList selectedColumn] == 1) {
    NSDictionary *service = [[servicesList selectedCellInColumn:1] representedObject];
    selected = [service valueForKeyPath:@"NSMenuItem.default"];
    NSLog(@"Setting state to service: %@", selected);
    [serviceManager setShowsServicesMenuItem:selected
                                          to:![serviceManager showsServicesMenuItem:selected]];
  } else {
    NSString *appName = [[servicesList selectedCellInColumn:0] title];
    NSArray *appServices = [services objectForKey:appName];
    for (NSDictionary *service in appServices) {
      selected = [service valueForKeyPath:@"NSMenuItem.default"];
      [serviceManager setShowsServicesMenuItem:selected
                                            to:![serviceManager showsServicesMenuItem:selected]];
    }
  }

  [self _fetchServices];
  [servicesList reloadColumn:[servicesList selectedColumn]];
  [(NSBrowser *)servicesList setPath:selectedPath];
  [self serviceListClicked:servicesList];
}

- (void)serviceListClicked:(id)sender
{
  NSLog(@"Service LIst clicked: %@", [sender className]);
  NSBrowser *browser = sender;
  NSUInteger col = [browser selectedColumn];

  if (col == 1) {
    NSDictionary *svc = [[browser selectedCellInColumn:col] representedObject];
    NSString *menuItem = [svc valueForKeyPath:@"NSMenuItem.default"];
    if ([disabledServices doesContain:menuItem]) {
      [actionButton setTitle:@"Enable"];
    } else {
      [actionButton setTitle:@"Disable"];
    }
  }
}

#pragma mark - Browser

- (NSString *)menuItemForService:(NSDictionary *)svc level:(int)level
{
  NSString *itemTitle = [svc valueForKeyPath:@"NSMenuItem.default"];
  NSArray *components = [itemTitle pathComponents];

  if (components.count == 0) {
    return nil;
  }

  return components[level];
}

- (BOOL)menuItemIsOnly:(NSArray *)svc
{
  if ([svc count] > 1) {
    return NO;
  } else {
    NSDictionary *service = svc[0];
    NSString *serviceTitle = [service valueForKeyPath:@"NSMenuItem.default"];
    if ([serviceTitle pathComponents].count > 1) {
      return NO;
    }
  }
  return YES;
}

- (void)browser:(NSBrowser *)browser
    willDisplayCell:(NSBrowserCell *)cell
              atRow:(NSInteger)row
             column:(NSInteger)col
{
  if (col == 0) {
    NSArray *apps = [services allKeys];
    NSArray *appServices = services[apps[row]];

    [cell setStringValue:[self menuItemForService:appServices[0] level:0]];
    [cell setLeaf:[self menuItemIsOnly:appServices]];
    [cell setRepresentedObject:appServices];
  } else {
    NSArray *appServices = [[browser selectedCellInColumn:0] representedObject];
    NSDictionary *svc = [appServices objectAtIndex:row];

    [cell setStringValue:[self menuItemForService:svc level:1]];
    // [cell setEnabled:[serviceManager
    //                      showsServicesMenuItem:[svc valueForKeyPath:@"NSMenuItem.default"]]];
    [cell setLeaf:YES];
    [cell setRepresentedObject:svc];
  }
  [cell setRefusesFirstResponder:YES];
}

- (NSInteger)browser:(NSBrowser *)browser numberOfRowsInColumn:(NSInteger)col
{
  if (col == 0) {
    return [services count];
  } else {
    NSString *appName = [[browser selectedCellInColumn:0] stringValue];
    return [[services objectForKey:appName] count];
  }
}

@end

