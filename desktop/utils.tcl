oo::class create Utils {

    method Lremove {deletion list} {
        set newlist {}
        foreach item $list {
            if {$item ni $deletion} {
                lappend newlist $item
            }
        }
        return $newlist
    }
}
