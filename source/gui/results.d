/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module gui.results;

import gtk.Builder;
import gtk.MenuItem;
import gtk.ApplicationWindow;

import gui.util;
import gui.generic;

import dlogg.log;

import project;

class ResultsWindow : GenericWindow
{  
    this(Builder builder, shared ILogger logger
        , Project project
        , ApplicationWindow settingsWindow
        , ApplicationWindow evoluitionWindow
        , ApplicationWindow resultsWindow)
    {
        super(builder, logger, project, resultsWindow);
        
        resultsWindow.hide();
        resultsWindow.addOnHide( (w) => onWindowHideShow(AppWindow.Results, true) );
        resultsWindow.addOnShow( (w) => onWindowHideShow(AppWindow.Results, false) );
        resultsWindow.addOnDelete( (e, w) { resultsWindow.hide; return true; } );
        
        auto showSettingsWndItem = cast(MenuItem)builder.getObject("ShowSettingsWndItem3");
        if(showSettingsWndItem is null)
        {
            logger.logError("ResultsWnd: failed to get show settings wnd item!");
            assert(false);
        }
        showSettingsWndItem.addOnActivate( (w) => settingsWindow.showAll() );
        
        auto showEvolutionWndItem = cast(MenuItem)builder.getObject("ShowEvolutionWndItem3");
        if(showEvolutionWndItem is null)
        {
            logger.logError("ResultsWnd: failed to get show evolution wnd item!");
            assert(false);
        }
        showEvolutionWndItem.addOnActivate( (w) => evoluitionWindow.showAll() );
        
        initProjectSaveLoad("3");
    }
    
    override void updateContent()
    {
        
    }
}