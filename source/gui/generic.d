/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module gui.generic;

import gtk.Builder;
import gtk.ApplicationWindow;

import dlogg.log;

import project;

class GenericWindow
{
    this(Builder builder, shared ILogger logger, Project project
        ,ApplicationWindow window)
    {
        mBuilder = builder;
        mLogger = logger;
        mProject = project;
        mWindow = window;
    }
    
    Builder builder()
    {
        return mBuilder;
    }
    
    shared(ILogger) logger()
    {
        return mLogger;
    }
    
    Project project()
    {
        return mProject;
    }
    
    ApplicationWindow window()
    {
        return mWindow;
    }
    
    void initProjectSaveLoad()
    {
        
    }
    
    private
    {
        Builder mBuilder;
        shared ILogger mLogger;
        Project mProject;
        ApplicationWindow mWindow;
    }
}