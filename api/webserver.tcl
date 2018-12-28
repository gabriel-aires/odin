#load webserver configuration
namespace eval conf {
	set html_path [file join $::vfs_root $html_folder]
	set wrap_path [file join $::vfs_root $wrap_folder]
	set entrypoint "wapp-page-[string trimleft $web_ctx /]"
}

#load wapp framework
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
		html					{set type "text/html" ; set f_config "-encoding utf-8 -translation crlf"}
		txt - log				{set type "text/plain" ; set f_config "-encoding utf-8 -translation crlf"}
		png - jpeg - gif - bmp	{set type "img/$ext" ; set f_config "-translation binary"}
		default					{set type "application/octet-stream"; set f_config "-translation binary"}
	}

	set file [open $asset r]
	chan configure $file {*}$f_config
	set content [read $file]
	close $file

	wapp-mimetype $type
	wapp-unsafe $content

}

#generate http response if endpoint is available
proc maybe {procname option} {
	if {[llength [info proc $procname]]>0} {
		::utils::log "info" "$procname $option"
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

#route table
proc $conf::entrypoint {} {

	wapp-set-param RESPONSE_SENT 0
	source $::vfs_root/routes.tcl

}

#redirect to webapp
proc wapp-default {} {
	wapp-redirect $conf::web_ctx/
}

#exit webserver thread
proc stop {} {
	::service::shutdown
}

#custom wapp start with tls options
proc start {port tls_opts} {

	set server [list wappInt-new-connection wappInt-http-readable server]

	if {! $port} {
		set port $conf::rest_port
	}

	if {$tls_opts ne ""} {
		package require tls
		tls::socket -server $server {*}$tls_opts $port
	} else {
		socket -server $server $port
	}

  puts "Starting server with options -port $port $tls_opts..."
}

#load procedures for defined endpoints
source [file join $vfs_root endpoints_get.tcl]
