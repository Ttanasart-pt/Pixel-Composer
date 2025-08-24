/*

 MIT License

 Copyright © 2021 Samuel Venable
 Copyright © 2021 babyjeans <twitter.com/babyj3ans>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

*/

#include <map>
#include <Cocoa/Cocoa.h>
#define EXPORTED_FUNCTION extern "C" __attribute__((visibility("default")))
std::map<NSWindow *, NSWindowStyleMask> style;
@interface NSWindow(subclass)
-(BOOL)canBecomeKeyWindow;
-(BOOL)canBecomeMainWindow;
@end
@implementation NSWindow(subclass)
-(BOOL)canBecomeKeyWindow{return YES;}
-(BOOL)canBecomeMainWindow{return YES;}
@end

static void simulate_click_in_window(NSWindow *w) {
  NSEvent *event = [NSEvent mouseEventWithType:NSEventTypeLeftMouseDown location:
  NSMakePoint(w.frame.size.width / 2, w.frame.size.height / 2) modifierFlags:0 timestamp:0 
  windowNumber:[w windowNumber] context:nil eventNumber:0 clickCount:1 pressure:1.0]; 
  [w sendEvent:event];
} 

EXPORTED_FUNCTION double window_get_showborder(void *window) {
  NSWindow *w = (NSWindow *)window;
  return ([w styleMask] != NSWindowStyleMaskBorderless);
}

EXPORTED_FUNCTION double window_set_showborder(void *window, double showborder) {
  NSWindow *w = (NSWindow *)window;
  if (!showborder && window_get_showborder(window)) {
    if (style.find(w) != style.end()) {
      style.insert(std::make_pair(w, [w styleMask]));
    } else {
      style[w] = [w styleMask];
    }
    [w setStyleMask:NSWindowStyleMaskBorderless];
    simulate_click_in_window(w);
  } else if (!window_get_showborder(window)) {
    [w setStyleMask:style[w] & ~NSWindowStyleMaskBorderless];
    simulate_click_in_window(w);
  }
  return 0;
}
