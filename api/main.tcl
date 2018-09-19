#import packages
package require starkit
package require json

#initialize starpack
starkit::startup
set vfs_root [file dirname [file normalize [info script]]]

#read configuration
set json_file [open $vfs_root/tcl.json r]
set conf [::json::json2dict [read $json_file]]
close $json_file

namespace eval conf {

	dict with conf {}
	dict with conf targets server {}

	set packages {sqlite3 cron json wapp}
	set asset_path [file join $vfs_root $asset_folder]
	set mod_path [file join $vfs_root $mod_folder]
	set entrypoint "wapp-page-[string trimleft $web_ctx /]"
	set default_port 3000

}

#adjust auto_path and load wapp framework
lappend ::auto_path $conf::mod_path/twapi4.3.5 $conf::mod_path/wapp1.0
package require wapp

#http errors
proc ERROR {code} {

	if {[wapp-param RESPONSE_SENT]} {
		return

	} else {
		switch $code {
			403		{set msg "403 Forbidden"}
			404		{set msg "404 Not Found"}
			default {set msg "500 Internal Server Error"}
		}

		wapp-reply-code $msg
		wapp-trim "<h1>$msg</h1>"
		wapp-set-param RESPONSE_SENT 1
	}
}

#serve static assets
proc serve {asset} {
	
	set ext [ string range [file extension $asset] 1 end ]
	switch  $ext {
		html					{set mimetype "text/html" 				; set f_config "-encoding utf-8 -translation crlf"}
		txt - log				{set mimetype "text/plain"				; set f_config "-encoding utf-8 -translation crlf"}
		png - jpeg - gif - bmp	{set mimetype "img/$ext"				; set f_config "-translation binary"}
		default					{set mimetype "application/octet-stream"; set f_config "-translation binary"}
	}
	
	set file [open $asset r]
	chan configure $file {*}$f_config
	set content [read $file]
	close $file
	
	wapp-mimetype $mimetype
	wapp-unsafe $content
	
}

proc log {msg} {
	puts "[clock format [clock seconds]]\t$msg"
}

#generate http response if endpoint is available
proc maybe {procname option} {
	if {[llength [info proc $procname]]>0} {
		log "$procname $option"
		$procname $option
		wapp-set-param RESPONSE_SENT 1
	} else {
		wapp-default
	}
}

#route requests from entrypoint
proc route {method raw_path} {
	
	set done [wapp-param RESPONSE_SENT]
	set request_method [wapp-param REQUEST_METHOD]
	set request_path [string trimright [wapp-param PATH_INFO] /]
	set path [string trim $raw_path /]
	set route [file join $conf::web_ctx $path]
	
	if {$done} {
		return

	} elseif {$method != $request_method} {
		return
	
	} elseif {! [string match $route $request_path]} {
		return
	
	} else {
		set ep [string map {/* "" /? "" * "" ? "" / -} $path]
		set endpoint [expr {$ep ne {} ? $ep : {index}}]
		set urlparam [string replace $request_path 0 [string length $conf::web_ctx/$ep]]
		set procname "endpoint-[string tolower $method]-$endpoint"
		maybe $procname $urlparam

	}
}

#main HTTP verbs
proc GET {path} {
	route GET $path
}

proc POST {path} {
	route POST $path
}

proc PUT {path} {
	route PUT $path 
}

proc DELETE {path} {
	route DELETE $path
}

#serve elm webapp
proc endpoint-get-index {_} {
	wapp-allow-xorigin-params
	wapp-content-security-policy "off"
	serve $conf::asset_path/index.html
}

#serve static assets
proc endpoint-get-$conf::asset_folder {asset_name} {
	if {$asset_name in $conf::web_assets} {
		serve $conf::asset_path/$asset_name
	} else {
		ERROR 404
	}
}

#route table
proc $conf::entrypoint {} {

	wapp-set-param RESPONSE_SENT 0

	GET $conf::asset_folder/*
	GET /
	ERROR 404
}

#redirect to webapp
proc wapp-default {} {
	wapp-redirect $conf::web_ctx/
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
			-port {set port $value}
			-cadir - -cafile - -certfile - -cypher - -dhparams - -keyfile {append tls_opts "$key $value "}
			default {puts "unknown option: $key" ; return}			
		}
	}
	
	if {! $port} {
		set port $conf::tcp_port
	}
	
	if {$tls_opts ne ""} {
		package require tls
		tls::socket -server $server {*}$tls_opts $port
	} else {
		socket -server $server $port
	}
	
    puts "Starting server with options -port $port $tls_opts..."
	vwait ::stop
}

wapp-start-custom $::argv