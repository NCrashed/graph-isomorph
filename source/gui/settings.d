/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module gui.settings;

import gtk.Builder;
import gtk.MenuItem;
import gtk.ApplicationWindow;
import gui.util;

import dlogg.log;

import evol.progtype;

class SettingsWindow
{
    ProgramType progt;
    ApplicationWindow window;
    shared ILogger logger;
    
    this(Builder builder, shared ILogger logger
        , ApplicationWindow settingsWindow
        , ApplicationWindow evoluitionWindow
        , ApplicationWindow resultsWindow)
    {
        this.window = settingsWindow;
        this.logger = logger;
        
        settingsWindow.showAll();
        settingsWindow.addOnHide( (w) => onWindowHideShow(AppWindow.Settings, true) );
        settingsWindow.addOnShow( (w) => onWindowHideShow(AppWindow.Settings, false) );
        settingsWindow.addOnDelete( (e, w) { settingsWindow.hide; return true; } );
        
        auto showEvolutionWndItem = cast(MenuItem)builder.getObject("ShowEvolutionWndItem1");
        if(showEvolutionWndItem is null)
        {
            logger.logError("SettingsWnd: failed to get show evolution wnd item!");
            assert(false);
        }
        showEvolutionWndItem.addOnActivate( (w) => evoluitionWindow.showAll() );
        
        auto showResultsWndItem = cast(MenuItem)builder.getObject("ShowResultsWndItem1");
        if(showResultsWndItem is null)
        {
            logger.logError("SettingsWnd: failed to get show results wnd item!");
            assert(false);
        }
        showResultsWndItem.addOnActivate( (w) => resultsWindow.showAll() );
        
        progt = new ProgramType();
    }
    
    void initProgtypeEntries()
    {
        
    }
}