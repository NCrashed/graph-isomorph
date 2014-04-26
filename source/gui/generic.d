/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module gui.generic;

import gtk.Builder;
import gtk.ApplicationWindow;
import gtk.ImageMenuItem;
import gtk.FileChooserDialog;
import dlogg.log;

import project;

import std.file;

class GenericWindow
{
    enum defaultWindowTittle = "Graph-isomorph";
    
    this(Builder builder, shared ILogger logger, Project project
        ,ApplicationWindow window)
    {
        mBuilder = builder;
        mLogger = logger;
        mProject = project;
        mWindow = window;
        
        updateTittle();
    }
    
    void updateTittle()
    {
        window.setTitle(defaultWindowTittle ~ " " ~ project.filename);
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
    
    void initProjectSaveLoad(string distinct)
    {
        auto newItem = cast(ImageMenuItem)builder.getObject("NewProjectMenuItem"~distinct);
        assert(newItem !is null);
        newItem.addOnActivate((i)
        {
            try
            {
                auto dlg = new FileChooserDialog("Выберите файл нового проекта"
                    , window
                    , FileChooserAction.SAVE
                    , ["OK", "Отмена"]
                    , [ResponseType.OK, ResponseType.CANCEL]
                );
                
                dlg.setDoOverwriteConfirmation(true);
                dlg.setCurrentFolder(getcwd);
                dlg.setCurrentName(Project.defaultProjectPath);
           
                switch(dlg.run)
                {
                    case(ResponseType.OK):
                    {
                        string filename = dlg.getFilename;
                        if(filename !is null)
                        {
                            project.recreate(filename);
                            updateTittle();
                        }
                        dlg.destroy;
                        return;
                    }
                    default:
                    {
                        dlg.destroy;
                        return;
                    }
                } 
            }
            catch(Throwable e)
            {
                logger.logError(e.toString);
            }
        });
        
        auto openItem = cast(ImageMenuItem)builder.getObject("OpenProjectMenuItem"~distinct);
        assert(openItem !is null);
        openItem.addOnActivate((i)
        {
            try
            {
                auto dlg = new FileChooserDialog("Выбирете файл проекта"
                    , window
                    , FileChooserAction.OPEN
                    , ["OK", "Отмена"]
                    , [ResponseType.OK, ResponseType.CANCEL]
                );
                
                dlg.setCurrentFolder(getcwd);
           
                switch(dlg.run)
                {
                    case(ResponseType.OK):
                    {
                        string filename = dlg.getFilename;
                        if(filename !is null)
                        {
                            project.open(filename);
                            updateTittle();
                        }
                        dlg.destroy;
                        return;
                    }
                    default:
                    {
                        dlg.destroy;
                        return;
                    }
                } 
            }
            catch(Throwable e)
            {
                logger.logError(e.toString);
            }
        });
    }
    
    private
    {
        Builder mBuilder;
        shared ILogger mLogger;
        Project mProject;
        ApplicationWindow mWindow;
    }
}