/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module app;

import gtk.Builder;
import gtk.Button;
import gtk.Main;
import gtk.Widget;
import gtk.ApplicationWindow;
import gtk.MenuItem;
import gobject.Type;

import std.stdio;
import std.getopt;
import std.c.process;
import std.file;

import dlogg.strict;

import gui.evolution;
import gui.results;
import gui.settings;

import project;
import application;

enum helpMsg = 
"graph-isomorph [options]

options:  --gui=<path>  - path to glade file. Optional, default is 'gui.glade'.
          --log=<path>  - path to log file. Optional, default is 'graph-isomorph.log'.
          --proj=<path> - path to project file. Optional, default is '"~Project.defaultProjectPath~"'. 
          --help        - display the message.";

void main(string[] args)
{
	string gladeFile = "./gui.glade";
	string logFile = "./graph-isomorph.log";
	string projFile = Project.defaultProjectPath;
	
	bool help = false;
	getopt(args,
	    "gui", &gladeFile,
	    "log", &logFile,
	    "proj", &projFile,
	    "help", &help
	);
	
	if(help)
	{
	    writeln(helpMsg);
	    return;
	}
	
	Main.initMultiThread(args);
	
	auto application = new Application(logFile, gladeFile, projFile);
	scope(exit) application.finalize();
    
	Main.run();
}

