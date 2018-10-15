#!/usr/bin/env tclsh

#
# LOAD SETTINGS
#

package require json
set conf_file [open tcl.json r]
set cfg [::json::json2dict [read $conf_file]]
close $conf_file
dict with cfg {}

#
# USAGE
#

set subcommand		[lindex $::argv end]
set help_msg		"usage: $::argv0 clean|debug|release\n"

proc debug {}		{global production ; set production 0}
proc release {}		{global production ; set production 1}
proc clean {} 		{
	global build_path web_path desktop_path asset_folder
	file delete -force "elm-stuff" "$web_path/$asset_folder" "$desktop_path/$asset_folder" $build_path
}

switch $subcommand {
	clean			{clean ; exit}
	debug			{debug}
	release			{release}
	help			{puts $help_msg ; exit}
	default			{clean ; debug}
}

#
# SETUP
#

set firstrun 1

proc setup {step} {

	global firstrun tcl_platform host_os host_arch tcl_kit sdx_kit wrap_folder \
		build_path runtime exe_name app_vfs mod_folder mod_path asset_folder \
		wrap_path src_pkgs deps_list dll_pkgs lib_path tcl_cmd

	if $firstrun {

		set host_os			[lindex [split [string tolower $tcl_platform(os)]] 0]
		set host_arch		"x[string range $tcl_platform(machine) end-1 end]"
		set tcl_kit			"tclkit-$host_os-$host_arch"
		set sdx_kit			"sdx-20110317.kit"

		if {$host_os eq "windows"} {
			append tcl_kit	".exe"
		}

		file mkdir $build_path
		file copy -force $wrap_folder/$tcl_kit $build_path
		file copy -force $wrap_folder/$sdx_kit $build_path/sdx.kit

		set runtime			"[file normalize $wrap_folder/$tcl_kit]"
		set firstrun 		0
	}

	set loadcfg "dict with cfg targets $step {}"
	uplevel 1 $loadcfg

	set app_vfs			"$build_path/$exe_name.vfs"
	set mod_path 		"$app_vfs/$mod_folder"
	set asset_path		"$app_vfs/$asset_folder"
	set wrap_path		"$app_vfs/$wrap_folder"
	set deps_list		"$src_pkgs"

	file mkdir $app_vfs
	file mkdir $mod_path

	if {$host_os eq "windows"} {
		append exe_name ".exe"
		lappend deps_list $dll_pkgs
	}

	foreach mod $deps_list {
		file copy -force "$lib_path/$mod" $mod_path
	}

	file copy -force tcl.json $app_vfs

	set tcl_cmd	"./$tcl_kit sdx.kit wrap $exe_name -runtime $runtime"
}

proc build {component} {
	global build_path tcl_cmd
	set prev_dir [pwd]
	cd $build_path
	puts "Building $component: $tcl_cmd"	
	exec {*}$tcl_cmd
	cd $prev_dir
}

#
# SERVER BUILD
#

#setup server build
setup "server"
set html_path		"$app_vfs/$html_folder"
set elm_opts		""

#elm cmd options
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
file mkdir $html_path
file rename -force "index.html" $html_path

foreach srcfile [glob $api_path/*] {
	file copy -force $srcfile $app_vfs
}

file copy -force $asset_folder $app_vfs			;# for embedded wapp server
file copy -force $asset_folder $web_path		;# for elm reactor server
file copy -force $wrap_folder $app_vfs

build "embedded server"

#
# DESKTOP BUILD
#

setup "desktop"

foreach srcfile [glob $desktop_path/*] {
	file copy -force $srcfile $app_vfs
}

file copy -force $asset_folder $app_vfs			;# for standalone binary
file copy -force $asset_folder $desktop_path	;# for local TK development

build "desktop application"