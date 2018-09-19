#import packages
package require starkit
package require json

#initialize starpack
starkit::startup
set vfs_root [file dirname [file normalize [info script]]]

#read configuration
set json_file [open $vfs_root/tcl.json r]
set conf [::json::json2dict [read $conf_file]]
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

#generate http response if endpoint is available
proc maybe {procname option} {
	if {[llength [info proc $procname]]>0} {
		$procname $option
	} else {
		wapp-default
	}
}

#route requests from entrypoint
proc route {method path} {
	
	set request_method [wapp-param REQUEST_METHOD]
	set request_path [wapp-param PATH_INFO]
	set route [file join $conf::web_ctx $path]
	
	if {$method != $request_method} {
		return
	
	} elseif {! [string match $route $request_path]} {
		return
	
	} else {		
		switch -glob $route {
			$conf::web_ctx {
				wapp-set-param ENDPOINT index
				wapp-set-param PATH_VAR {}
			}
			*[a-z] {
				wapp-set-param ENDPOINT [string map {/ -} $path]
				wapp-set-param PATH_VAR {}
			}
			*/\* {
				wapp-set-param ENDPOINT [string map {/* "" / -} $path]
				wapp-set-param PATH_VAR [string replace $request_path 0 [string length $conf::web_ctx/[wapp-param ENDPOINT]]]
			}
			default {
				wapp-reply-code "500 Internal Server Error"
				wapp-trim "<h1>500 - Internal Server Error/h1>"
				error "invalid route: $route"
			}
		}
		
		maybe endpoint-[string tolower $method]-[wapp-param ENDPOINT] [wapp-param PATH_VAR]
	}
}

#main HTTP verbs
proc GET {path} {
	route GET path
}

proc POST {path} {
	route POST path
}

proc PUT {path} {
	route PUT path 
}

proc DELETE {path} {
	route DELETE path
}

#serve elm webapp
proc endpoint-get-index {} {
	wapp-allow-xorigin-params
	wapp-content-security-policy "off"
	serve $conf::asset_path/index.html
}

#serve static assets
proc endpoint-get-$conf::asset_folder {asset_name} {
	if {$asset_name in $conf::web_assets} {
		serve $conf::asset_path/$asset_name
	} else {
		wapp-default
	}
}

#route table
proc $conf::entrypoint {} {

	GET /
	GET $conf::asset_folder/*

}

#default response: 404
proc wapp-default {} {
	wapp-reply-code "404 Not Found"
	wapp-subst "<h1>404 - Not Found</h1>"
	
	foreach line [split [wapp-debug-env] "\n"] {
		wapp-unsafe "<br>$line"
	}
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