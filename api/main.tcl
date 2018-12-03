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

	set web_port 0
	set tls_opts {}

	if {([llength $cli_options] % 2) != 0} {
		puts "usage: [file dirname $::argv0] -key1 value1 -key2 value2 ..."
		return
	}

	foreach {key value} $cli_options {
		switch -exact -- $key {
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

	#enter main event loop
	vwait ::shutdown
}

main $::argv
