oo::class create Sidebar {
    variable Index Container Parent
    
    constructor {parent} {
        set Index       0
        set Parent      $parent
        set Container   [::Section new $parent]
        pack $Parent -side left -fill y
    }

    method install {list} {
        foreach {label command} $list {
            my add_button $label $command
        }   
    }
    
    method add_button {label command} {
        pack [::ttk::button ${Parent}.button_[incr Index] -text $label -padding 5p -command $command] -fill x -pady 12p
    }
    
    destructor {
        destroy $Parent
        $Container destroy
    }
}