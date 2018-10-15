#!/usr/bin/env tclsh

#load configuration
package require json
set conf_file [open tcl.json r]
set cfg [::json::json2dict [read $conf_file]]
close $conf_file
dict with cfg {}
dict with cfg targets server {}

#available build commands
proc clean {}		{global web_path build_path asset_folder ; file delete -force "elm-stuff" "$web_path/$asset_folder" $build_path}
proc debug {}		{global production ; set production 0}
proc release {}		{global production ; set production 1}

#initialize main variables
set subcommand		[lindex $::argv end]
set help_msg		"usage: $::argv0 clean|debug|release\n"
set host_os			[lindex [split [string tolower $tcl_platform(os)]] 0]
set host_arch		"x[string range $tcl_platform(machine) end-1 end]"
set exe_path		"$build_path/$exe_name"
set tcl_kit			"tclkit-$host_os-$host_arch"
set sdx_kit			"sdx-20110317.kit"
set app_vfs			"$build_path/$exe_name.vfs"
set mod_path 		"$app_vfs/$mod_folder"
set asset_path		"$app_vfs/$asset_folder"
set html_path		"$app_vfs/$html_folder"
set wrap_path		"$app_vfs/$wrap_folder"
set deps_list		"$src_pkgs"
set elm_opts		""

#windows specific settings
if {$host_os eq "windows"} {
	append exe_path ".exe"
	append exe_name ".exe"
	append tcl_kit	".exe"
	lappend deps_list $dll_pkgs
}

#parse cli arguments
switch $subcommand {
	clean			{clean ; exit}
	debug			{debug}
	release			{release}
	help			{puts $help_msg ; exit}
	default			{clean ; debug}
}

#set packaging options
if {$production} {
	append elm_opts " --optimize"
} else {
	append elm_opts " --debug"
}

#build static webapp
set elm_cmd	"$elm_bin make $web_path/Main.elm $elm_opts"
puts "Building webapp ($elm_cmd)"
exec {*}$elm_cmd

#build embedded tcl server
set runtime [file normalize $wrap_folder/$tcl_kit]
file mkdir $build_path
file mkdir $app_vfs
file mkdir $mod_path
file mkdir $html_path

foreach mod $deps_list {
	file copy -force "$lib_path/$mod" $mod_path
}

foreach srcfile [glob $api_path/*] {
	file copy -force $srcfile $app_vfs
}

file rename -force "index.html" $html_path

file copy -force tcl.json $app_vfs
file copy -force $asset_folder $app_vfs		;# for embedded wapp server
file copy -force $asset_folder $web_path	;# for elm reactor server
file copy -force $wrap_folder $app_vfs
file copy -force $wrap_folder/$tcl_kit $build_path
file copy -force $wrap_folder/$sdx_kit $build_path/sdx.kit

cd $build_path
set tcl_cmd	"[pwd]/$tcl_kit sdx.kit wrap $exe_name -runtime $runtime"
puts "Building embedded server ($tcl_cmd)"
exec {*}$tcl_cmd
