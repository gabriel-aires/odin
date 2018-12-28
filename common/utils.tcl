namespace eval ::utils {

    proc log {type msg} {
      set channel $::conf::log
      set level   [string toupper $type]
      set origin  [string toupper [info hostname]]
      set seconds [string toupper [clock format [clock seconds]]]
      set record  [join [list $level $origin $seconds $msg] \t]
      puts $channel $record
    }

    proc lremove {deletion list} {
        set newlist {}
        foreach item $list {
            if {$item ni $deletion} {
                lappend newlist $item
            }
        }
        return $newlist
    }
}
