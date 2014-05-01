/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module application;

import gtk.Builder;
import gtk.ApplicationWindow;

import gui.settings;
import gui.evolution;
import gui.results;

import dlogg.strict;

import project;
import std.file;

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
        project = new Project(logger);
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
        
        settingsWindow = new SettingsWindow(this, builder, logger, project, settingsWnd, evolutionWnd, resultsWnd);
        evolutionWindow = new EvolutionWindow(this, builder, logger, project, settingsWnd, evolutionWnd, resultsWnd);
        resultsWindow = new ResultsWindow(this, builder, logger, project, settingsWnd, evolutionWnd, resultsWnd);
        
        updateAll();
    }
    
    void updateAll()
    {
        settingsWindow.updateContent();
        evolutionWindow.updateContent();
        resultsWindow.updateContent();
    }
    
    void finalize()
    {
        logger.finalize();
    }
}