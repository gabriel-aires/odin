oo::class create Window {
	mixin Event
	variable Path Members Resources

	constructor {path} {
		
		set Path $path
		set Members {}
		set Resources {}
		
		if {$Path ne "."} {
			toplevel [my id]
		}
		
		my bind_method [my id] <Destroy> "destroy"
	}
	
	method id {} {
		return $Path
	}

	method title {title} {
		wm title [my id] $title
	}

	method focus {} {
		grab [my id]
		focus [my id]
		raise [my id]
		wm deiconify [my id]
	}
	
	method unfocus {} {
		grab release [my id]
	}
	
	method center {} {
		raise [my id]
		update
		set x [/ [- [winfo screenwidth .] [winfo width [my id]]] 2]
		set y [/ [- [winfo screenheight .] [winfo height [my id]]] 2]
		wm geometry [my id] +$x+$y
	}
	
	method close {} {
		destroy [my id]
	}

	method configure {options} {
		[my id] configure {*}$options
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
		
		puts "window [my id] destroyed"

	}
}
