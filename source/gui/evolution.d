/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module gui.evolution;

import gtk.Builder;
import gtk.MenuItem;
import gtk.ApplicationWindow;
import gtk.Image;

import gui.util;
import gui.generic;
import dlogg.log;

import graph.directed;

import project;
import application;

import std.file;
import std.stdio;
import std.process;
import std.path;
import std.conv;

class EvolutionWindow : GenericWindow
{
    this(Application app, Builder builder, shared ILogger logger
        , Project project
        , ApplicationWindow settingsWindow
        , ApplicationWindow evoluitionWindow
        , ApplicationWindow resultsWindow)
    {
        super(app, builder, logger, project, evoluitionWindow);
        
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
    
    void setInputImages(IDirectedGraph first, IDirectedGraph second)
    {
        void setImage(IDirectedGraph graph, string wname)
        {
            auto image = cast(Image)builder.getObject(wname);
            assert(image !is null);
            
            try
            {
                enum tempImageDir = "./images";
                if(!tempImageDir.exists)
                {
                    mkdirRecurse(tempImageDir);
                }
                
                string dotFilename = buildPath(tempImageDir, wname~".dot");
                string imageFilename = buildPath(tempImageDir, wname~".png");
                
                auto file = File(dotFilename, "w");
                file.writeln(graph.genDot);
                file.close();
                
                shell(text("dot -Tpng ", dotFilename, " > ", imageFilename));
                
                image.setFromFile(imageFilename);
            }
            catch(Exception e)
            {
                logger.logError("Failed to load image from graph for "~wname);
                logger.logError(e.msg);
            }
        }
        
        setImage(first, "InputGraphImage1");
        setImage(second, "InputGraphImage2");
    }
}