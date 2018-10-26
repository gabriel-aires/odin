oo::class create Holder {
    variable Members Resources
    
    method setup_contents {} {
        set Members     {}
		set Resources   {}
    }
    
	method assign_member {objects} {
		lappend Members {*}$objects
	}

    method destroy_members {} {
		foreach member $Members {
			if [info exists $member] {
				set path [$member id]
				$member destroy
				catch {destroy $path}
				puts "window $path destroyed"
			}
		}
    }
    	
	method assign_resource {objects} {
		lappend Resources {*}$objects
	}

    method release_resources {} {
		foreach resource $Resources {
			$resource destroy
			puts "resource $resource released"
		}
    }
}