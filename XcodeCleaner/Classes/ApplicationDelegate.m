/*******************************************************************************
 * Copyright (c) 2010, Jean-David Gadina <macmade@eosgarden.com>
 * Distributed under the Boost Software License, Version 1.0.
 * 
 * Boost Software License - Version 1.0 - August 17th, 2003
 * 
 * Permission is hereby granted, free of charge, to any person or organization
 * obtaining a copy of the software and accompanying documentation covered by
 * this license (the "Software") to use, reproduce, display, distribute,
 * execute, and transmit the Software, and to prepare derivative works of the
 * Software, and to permit third-parties to whom the Software is furnished to
 * do so, all subject to the following:
 * 
 * The copyright notices in the Software and this entire statement, including
 * the above license grant, this restriction and the following disclaimer,
 * must be included in all copies of the Software, in whole or in part, and
 * all derivative works of the Software, unless such copies or derivative
 * works are solely in the form of machine-executable object code generated by
 * a source language processor.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
 * SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
 * FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ******************************************************************************/

/* $Id$ */

#import "ApplicationDelegate.h"
#import "ApplicationDelegate+Private.h"
#import "AboutWindowController.h"
#import "PreferencesWindowController.h"
#import "Preferences.h"

@implementation ApplicationDelegate

@synthesize menu = _menu;

- ( void )dealloc
{
    [ _aboutWindowController        release ];
    [ _preferencesWindowController  release ];
    [ _developerDataPath            release ];
    [ _derivedDataPath              release ];
    
    [ super dealloc ];
}

- ( void )applicationDidFinishLaunching: ( NSNotification * )notification
{
    NSAlert  * alert;
    NSImage  * statusIcon;
    NSImage  * statusIconAlt;
    
    [ Preferences sharedInstance ];
    
    ( void )notification;
    
    _developerDataPath  = [ [ NSHomeDirectory() stringByAppendingPathComponent: @"Library/Developer" ] copy ];
    _derivedDataPath    = [ [ _developerDataPath stringByAppendingPathComponent: @"Xcode/DerivedData" ] copy ];
    
    if( [ [ NSFileManager defaultManager ] fileExistsAtPath: _developerDataPath ] == NO )
    {
        alert = [ NSAlert alertWithMessageText: NSLocalizedString( @"NoXcodeAlertTitle", @"NoXcodeAlertTitle" ) defaultButton: NSLocalizedString( @"OK", @"OK" ) alternateButton: nil otherButton: nil informativeTextWithFormat: NSLocalizedString( @"NoXcodeAlertText", @"NoXcodeAlertText" ) ];
        
        [ alert runModal ];
        [ [ NSApplication sharedApplication ] terminate: nil ];
    }
    
    statusIcon     = [ [ NSImage alloc ] initWithContentsOfFile: [ [ NSBundle mainBundle ] pathForResource: @"Menu-Off" ofType: @"tif" ] ];
    statusIconAlt  = [ [ NSImage alloc ] initWithContentsOfFile: [ [ NSBundle mainBundle ] pathForResource: @"Menu-On" ofType: @"tif" ] ];
    _statusItem    = [ [ [ NSStatusBar systemStatusBar ] statusItemWithLength: NSSquareStatusItemLength  ] retain ];
    
    [ _statusItem setImage: statusIcon ];
    [ _statusItem setAlternateImage: statusIconAlt ];
    [ _statusItem setMenu: _menu ];
    [ _statusItem setHighlightMode: YES ];
    
    [ statusIcon release ];
    [ statusIconAlt release ];
    
    [ NSTimer scheduledTimerWithTimeInterval: 1 target: self selector: @selector( clearData: ) userInfo: nil repeats: YES ];
}

- ( void )applicationWillTerminate: ( NSNotification * )notification
{
    ( void )notification;
    
    if( [ [ Preferences sharedInstance ] clearingType ] == PreferencesClearingTypeOnQuit )
    {
        [ self clearData: nil ];
    }
}

- ( IBAction )showAboutWindow: ( id )sender
{
    if( _aboutWindowController == nil )
    {
        _aboutWindowController = [ AboutWindowController new ];
    }
    
    [ _aboutWindowController.window center ];
    [ _aboutWindowController showWindow: sender ];
}

- ( IBAction )showPreferencesWindow: ( id )sender
{
    if( _preferencesWindowController == nil )
    {
        _preferencesWindowController = [ PreferencesWindowController new ];
    }
    
    [ _preferencesWindowController.window center ];
    [ _preferencesWindowController showWindow: sender ];
}

- ( IBAction )clearData: ( id )sender
{
    BOOL                    isDir;
    NSDirectoryEnumerator * enumerator;
    NSString              * path;
    NSArray               * apps;
    NSRunningApplication  * app;
    
    ( void )sender;
    
    if( [ sender isKindOfClass: [ NSTimer class ] ] )
    {
        if( [ [ Preferences sharedInstance ] clearingType ] == PreferencesClearingTypeOnQuit )
        {
            return;
        }
        else
        {
            apps = [ [ NSWorkspace sharedWorkspace ] runningApplications ];
            
            for( app in apps )
            {
                if( [ app.bundleIdentifier isEqualToString: @"com.apple.dt.Xcode" ] )
                {
                    return;
                }
            }
        }
    }
    
    isDir = NO;
    
    if( [ [ NSFileManager defaultManager ] fileExistsAtPath: _derivedDataPath isDirectory: &isDir ] == NO || isDir == NO )
    {
        return;
    }
    
    enumerator = [ [ NSFileManager defaultManager ] enumeratorAtPath: _derivedDataPath ];
    
    while( ( path = [ enumerator nextObject ] ) )
    {
        [ enumerator skipDescendants ];
        
        path = [ _derivedDataPath stringByAppendingPathComponent: path ];
        
        [ [ NSFileManager defaultManager ] removeItemAtPath: path error: nil ];
    }
}

@end
