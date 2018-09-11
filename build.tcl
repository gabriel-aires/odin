#!/usr/bin/env tclsh

#initialize main variables
set subcommand [lindex $::argv 0]
set deps_path		"/modules"
set deps_list		{msvcr110.dll libwinpthread-1.dll twapi4.3.5/pkgIndex.tcl twapi4.3.5/twapi_base64.dll wapp1.0/pkgIndex.tcl wapp1.0/wapp.tcl}
set asset_path	"/assets"
set asset_list {index.html logo_black.png logo_white.png style_main.css style_pure_grids_custom.css style_pure_min_v1.css}
set api_path			"api/src"
set web_path			"web/src"
set stub_path  "~/Programas/tclkits/tclexecomp64.exe"
set exe_path			"odin-server.exe"
set build_path	"build"
set help_msg			"usage: [set $::argv0] debug|release\n"
set elm_cmd				"elm make $web_path/main.elm"
set tcl_cmd				"$stub_path $api_path/main.tcl -w $stub_path -forcewrap -o $exe_path"

#parse cli arguments
if { $::argc <> 1} {	
	switch $subcommand {
		debug			{set production 0}
		release	{set production 1}
		default	{puts $help_msg ; exit}
	}	
} else {	
	puts $help_msg ; exit	
} 

#set packaging options
if {$production} {
	append elm_make_cmd " --optimize"
} else {
	append elm_make_cmd " --debug"	
}

#build static webapp
puts "Building webapp ($elm_cmd)"
exec $elm_cmd

file mkdir $build_path
file copy -force $web_path $build_path
file rename -force "index.html" $build_path
file delete "$build_path/main.elm"

#build embedded tcl server
puts "Building embedded server ($tcl_cmd)"

foreach file $deps_list {
	lappend tcl_cmd [file join $deps_path $file]
}

foreach file $asset_list {
	file copy -force [file join $build_path $file] $asset_path
	lappend tcl_cmd [file join $asset_path $file]
}

exec $tcl_cmd
