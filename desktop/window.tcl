oo::class create Window {
	mixin Event Holder
	variable Path 

	constructor {path} {
		my setup_contents
		set Path $path
		
		if {$Path ne "."} {
			toplevel $Path
		}
		
		my bind_method $Path <Destroy> "destroy"
	}
	
	method id {} {
		return $Path
	}

	method title {title} {
		wm title $Path $title
	}

	method focus {} {
		my center
		grab $Path
		focus $Path
		raise $Path
		wm deiconify $Path
		wm attributes $Path -topmost 1
	}
	
	method unfocus {} {
		grab release $Path
		wm attributes $Path -topmost 0
	}
	
	method center {} {
		raise $Path
		update
		set x [/ [- [winfo screenwidth .] [winfo width $Path]] 2]
		set y [/ [- [winfo screenheight .] [winfo height $Path]] 2]
		wm geometry $Path +$x+$y
	}
	
	method close {} {
		destroy $Path
	}
	
	method maximize {} {
		if {$::tcl_platform(platform) eq "unix"} {
			wm attributes $Path -zoomed 1
		} else {
			wm state $Path zoomed
		}
	}

	method configure {options} {
		$Path configure {*}$options
	}
		
	destructor {
		my release_resources
		my destroy_members		
		my unfocus
		my close
		puts "window $Path destroyed"
	}
}
