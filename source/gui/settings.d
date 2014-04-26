/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module gui.settings;

import gtk.Builder;
import gtk.MenuItem;
import gtk.ApplicationWindow;
import gtk.Entry;
import gtk.MessageDialog;
import gtk.Widget;
import gtk.TreeView;
import gtk.TextView;
import gtk.TextIter;
import gtk.ListStore;
import gtk.TreeIter;

import gdk.Event;
import gobject.Value;

import gui.util;
import gui.generic;

import dlogg.log;

import evol.progtype;
import devol.operator;
import devol.operatormng;

import project;
import application;

import std.string;

class SettingsWindow : GenericWindow
{   
    this(Application app, Builder builder, shared ILogger logger
        , Project project
        , ApplicationWindow settingsWindow
        , ApplicationWindow evoluitionWindow
        , ApplicationWindow resultsWindow)
    {
        super(app, builder, logger, project, settingsWindow);
        
        settingsWindow.showAll();
        settingsWindow.addOnHide( (w) => onWindowHideShow(AppWindow.Settings, true) );
        settingsWindow.addOnShow( (w) => onWindowHideShow(AppWindow.Settings, false) );
        settingsWindow.addOnDelete( (e, w) { settingsWindow.hide; return true; } );
        
        auto showEvolutionWndItem = cast(MenuItem)builder.getObject("ShowEvolutionWndItem1");
        if(showEvolutionWndItem is null)
        {
            logger.logError("SettingsWnd: failed to get show evolution wnd item!");
            assert(false);
        }
        showEvolutionWndItem.addOnActivate( (w) => evoluitionWindow.showAll() );
        
        auto showResultsWndItem = cast(MenuItem)builder.getObject("ShowResultsWndItem1");
        if(showResultsWndItem is null)
        {
            logger.logError("SettingsWnd: failed to get show results wnd item!");
            assert(false);
        }
        showResultsWndItem.addOnActivate( (w) => resultsWindow.showAll() );
        
        initProgtypeEntries();
        initOperatorsView();
        initProjectSaveLoad("1");
    }
    
    override void updateContent()
    {
        super.updateContent();
        reloadSettings();
    }
    
    private
    {
        static char cupper(char c)
        {
            immutable source = "qwertyuiopasdfghjklzxcvbnm";
            immutable dist   = "QWERTYUIOPASDFGHJKLZXCVBNM";
            
            foreach(i, sc; source)
            {
                if(sc == c) return dist[i];
            }
            
            return c;
        }
        
        template genEntryGetter(tt...)
        {
            enum field = tt[0];
            enum genEntryGetter = "auto "~field
                ~`Entry = cast(Entry)builder.getObject("`
                ~[cupper(cast(char)field[0])]~field[1..$]~`Entry");`"\n"
                ~`assert(`~field~`Entry !is null);`;
        }
        
        template genInitialSetupText(tts...)
        {
            enum field = tts[0];
            enum genInitialSetupText = field~`Entry.setText(project.programType.`~field~`.to!string);`;
        }
    }
    
    void initProgtypeEntries()
    {
        mixin(genEntryGetter!"progMinSize");
        mixin(genEntryGetter!"progMaxSize");
        mixin(genEntryGetter!"scopeMinSize");
        mixin(genEntryGetter!"scopeMaxSize");
        mixin(genEntryGetter!"newOpGenChance");
        mixin(genEntryGetter!"newScopeGenChance");
        mixin(genEntryGetter!"newLeafGenChance");
        mixin(genEntryGetter!"mutationChangeChance");
        mixin(genEntryGetter!"mutationReplaceChance");
        mixin(genEntryGetter!"mutationDeleteChance");
        mixin(genEntryGetter!"mutationAddLineChance");
        mixin(genEntryGetter!"mutationRemoveLineChance");
        mixin(genEntryGetter!"maxMutationChange");
        mixin(genEntryGetter!"mutationChance");
        mixin(genEntryGetter!"crossingoverChance");
        mixin(genEntryGetter!"copyingPart");
        mixin(genEntryGetter!"deleteMutationRiseGenomeSize");
        mixin(genEntryGetter!"maxGenomeSize");
        
        void showInvalidValueDialog(T)(string value)
        {
            auto dialog = new MessageDialog(window
                , GtkDialogFlags.MODAL
                , GtkMessageType.ERROR
                , GtkButtonsType.CLOSE
                , "%s"
                , text("Expected value of type ", T.stringof, ", but got '", value,"'!"));
            dialog.addOnResponse( (r, d) => dialog.destroy );
            dialog.run();
        }
        
        bool delegate(Event, Widget) tryFillValue(T, string field)(Entry entry)
        {
            return (e, w)
            {
                scope(failure) 
                {
                    showInvalidValueDialog!T(entry.getText);
                    return false;
                }
                mixin("project.programType."~field~" = entry.getText.to!T;");
                return false;
            };
        }
        
        template genFocusSignal(tts...)
        {
            enum field = tts[0];
            mixin(`alias T = typeof(project.programType.`~field~`);`);
            enum genFocusSignal = field~"Entry.addOnFocusOut(tryFillValue!("~T.stringof~`,"`~field~`")(`~field~`Entry));`;
        }
        
        mixin(genFocusSignal!"progMinSize");
        mixin(genFocusSignal!"progMaxSize");
        mixin(genFocusSignal!"scopeMinSize");
        mixin(genFocusSignal!"scopeMaxSize");
        mixin(genFocusSignal!"newOpGenChance");
        mixin(genFocusSignal!"newScopeGenChance");
        mixin(genFocusSignal!"newLeafGenChance");
        mixin(genFocusSignal!"mutationChangeChance");
        mixin(genFocusSignal!"mutationReplaceChance");
        mixin(genFocusSignal!"mutationDeleteChance");
        mixin(genFocusSignal!"mutationAddLineChance");
        mixin(genFocusSignal!"mutationRemoveLineChance");
        mixin(genFocusSignal!"maxMutationChange");
        mixin(genFocusSignal!"mutationChance");
        mixin(genFocusSignal!"crossingoverChance");
        mixin(genFocusSignal!"copyingPart");
        mixin(genFocusSignal!"deleteMutationRiseGenomeSize");
        mixin(genFocusSignal!"maxGenomeSize");
        
        mixin(genInitialSetupText!"progMinSize");
        mixin(genInitialSetupText!"progMaxSize");
        mixin(genInitialSetupText!"scopeMinSize");
        mixin(genInitialSetupText!"scopeMaxSize");
        mixin(genInitialSetupText!"newOpGenChance");
        mixin(genInitialSetupText!"newScopeGenChance");
        mixin(genInitialSetupText!"newLeafGenChance");
        mixin(genInitialSetupText!"mutationChangeChance");
        mixin(genInitialSetupText!"mutationReplaceChance");
        mixin(genInitialSetupText!"mutationDeleteChance");
        mixin(genInitialSetupText!"mutationAddLineChance");
        mixin(genInitialSetupText!"mutationRemoveLineChance");
        mixin(genInitialSetupText!"maxMutationChange");
        mixin(genInitialSetupText!"mutationChance");
        mixin(genInitialSetupText!"crossingoverChance");
        mixin(genInitialSetupText!"copyingPart");
        mixin(genInitialSetupText!"deleteMutationRiseGenomeSize");
        mixin(genInitialSetupText!"maxGenomeSize");
    }
    
    void reloadSettings()
    {
        mixin(genEntryGetter!"progMinSize");
        mixin(genEntryGetter!"progMaxSize");
        mixin(genEntryGetter!"scopeMinSize");
        mixin(genEntryGetter!"scopeMaxSize");
        mixin(genEntryGetter!"newOpGenChance");
        mixin(genEntryGetter!"newScopeGenChance");
        mixin(genEntryGetter!"newLeafGenChance");
        mixin(genEntryGetter!"mutationChangeChance");
        mixin(genEntryGetter!"mutationReplaceChance");
        mixin(genEntryGetter!"mutationDeleteChance");
        mixin(genEntryGetter!"mutationAddLineChance");
        mixin(genEntryGetter!"mutationRemoveLineChance");
        mixin(genEntryGetter!"maxMutationChange");
        mixin(genEntryGetter!"mutationChance");
        mixin(genEntryGetter!"crossingoverChance");
        mixin(genEntryGetter!"copyingPart");
        mixin(genEntryGetter!"deleteMutationRiseGenomeSize");
        mixin(genEntryGetter!"maxGenomeSize");
        
        mixin(genInitialSetupText!"progMinSize");
        mixin(genInitialSetupText!"progMaxSize");
        mixin(genInitialSetupText!"scopeMinSize");
        mixin(genInitialSetupText!"scopeMaxSize");
        mixin(genInitialSetupText!"newOpGenChance");
        mixin(genInitialSetupText!"newScopeGenChance");
        mixin(genInitialSetupText!"newLeafGenChance");
        mixin(genInitialSetupText!"mutationChangeChance");
        mixin(genInitialSetupText!"mutationReplaceChance");
        mixin(genInitialSetupText!"mutationDeleteChance");
        mixin(genInitialSetupText!"mutationAddLineChance");
        mixin(genInitialSetupText!"mutationRemoveLineChance");
        mixin(genInitialSetupText!"maxMutationChange");
        mixin(genInitialSetupText!"mutationChance");
        mixin(genInitialSetupText!"crossingoverChance");
        mixin(genInitialSetupText!"copyingPart");
        mixin(genInitialSetupText!"deleteMutationRiseGenomeSize");
        mixin(genInitialSetupText!"maxGenomeSize");
    }
    
    void initOperatorsView()
    {
        auto operatorsView = cast(TreeView)builder.getObject("OperatorsView");
        auto operatorNameEntry = cast(Entry)builder.getObject("OperatorNameEntry");
        auto operatorDescriptionView = cast(TextView)builder.getObject("OperatorDescriptionView");
        
        auto model = new ListStore([GType.STRING]);
        operatorsView.setModel(model);
        
        operatorsView.addOnCursorChanged((v)
        {
            auto opmng = OperatorMng.getSingleton();
            auto model = operatorsView.getModel();
            assert(model !is null);
            
            auto iter = operatorsView.getSelectedIter();
            if(iter is null)
            {
                operatorNameEntry.setText("");
                operatorDescriptionView.getBuffer().setText("");
            }
            else
            {
                auto value = model.getValue(iter, 0);
                auto opName = value.getString();
                auto operator = opmng.getOperator(opName);
                
                operatorNameEntry.setText(operator.name);
                operatorDescriptionView.getBuffer().setText(operator.disrc);
            }
        });
        
        auto opmng = OperatorMng.getSingleton();
        foreach(operator; OperatorMng.getSingleton)
        {
            auto iter = new TreeIter;
            model.insert(iter, -1);
            model.setValue(iter, 0, operator.name);
        }
    }
}