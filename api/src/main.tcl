console show

#initialize auto_path and main variables
lappend ::auto_path /modules/twapi4.3.5 /modules/wapp1.0
set packages {twapi sqlite3 cron json wapp}
set assets [zvfs::list /assets/*]
set pages {}
set default_port 3000

#load required packages
puts "Loading required packages...\n"
foreach pkg $packages {
	puts "\t* $pkg: [package require $pkg]"
}

#find static web assets
puts "\nSearching for static assets...\n"
foreach file $assets {
	puts "\t* $file"
	lappend pages [file tail $file]
}

#dynamically create asset pages
proc get-mimetype {ext} {
	switch $ext {
		html -
		css {return "text/$ext"}
		png {return "image/$ext"}
		default {error "error: unsupported filetype"}
	}
}

foreach page $pages {
	
	set procname "wapp-page-$page"
	set document "/assets/$page"
	set fileext		[lindex [split $page .] end]
	set mimetype	[get-mimetype $fileext]
	set channel		[open $document rb]	
	set content 	[binary decode base64 [read $channel]]
	close $channel
	
	proc $procname {} "wapp-mimetype $mimetype	; foreach line $content [list wapp-subst %unsafe%([string cat \$line])%]"

}

#serve elm webapp
proc wapp-default {} { wapp-redirect "/index.html" }

#start webserver
puts ""
wapp-start "--server $default_port"
