/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module gui.results;

import gtk.Builder;
import gtk.MenuItem;
import gtk.ApplicationWindow;
import gtk.TreeView;
import gtk.TreeIter;
import gtk.TextView;
import gtk.Image;
import gtk.ListStore;

import gui.util;
import gui.generic;

import dlogg.log;

import project;
import application;

import std.conv;
import std.file;
import std.path;
import std.stdio;
import std.process;

import devol.individ;

class ResultsWindow : GenericWindow
{  
    this(Application app, Builder builder, shared ILogger logger
        , Project project
        , ApplicationWindow settingsWindow
        , ApplicationWindow evoluitionWindow
        , ApplicationWindow resultsWindow)
    {
        super(app, builder, logger, project, resultsWindow);
        
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
        initPopulationView();
    }
    
    private void setImage(IndAbstract graph, string wname)
    {
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
            file.writeln(graph.genDot());
            file.close();
            
            shell(text("dot -Tpng ", dotFilename, " > ", imageFilename));
            
            programImage.setFromFile(imageFilename);
        }
        catch(Exception e)
        {
            logger.logError("Failed to load image from graph for "~wname);
            logger.logError(e.msg);
        }
    }
    
    private TreeView individsView;
    private ListStore individsViewModel;
    private TextView programView;
    private Image programImage;
    
    void updatePopulation()
    {
    	individsViewModel.clear();
    	programView.getBuffer().setText("");
    	programImage.clear();
    	
    	if(project.population !is null)
    	{
        	foreach(i, ind; project.population)
        	{
        		auto iter = new TreeIter();
        		individsViewModel.insert(iter, -1);
        		
        		individsViewModel.setValue(iter, 0, ind.name);
        		individsViewModel.setValue(iter, 1, to!string(ind.fitness));
        		individsViewModel.setValue(iter, 2, cast(int)i);
        	}
    	}
    }
    
    override void updateContent()
    {
        super.updateContent();
        updatePopulation();
    }
    
    void initPopulationView()
    {
    	individsView = cast(TreeView)builder.getObject("IndividsTreeView");
    	assert(individsView !is null);
    	
    	individsViewModel = new ListStore([GType.STRING, GType.STRING, GType.INT]);
        individsView.setModel(individsViewModel);
        
        programView = cast(TextView)builder.getObject("ProgramTextView");
        assert(programView !is null);
        
        programImage = cast(Image)builder.getObject("ProgramImage");
        assert(programImage !is null);
        
        individsView.addOnCursorChanged((v)
        {
            auto model = individsView.getModel();
            assert(model !is null);
            
            auto iter = individsView.getSelectedIter();
            if(iter is null)
            {
                programImage.clear();
                programView.getBuffer().setText("");
            }
            else
            {
                auto individId = model.getValueInt(iter, 2);
                if(individId < 0 || individId >= project.population.length) return;
                
                auto individ = project.population[cast(size_t)individId];
                assert(individ !is null);
                
                programView.getBuffer().setText(individ.programString);
                setImage(individ, individ.name);
            }
        });
    }
}