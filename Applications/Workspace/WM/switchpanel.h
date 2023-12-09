/*
 *  Workspace window manager
 *  Copyright (c) 2015-2021 Sergii Stoian
 *
 *  Window Maker window manager
 *  Copyright (c) 1997-2004 Alfredo K. Kojima
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef __WORKSPACE_WM_SWITCHPANEL__
#define __WORKSPACE_WM_SWITCHPANEL__

#include "screen.h"
#include "window.h"

typedef struct SwitchPanel WSwitchPanel;

WSwitchPanel *wInitSwitchPanel(WScreen *scr, struct WWindow *curwin);

void wSwitchPanelDestroy(WSwitchPanel *panel);

struct WWindow *wSwitchPanelSelectNext(WSwitchPanel *panel, int back, int ignore_minimized);
struct WWindow *wSwitchPanelSelectFirst(WSwitchPanel *panel, int back);

struct WWindow *wSwitchPanelHandleEvent(WSwitchPanel *panel, XEvent *event);

Window wSwitchPanelGetWindow(WSwitchPanel *swpanel);

void wSwitchPanelStart(WWindow *wwin, XEvent *event, Bool next);

#endif /* __WORKSPACE_WM_SWITCHPANEL__ */
