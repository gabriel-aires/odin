oo::class create Window {
	variable Path Members Resources

	constructor {path} {
		
		set Path $path
		set Members {}
		set Resources {}
		
		if {$Path ne "."} {
			toplevel [my id]
		}
		
		bind [my id] <Destroy> "if \{\"%W\" eq \"[my id]\"\} \{[self] destroy\}"
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
		wm attributes [my id] -topmost 1
	}
	
	method unfocus {} {
		grab release [my id]
		wm attributes [my id] -topmost 0
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
			set path [$member id]
			$member destroy
			catch {destroy $path}
			puts "window $path destroyed"
		}			
		
		my unfocus
		my close
		
		puts "window [my id] destroyed"

	}
}
