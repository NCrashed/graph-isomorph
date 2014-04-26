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
import std.file;

import dlogg.strict;

import gui.evolution;
import gui.results;
import gui.settings;

import project;

enum helpMsg = 
"graph-isomorph [options]

options:  --gui=<path>  - path to glade file. Optional, default is 'gui.glade'.
          --log=<path>  - path to log file. Optional, default is 'graph-isomorph.log'.
          --proj=<path> - path to project file. Optional, default is '"~Project.defaultProjectPath~"'. 
          --help        - display the message.";

void main(string[] args)
{
	string gladeFile = "./gui.glade";
	string logFile = "./graph-isomorph.log";
	string projFile = Project.defaultProjectPath;
	
	bool help = false;
	getopt(args,
	    "gui", &gladeFile,
	    "log", &logFile,
	    "proj", &projFile,
	    "help", &help
	);
	
	if(help)
	{
	    writeln(helpMsg);
	    return;
	}
	
	Main.initMultiThread(args);
	
	auto application = new Application(logFile, gladeFile, projFile);
	scope(exit) application.finalize();
    
	Main.run();
}

class Application
{
    shared ILogger logger;
    
    SettingsWindow settingsWindow;
    EvolutionWindow evolutionWindow;
    ResultsWindow resultsWindow;
    
    Project project;
    
    this(string logFile, string gladeFile, string projFile)
    {
        logger = new shared StrictLogger(logFile);
        
        logger.logInfo("Loading project file...");
        project = new Project();
        if(projFile.exists)
        {
            project.open(projFile);
        } 
        else
        {
            logger.logInfo("Cannot find project file, creating new project");
        }
        
        Builder builder = new Builder();
        if( !builder.addFromFile(gladeFile) )
        {
            logger.logError(text("Failed to create gui from glade file '", gladeFile, "'!"));
            return;
        }
        
        logger.logInfo("Loading settings window");
        auto settingsWnd = cast(ApplicationWindow)builder.getObject("SettingsWindow");
        if(settingsWnd is null)
        {
            logger.logError("Failed to create settings window!");
            return;
        }
        
        logger.logInfo("Loading evolution window");
        auto evolutionWnd = cast(ApplicationWindow)builder.getObject("EvolutionWindow");
        if(evolutionWnd is null)
        {
            logger.logError("Failed to create evolution window!");
            return;
        }
        
        logger.logInfo("Loading results window");
        auto resultsWnd = cast(ApplicationWindow)builder.getObject("ResultsWindow");
        if(resultsWnd is null)
        {
            logger.logError("Failed to create results window!");
            return;
        }
        
        settingsWindow = new SettingsWindow(builder, logger, project, settingsWnd, evolutionWnd, resultsWnd);
        evolutionWindow = new EvolutionWindow(builder, logger, project, settingsWnd, evolutionWnd, resultsWnd);
        resultsWindow = new ResultsWindow(builder, logger, project, settingsWnd, evolutionWnd, resultsWnd);
    }
    
    void finalize()
    {
        logger.finalize();
    }
}