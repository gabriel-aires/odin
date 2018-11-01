oo::class create Contract {
    variable Workers
    
    method setup_contract {} {
        set Workers {}
    }

    method Lremove {deletion list} {
        set newlist {}
        foreach item $list {
            if {$item ni $deletion} {
                lappend newlist $item
            }
        }
        return $newlist
    }

	method hire {objects} {
		lappend Workers {*}$objects
	}

    method dismiss {objects} {
        foreach object $objects {
            catch {$object destroy}
		}
        set Workers [my Lremove $objects $Workers]
    }

    method terminate {} {
        my dismiss $Workers
    }
}