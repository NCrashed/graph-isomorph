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
import gtk.Main;
import dlogg.log;

import project;
import application;

import std.file;

abstract class GenericWindow
{
    enum defaultWindowTittle = "Graph-isomorph";
    
    this(Application app, Builder builder, shared ILogger logger, Project project
        ,ApplicationWindow window)
    {
        this.app = app;
        mBuilder = builder;
        mLogger = logger;
        mProject = project;
        mWindow = window;
        
        updateTittle();
    }
    
    Application application()
    {
    	return app;
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
    
    void updateContent()
    {
        updateTittle();
    }
    
    void initProjectSaveLoad(string distinct)
    {
        logger.logInfo("New project button setup");
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
                            updateContent();
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
        
        logger.logInfo("Open project button setup");
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
                            app.updateAll();
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
        
        logger.logInfo("Save as project button setup");
        auto saveAsItem = cast(ImageMenuItem)builder.getObject("SaveAsProjectMenuItem"~distinct);
        assert(saveAsItem !is null);
        saveAsItem.addOnActivate((i)
        {
            try
            {
                auto dlg = new FileChooserDialog("Выбирете файл проекта"
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
                            project.save(filename);
                            app.updateAll();
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
        
        logger.logInfo("Save project button setup");
        auto saveItem = cast(ImageMenuItem)builder.getObject("SaveProjectMenuItem"~distinct);
        assert(saveItem !is null);
        saveItem.addOnActivate((i)
        {
            try
            {
                project.save(project.filename);
                app.updateAll();
            }
            catch(Throwable e)
            {
                logger.logError(e.toString);
            }
        });
        
        logger.logInfo("Exit application button setup");
        auto exitItem = cast(ImageMenuItem)builder.getObject("ExitMenuItem"~distinct);
        assert(exitItem !is null);
        exitItem.addOnActivate((i)
        {
            try
            {
                Main.quit();
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
        Application app;
    }
}