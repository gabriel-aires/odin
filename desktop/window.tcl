oo::class create Window {
	variable Path Members

	constructor {path} {
		set Path $path
		set Members {}
		if {$Path ne "."} {
			toplevel $Path
		}
	}
	
	method id {} {
		return $Path
	}

	method title {title} {
		wm title [my id] $title
	}

	method configure {options} {
		[my id] configure {*}$options
	}
	
	method assign_members {objects} {
		lappend Members {*}$objects
	}
	
	destructor {
		foreach member $Members {
			catch {destroy [$member id]}
		}
		destroy [my id]
		[self] destroy
	}

}
