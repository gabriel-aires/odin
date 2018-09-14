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

#adjust auto_path and load wapp framework
lappend ::auto_path $cfg::mod_path/twapi4.3.5 $cfg::mod_path/wapp1.0
package require wapp

#redirect requests to webapp
proc wapp-default {} {
	wapp-redirect $cfg::web_ctx
}

#serve elm webapp
proc wapp-page-$cfg::web_ctx {} {

	set file [open $cfg::asset_path/index.html r]
	chan configure $file -encoding utf-8 -translation crlf
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

#custom wapp start with tls options
proc wapp-start-custom {cli_options} {
	
	set port 0
	set tls_opts ""
	set server [list wappInt-new-connection wappInt-http-readable server]
	
	if {([llength $cli_options] % 2) != 0} {
		puts "usage: [file dirname $::argv0] -key1 value1 -key2 value2 ..."
		return
	}
	
	foreach {key value} $cli_options {

		switch -exact -- $key {
			-port {
				set port $value
			}			
			-cadir -
			-cafile -
			-certfile -
			-cypher -
			-dhparams -
			-keyfile {
				append tls_opts "$key $value "
			}
			default {
				puts "unknown option: $key"
				return
			}			
		}	
	}
	
	if {! $port} {
		set port $cfg::tcp_port
	}
	
	if {$tls_opts ne ""} {
		package require tls
		tls::socket -server $server {*}$tls_opts $port
	} else {
		socket -server $server $port
	}
	
    puts "Starting server with options -port $port $tls_opts..."
	vwait ::forever
}

wapp-start-custom $::argv