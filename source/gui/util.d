/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module gui.util;

import gtk.ApplicationWindow;
import gtk.Main;

enum AppWindow
{
    Settings,
    Evolution,
    Results
}

void onWindowHideShow(AppWindow type, bool isClosed)
{
    static bool settingsClosed = false;
    static bool evolutionClosed = true;
    static bool resultsClosed = true;
    
    final switch(type)
    {
        case(AppWindow.Settings): settingsClosed = isClosed; break;
        case(AppWindow.Evolution): evolutionClosed = isClosed; break;
        case(AppWindow.Results): resultsClosed  = isClosed; break;
    } 
    
    if(settingsClosed && evolutionClosed && resultsClosed)
    {
        Main.quit();
    }
}