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
        compiler = new GraphCompiler(new GraphCompilation(), project.programType, new GraphWorld(
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
                return;
            }
            case(EvolutionState.Stoped):
            {
                compiler.clean();
                compiler.addPop(project.programType.populationSize);
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
                    return exit;
                }
                auto whenExitDelegate = toDelegate(&whenExit);
                
                bool pauser()
                {
                    return paused;
                }
                auto pauserDelegate = toDelegate(&pauser);
                    
                while(!exit)
                {
                    compiler.envolveGeneration(whenExitDelegate, "saves"
                        , updaterDelegate, pauserDelegate);
                }
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