#!/usr/bin/env tclsh

#initialize main variables
set subcommand [lindex $::argv end]
set deps_path		"/modules"
set deps_list		{msvcr110.dll libwinpthread-1.dll twapi4.3.5/pkgIndex.tcl twapi4.3.5/twapi_base64.dll wapp1.0/pkgIndex.tcl wapp1.0/wapp.tcl}
set asset_path	"/assets"
set asset_list {index.html logo_black.png logo_white.png style_main.css style_pure_grids_custom.css style_pure_min_v1.css}
set api_path			"api/src"
set web_path			"web/src"
set stub_path  "~/Programas/tclkits/tclexecomp64.exe"
set build_path	"build"
set exe_path			"$build_path/odin-server.exe"
set help_msg			"usage: $::argv0 clean|debug|release\n"
set elm_cmd				"elm make $web_path/main.elm"
set tcl_cmd				"$stub_path $api_path/main.tcl -w $stub_path -forcewrap -o $exe_path"

#parse cli arguments
switch $subcommand {
	clean			{file delete -force "elm-stuff" "$web_path/index.html" $build_path $asset_path ; exit}
	debug			{set production 0}
	release	{set production 1}
	default	{puts $help_msg ; exit}
}

#set packaging options
if {$production} {
	append elm_cmd " --optimize"
} else {
	append elm_cmd " --debug"	
}

#build static webapp
puts "Building webapp ($elm_cmd)"
exec {*}$elm_cmd
file rename -force "index.html" $web_path

#build embedded tcl server
file mkdir $asset_path
file mkdir $build_path

foreach file $deps_list {
	lappend tcl_cmd [file join $deps_path $file]
}

foreach file $asset_list {

	set filename	[lindex [split $file .] 0]
	set fileext		[lindex [split $file .] end]

	if {$fileext eq "png"} {
		
		file copy -force [file join $web_path "$filename.bin"] [file join $asset_path "$filename.png"]
		file copy -force [file join $web_path "$filename.bin"] [file join $build_path "$filename.png"]
		
	} else {

		set in 	[open [file join $web_path $file] r]
		set out [open [file join $build_path $file] w]
		fconfigure $out -translation binary
		puts -nonewline $out [binary encode base64 [read $in]]
		close $in
		close $out
		file copy -force [file join $build_path $file] $asset_path
		
	}
	
	lappend tcl_cmd [file join $asset_path $file]
}

puts "Building embedded server ($tcl_cmd)"
exec {*}$tcl_cmd
