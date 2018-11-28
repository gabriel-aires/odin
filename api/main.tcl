#import packages
package require Thread
package require starkit
starkit::startup

#startup configuration
set shutdown 0
set startup [format {
	package require json

	set argv0			%s
	set vfs_root 	%s
	source [file join $vfs_root common include.tcl]

	namespace eval conf {
		dict with ::settings targets server {}
		setup_path
	}

	namespace eval service {
		set workers {}
		set master 	%s
		set self		[thread::id]
	}

	source [file join $vfs_root include.tcl]
} $::argv0 $::starkit::topdir [thread::id]]

#initialize main thread
eval $startup

#setup worker threads
foreach worker {database scheduler webserver} {
	::service::add_worker $worker [thread::create [format {
		%s
		source [file join $vfs_root %s.tcl]
		thread::wait
	} $startup $worker]]
}

# inform workers about other threads
foreach {name id} $service::workers {
	thread::broadcast [list ::service::add_worker $name $id]
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
