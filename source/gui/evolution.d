/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module gui.evolution;

import gtk.Builder;
import gtk.MenuItem;
import gtk.ApplicationWindow;

import gui.util;
import gui.generic;

import dlogg.log;

import project;

class EvolutionWindow : GenericWindow
{
    this(Builder builder, shared ILogger logger
        , Project project
        , ApplicationWindow settingsWindow
        , ApplicationWindow evoluitionWindow
        , ApplicationWindow resultsWindow)
    {
        super(builder, logger, project, evoluitionWindow);
        
        evoluitionWindow.hide();
        evoluitionWindow.addOnHide( (w) => onWindowHideShow(AppWindow.Evolution, true) );
        evoluitionWindow.addOnShow( (w) => onWindowHideShow(AppWindow.Evolution, false) );
        evoluitionWindow.addOnDelete( (e, w) { evoluitionWindow.hide; return true; } );
        
        auto showSettingsWndItem = cast(MenuItem)builder.getObject("ShowSettingsWndItem2");
        if(showSettingsWndItem is null)
        {
            logger.logError("EvolutionWnd: failed to get show settings wnd item!");
            assert(false);
        }
        showSettingsWndItem.addOnActivate( (w) => settingsWindow.showAll() );
        
        auto showResultsWndItem = cast(MenuItem)builder.getObject("ShowResultsWndItem2");
        if(showResultsWndItem is null)
        {
            logger.logError("EvolutionWnd: failed to get show results wnd item!");
            assert(false);
        }
        showResultsWndItem.addOnActivate( (w) => resultsWindow.showAll() ); 
        
        initProjectSaveLoad("2");
    }
}