#initialization
package require Thread
package require starkit
package require json

starkit::startup
set vfs_root $::starkit::topdir
source [file join $vfs_root common include.tcl]
source [file join $vfs_root service.tcl]

namespace eval conf {
	dict with ::settings targets server {}
	setup_path
}

#start worker threads
foreach worker {database scheduler webserver} {
	::service::startup $worker
}

#start daemon
proc main {cli_options} {

  set adm_port $conf::admin_port
	set web_port 0
	set tls_opts {}

	if {([llength $cli_options] % 2) != 0} {
		puts "usage: [file dirname $::argv0] -key1 value1 -key2 value2 ..."
		return
	}

	foreach {key value} $cli_options {
		switch -exact -- $key {
      -admport    {set adm_port $value}
			-webport 		{set web_port $value}
			-cadir -
			-cafile -
			-certfile -
			-cypher -
			-dhparams -
			-keyfile 		{append tls_opts "$key $value "}
			default 		{puts "unknown option: $key" ; return}
		}
	}

	#start webserver
	::service::call webserver start $web_port $tls_opts

	socket -server listen $adm_port

	#enter main event loop
	vwait ::shutdown
}

proc receive {sock} {
	set msg [chan gets $sock]
	switch $msg --exact {
		test	{puts $sock OK ; chan close $sock}
		default {chan close $sock; error "Unknown message"}
	}
}

proc listen {sock ip port} {
	chan configure $sock -buffering line -encoding utf-8 -blocking 0 -translation auto
	chan event $sock readable [list receive $sock]
}

main $::argv
