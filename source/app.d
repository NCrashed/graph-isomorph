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

import gui.evolution;
import gui.results;
import gui.settings;

enum helpMsg = 
"graph-isomorph [options]

options:  --gui=<path> - path to glade file. Optional, default is 'gui.glade'.
          --log=<path> - path to log file. Optional, default is 'graph-isomorph.log'.
          --help       - display the message.";

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
	
	if(help)
	{
	    writeln(helpMsg);
	    return;
	}
	
	Main.initMultiThread(args);
	
	auto application = new Application(logFile, gladeFile);
	scope(exit) application.finalize();
    
	Main.run();
}

class Application
{
    shared ILogger logger;
    SettingsWindow settingsWindow;
    EvolutionWindow evolutionWindow;
    ResultsWindow resultsWindow;
    
    this(string logFile, string gladeFile)
    {
        logger = new shared StrictLogger(logFile);
   
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
        
        settingsWindow = new SettingsWindow(builder, logger, settingsWnd, evolutionWnd, resultsWnd);
        evolutionWindow = new EvolutionWindow(builder, logger, settingsWnd, evolutionWnd, resultsWnd);
        resultsWindow = new ResultsWindow(builder, logger, settingsWnd, evolutionWnd, resultsWnd);
    }
    
    void finalize()
    {
        logger.finalize();
    }
}