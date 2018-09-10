console show

#load dependencies

lappend ::auto_path /modules/twapi4.3.5 /modules/wapp1.0
set packages {twapi sqlite3 cron json wapp}

puts "Loading required packages...\n"
foreach pkg $packages {
	puts "\t* $pkg: [package require $pkg]"
}

