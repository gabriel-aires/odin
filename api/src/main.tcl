#import packages
package require starkit
package require json

#initialize starpack
starkit::startup
set vfs_root [file dirname [file normalize [info script]]]

#read configuration
set conf_file [open $vfs_root/tcl.json r]
set cfg [::json::json2dict [read $conf_file]]
close $conf_file

namespace eval cfg {

	dict with cfg {}
	dict with cfg targets server {}

	set packages {sqlite3 cron json wapp}
	set asset_path [file join $vfs_root $asset_folder]
	set mod_path [file join $vfs_root $mod_folder]
	set assets [glob $asset_path/*]
	set pages {}
	set default_port 3000

}

#adjust auto_path
lappend ::auto_path $cfg::mod_path/twapi4.3.5 $cfg::mod_path/wapp1.0

#load required packages
puts "Loading required packages...\n"
foreach pkg $cfg::packages {
	puts "\t* $pkg: [package require $pkg]"
}

#find static web assets
puts "\nSearching for static assets...\n"
foreach file $cfg::assets {
	puts "\t* [file tail $file]"
}

proc wapp-default {} {
	wapp-redirect "index.html"
}

#serve elm webapp
proc wapp-page-index.html {} {

	set file [open $cfg::asset_path/index.html rb]
	set content [read $file]
	close $file
	
	wapp-allow-xorigin-params
	wapp-content-security-policy "off"
	wapp-mimetype "text/html"
	wapp-unsafe $content

}

#serve static assets
proc wapp-page-logo_black.png {} {

	set file [open $cfg::asset_path/logo_black.png rb]
	set content [read $file]
	close $file

	wapp-mimetype "img/png"
	wapp-unsafe $content

}

proc wapp-page-logo_white.png {} {

	set file [open $cfg::asset_path/logo_white.png rb]
	set content [read $file]
	close $file

	wapp-mimetype "img/png"
	wapp-unsafe $content

}

#start webserver
puts ""
wapp-start "--server $cfg::default_port"
