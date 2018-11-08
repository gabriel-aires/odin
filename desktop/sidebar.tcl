oo::class create Sidebar {
    mixin Contract
    variable Index Container Parent

    constructor {parent} {
        set Index       0
        set Parent      $parent
        my hire [::Container new $Parent]
        pack $Parent -side left -fill y
    }

    method install {list} {
        foreach {label command} $list {
            my add_button $label $command
        }
    }

    method add_button {label command} {
        set name "${Parent}.button_[incr Index]"
        if {$Index == 1} {
          set pady {8p 3p}
        } else {
          set pady "3p"
        }
        pack [::ttk::button $name -text $label -padding 3p -command $command] -fill x -pady $pady
    }

    destructor {
        my terminate
    }
}

