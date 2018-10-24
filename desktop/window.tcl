oo::class create Window {
	mixin Event
	variable Path Members Resources

	constructor {path} {
		
		set Path $path
		set Members {}
		set Resources {}
		
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

	method configure {options} {
		$Path configure {*}$options
	}
	
	method assign_member {objects} {
		lappend Members {*}$objects
	}
	
	method assign_resource {objects} {
		lappend Resources {*}$objects
	}	
		
	destructor {
		
		foreach resource $Resources {
			$resource destroy
			puts "resource $resource released"
		}
		
		foreach member $Members {
			if [info exists $member] {
				set path [$member id]
				$member destroy
				catch {destroy $path}
				puts "window $path destroyed"
			}
		}			
		
		my unfocus
		my close
		
		puts "window $Path destroyed"

	}
}
