/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module app;

import gtk.Builder;
import gtk.Button;
import gtk.Main;
import gtk.Widget;
import gtk.ApplicationWindow;
import gtk.MenuItem;
import gobject.Type;

import std.stdio;
import std.getopt;
import std.c.process;

import dlogg.strict;

enum helpMsg = 
"graph-isomorph [options]

options:  --gui=<path> - path to glade file. Optional, default is 'gui.glade'.
          --log=<path> - path to log file. Optional, default is 'graph-isomorph.log'.
          --help       - display the message.";

shared ILogger logger;

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

void setupSettingsWindow(Builder builder
    , ApplicationWindow settingsWindow
    , ApplicationWindow evoluitionWindow
    , ApplicationWindow resultsWindow)
{
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
}

void setupEvolutionWindow(Builder builder
    , ApplicationWindow settingsWindow
    , ApplicationWindow evoluitionWindow
    , ApplicationWindow resultsWindow)
{
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
}

void setupResultsWindow(Builder builder
    , ApplicationWindow settingsWindow
    , ApplicationWindow evoluitionWindow
    , ApplicationWindow resultsWindow)
{
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
}

void main(string[] args)
{
	string gladeFile = "./gui.glade";
	string logFile = "./graph-isomorph.log";
	
	bool help = false;
	getopt(args,
	    "gui", &gladeFile,
	    "log", &logFile,
	    "help", &help
	);
	
	logger = new shared StrictLogger(logFile);
	scope(exit) logger.finalize();
	
	if(help)
	{
	    writeln(helpMsg);
	    return;
	}
	
	logger.logDebug("Initing gtk-d...");
	Main.initMultiThread(args);
	
	Builder builder = new Builder();
	if( !builder.addFromFile(gladeFile) )
	{
	    logger.logError(text("Failed to create gui from glade file '", gladeFile, "'!"));
	    return;
	}
	
	auto settingsWnd = cast(ApplicationWindow)builder.getObject("SettingsWindow");
	if(settingsWnd is null)
	{
	    logger.logError("Failed to create settings window!");
	    return;
	}
	
	auto evolutionWnd = cast(ApplicationWindow)builder.getObject("EvolutionWindow");
    if(evolutionWnd is null)
    {
        logger.logError("Failed to create evolution window!");
        return;
    }
    
    auto resultsWnd = cast(ApplicationWindow)builder.getObject("ResultsWindow");
    if(resultsWnd is null)
    {
        logger.logError("Failed to create results window!");
        return;
    }
    
    setupSettingsWindow(builder, settingsWnd, evolutionWnd, resultsWnd);
    setupEvolutionWindow(builder, settingsWnd, evolutionWnd, resultsWnd);
    setupResultsWindow(builder, settingsWnd, evolutionWnd, resultsWnd);
    
	Main.run();
}