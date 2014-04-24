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

import dlogg.log;

import evol.progtype;
import devol.operator;
import devol.operatormng;

import project;

class SettingsWindow
{
    Builder builder;
    ApplicationWindow window;
    shared ILogger logger;
    Project project;
    
    this(Builder builder, shared ILogger logger
        , Project project
        , ApplicationWindow settingsWindow
        , ApplicationWindow evoluitionWindow
        , ApplicationWindow resultsWindow)
    {
        this.window = settingsWindow;
        this.logger = logger;
        this.builder = builder;
        this.project = project;
        
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
    }
    
    void initProgtypeEntries()
    {
        auto progMinSizeEntry = cast(Entry)builder.getObject("ProgMinSizeEntry");
        assert(progMinSizeEntry !is null);
        
        auto progMaxSizeEntry = cast(Entry)builder.getObject("ProgMaxSizeEntry");
        assert(progMaxSizeEntry !is null);
        
        auto scopeMinSizeEntry = cast(Entry)builder.getObject("ScopeMinSizeEntry");
        assert(scopeMinSizeEntry !is null);
        
        auto scopeMaxSizeEntry = cast(Entry)builder.getObject("ScopeMaxSizeEntry");
        assert(scopeMaxSizeEntry !is null);
        
        auto newOpGenChanceEntry = cast(Entry)builder.getObject("NewOpGenChanceEntry");
        assert(newOpGenChanceEntry !is null);
        
        auto newScopeGenChanceEntry = cast(Entry)builder.getObject("NewScopeGenChanceEntry");
        assert(newScopeGenChanceEntry !is null);
        
        auto newLeafGenChanceEntry = cast(Entry)builder.getObject("NewLeafGenChanceEntry");
        assert(newLeafGenChanceEntry !is null);
        
        auto mutationChangeChanceEntry = cast(Entry)builder.getObject("MutationChangeChanceEntry");
        assert(mutationChangeChanceEntry !is null);
        
        auto mutationReplaceChanceEntry = cast(Entry)builder.getObject("MutationReplaceChanceEntry");
        assert(mutationReplaceChanceEntry !is null);
        
        auto mutationDeleteChanceEntry = cast(Entry)builder.getObject("MutationDeleteChanceEntry");
        assert(mutationDeleteChanceEntry !is null);
        
        auto mutationAddLineChanceEntry = cast(Entry)builder.getObject("MutationAddLineChanceEntry");
        assert(mutationAddLineChanceEntry !is null);
        
        auto mutationRemoveLineChanceEntry = cast(Entry)builder.getObject("MutationRemoveLineChanceEntry");
        assert(mutationRemoveLineChanceEntry !is null);
        
        auto maxMutationChangeEntry = cast(Entry)builder.getObject("MaxMutationChangeEntry");
        assert(maxMutationChangeEntry !is null);
        
        auto mutationChanceEntry = cast(Entry)builder.getObject("MutationChanceEntry");
        assert(mutationChanceEntry !is null);
        
        auto crossingoverChanceEntry = cast(Entry)builder.getObject("CrossingoverChanceEntry");
        assert(crossingoverChanceEntry !is null);
        
        auto copyingPartEntry = cast(Entry)builder.getObject("CopyingPartEntry");
        assert(copyingPartEntry !is null);
        
        auto deleteMutationRiseGenomeSizeEntry = cast(Entry)builder.getObject("DeleteMutationRiseGenomeSizeEntry");
        assert(deleteMutationRiseGenomeSizeEntry !is null);
        
        auto maxGenomeSizeEntry = cast(Entry)builder.getObject("MaxGenomeSizeEntry");
        assert(maxGenomeSizeEntry !is null);
        
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
        
        template genInitialSetupText(tts...)
        {
            enum field = tts[0];
            enum genInitialSetupText = field~`Entry.setText(project.programType.`~field~`.to!string);`;
        }
        
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