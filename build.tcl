#!/usr/bin/env tclsh

#load configuration
package require json
set conf_file [open tcl.json r]
set cfg [::json::json2dict [read $conf_file]]
close $conf_file
dict with cfg {}
dict with cfg targets server {}

#available build commands
proc clean {}		{global web_path build_path asset_path ; file delete -force "elm-stuff" "$web_path/index.html" $build_path $asset_path}
proc debug {}		{global production ; set production 0}
proc release {}	{global production ; set production 1}

#initialize main variables
set subcommand	[lindex $::argv end]
set help_msg		"usage: $::argv0 clean|debug|release\n"
set host_os			[string tolower $tcl_platform(os)]
set host_arch		"x[string range $tcl_platform(machine) end-1 end]"
set exe_path		"$build_path/$exe_name"
set tcl_kit			[file normalize "$wrap_path/tclkit-$host_os-$host_arch"]
set sdx_kit			[file normalize "$wrap_path/sdx-20110317.kit"]
set app_vfs			"$build_path/$exe_name.vfs"
set mod_path 		"$app_vfs/$mod_folder"
set asset_path 	"$app_vfs/$asset_folder"
set deps_list		$src_pkgs

#windows specific settings
if {$host_os eq "windows"} {
	append exe_path ".exe"
	append tcl_kit	".exe"
	lappend deps_list $dll_pkgs
}

#parse cli arguments
switch $subcommand {
	clean			{clean ; exit}
	debug			{debug}
	release		{release}
	help			{puts $help_msg ; exit}
	default		{clean ; debug}
}

#set packaging options
if {$production} {
	append elm_cmd " --optimize"
} else {
	append elm_cmd " --debug"
}

#build static webapp
set elm_cmd	"$elm_bin make $web_path/main.elm"
puts "Building webapp ($elm_cmd)"
exec {*}$elm_cmd
file rename -force "index.html" $web_path

#build embedded tcl server
file mkdir $build_path
file mkdir $app_vfs
file mkdir $mod_path
file mkdir $asset_path

foreach mod $deps_list {
	file copy -force "$lib_path/$mod" $mod_path
}

foreach asset $web_assets {
	file copy -force "$web_path/$asset" $asset_path
}

cd $build_path
set tcl_cmd	"$sdx_kit wrap $exe_name -runtime $tcl_kit"

puts "Building embedded server ($tcl_cmd)"
exec {*}$tcl_cmd
