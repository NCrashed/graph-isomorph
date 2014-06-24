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
import gtk.ToolButton;
import gtk.ProgressBar;
import gdk.Threads;
import gtk.Entry;

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
import std.concurrency;
import std.datetime;
import std.functional;

import core.thread;

import evol.compiler;
import evol.world;

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
        initAboutDialog("2");
        
        initEvolution();
        initEvolutionControl();
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
                file.writeln(graph.genDot());
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
    
    void setGenerationNumber(size_t i)
    {
    	auto entry = cast(Entry)builder.getObject("GenerationNumberEntry");
    	assert(entry !is null);
    	
    	entry.setText(to!string(i+1));
    }
    
    void setMaxFitness(double fitness)
    {
    	auto entry = cast(Entry)builder.getObject("MaxFitnessEntry");
    	assert(entry !is null);
    	
    	entry.setText(to!string(fitness));
    }
    
    void setAvarageFitness(double fitness)
    {
    	auto entry = cast(Entry)builder.getObject("AvarageFitnessEntry");
    	assert(entry !is null);
    	
    	entry.setText(to!string(fitness));
    }
    
    void initEvolutionControl()
    {
        auto startBtn = cast(ToolButton)builder.getObject("EvolutionStartButton");
        assert(startBtn !is null);
        
        startBtn.addOnClicked((b)
        {
            try 
            {
                startEvolution();
            } catch(Throwable th)
            {
                logger.logError(th.toString);
            }
        });
        
        auto pauseBtn = cast(ToolButton)builder.getObject("EvolutionPauseButton");
        assert(pauseBtn !is null);
        
        pauseBtn.addOnClicked((b)
        {
            try
            {
                pauseEvolution();
            } catch(Throwable th)
            {
                logger.logError(th.toString);
            }
        });
        
        auto stopBtn = cast(ToolButton)builder.getObject("EvolutionStopButton");
        assert(stopBtn !is null);
        
        stopBtn.addOnClicked((b)
        {
            try
            {
                stopEvolution();
                
                auto progressBar = cast(ProgressBar)builder.getObject("EvolutionProgressBar");
                assert(progressBar !is null);
                progressBar.setFraction(0);
                
            } catch(Throwable th)
            {
                logger.logError(th.toString);
            }
        });
    }
    
    void initEvolution()
    {
        compiler = new GraphCompiler(
        	new GraphCompilation(project, ()
        		{
        			threadsEnter();
        			application.updateAll();
        			threadsLeave();
    			})
        	, project.programType
        	, new GraphWorld(
                project.programType
                ,(gr1, gr2)
                {
                    threadsEnter();
                    setInputImages(gr1, gr2);
                    threadsLeave();
                }));
        
        evolState = EvolutionState.Stoped;
    }
    
    void startEvolution()
    {
        final switch(evolState)
        {
            case(EvolutionState.Running):
            {
                return;
            }
            case(EvolutionState.Paused):
            {
                evolutionTid.send(thisTid, EvolutionCommand.Resume);
                if(project.popLoaded)
                {
                	core.thread.Thread.sleep(dur!"msecs"(500));
                	startEvolution();
                }
                return;
            }
            case(EvolutionState.Stoped):
            {
                compiler.clean();
                if(!project.popLoaded || project.population is null)
                {
                    project.population = compiler.addPop(
                    	project.programType.populationSize);
                    project.popLoaded = false;
                } else
                {
                	compiler.addPop(project().population);
                	project.popLoaded = false;
                }
                
                evolutionTid = spawn(&evolutionThread, cast(shared)this);
                evolutionTid.send(thisTid);
                return;
            }
        }
    }
    
    void stopEvolution()
    {
        final switch(evolState)
        {
            case(EvolutionState.Running):
            {
                evolutionTid.send(thisTid, EvolutionCommand.Stop);
                return;
            }
            case(EvolutionState.Paused):
            {
                evolutionTid.send(thisTid, EvolutionCommand.Stop);
                return;
            }
            case(EvolutionState.Stoped):
            {
                return;
            }
        }
    }
    
    override void updateContent()
    {
        super.updateContent();
        
        if(project.population !is null)
        {
            setGenerationNumber(cast(size_t)project.population.generation);
            
            double val = 0.0;
            double maxFitness = 0.0;
            foreach(ind; project.population)
            {
                if(ind.fitness > maxFitness)
                    maxFitness = ind.fitness;
                    
                val += ind.fitness;
            }
            
            setMaxFitness(maxFitness);
            if(val != 0.0)
            {
                setAvarageFitness(val / cast(double) project.population.length);
            } else
            {
                setAvarageFitness(0.0);
            }
        }
    }
    
    void pauseEvolution()
    {
        final switch(evolState)
        {
            case(EvolutionState.Running):
            {
                evolutionTid.send(thisTid, EvolutionCommand.Pause);
                return;
            }
            case(EvolutionState.Paused):
            {
                evolutionTid.send(thisTid, EvolutionCommand.Pause);
                return;
            }
            case(EvolutionState.Stoped):
            {
                return;
            }
        }
    }
    
    private
    {
        enum EvolutionState
        {
            Stoped,
            Running,
            Paused
        }
        
        enum EvolutionCommand
        {
            Pause,
            Resume,
            Stop
        }
        
        __gshared EvolutionState evolState;
        __gshared GraphCompiler compiler;
        Tid evolutionTid;
        
        static void evolutionThread(shared EvolutionWindow wndShared)
        {
            Thread.getThis().isDaemon(true);
            
            EvolutionWindow wnd = cast()wndShared;
            try
            {
                auto progressBar = cast(ProgressBar)wnd.builder.getObject("EvolutionProgressBar");
                assert(progressBar !is null);
            
                evolState = EvolutionState.Running;
                scope(exit) evolState = EvolutionState.Stoped;
                
                wnd.project.programType.registerTypes();
                
                bool exit = false;
                bool paused = false;
                Tid parent = receiveOnly!Tid();
                
                void listener()
                {
                    receiveTimeout(dur!"msecs"(1),
                        (Tid sender, EvolutionCommand command)
                        {
                            final switch(command)
                            {
                                case(EvolutionCommand.Resume):
                                {
                                    evolState = EvolutionState.Running;
                                    paused = false;
                                    break;
                                }
                                case(EvolutionCommand.Pause):
                                {
                                    evolState = EvolutionState.Paused;
                                    paused = true;
                                    break;
                                }
                                case(EvolutionCommand.Stop):
                                {
                                    exit = true;
                                    paused = false;
                                    evolState = EvolutionState.Paused;
                                    break;
                                }
                            }
                        });
                }
                
                void updater(double percent)
                {
                    listener();
                    assert(progressBar !is null);
                    
                    threadsEnter();
                    progressBar.setFraction(percent);
                    threadsLeave();
                }
                auto updaterDelegate = toDelegate(&updater);
                
                bool whenExit()
                {
                    return exit || wnd.project().popLoaded;
                }
                auto whenExitDelegate = toDelegate(&whenExit);
                
                bool pauser()
                {
                    return paused;
                }
                auto pauserDelegate = toDelegate(&pauser);
                    
                while(!whenExit)
                {
                    compiler.envolveGeneration(whenExitDelegate, "saves"
                        , updaterDelegate, pauserDelegate);
                }
                updater(0.0);
            } catch(OwnerTerminated e)
            {
                
            } catch(Exception e)
            {
                wnd.logger.logError(e.toString);
            } catch(Throwable th)
            {
                wnd.logger.logError(th.toString);
            }
        }
    }
}