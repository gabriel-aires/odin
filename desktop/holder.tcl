oo::class create Holder {
    variable Members Resources
    
    method setup_contents {} {
        set Members     {}
		set Resources   {}
    }

    method remove {value list} {
        set newlist {}
        foreach item $list {
            if {$item ne $value} {
                lappend newlist $item
            }
        }
        return $newlist
    }
    
	method assign_member {objects} {
		lappend Members {*}$objects
	}

    method remove_member {object} {
        set Members [my remove $object $Members]
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

    method remove_resource {object} {
        set Resources [my remove $object $Resources]
    }
    
    method release_resources {} {
		foreach resource $Resources {
			$resource destroy
			puts "resource $resource released"
		}
    }
}