oo::class create Component {
    mixin Contract
    variable Components Path Parent Frame
    
    constructor {parent} {
        my setup_contract
        set Components  {}
        set Path        {}
        set Frame       {}
        set Parent      $parent
        my hire [::Container new $Parent /]
        pack $Parent -fill both -expand 1
    }

    method define {basepath title body} {
        set path ${Parent}.${basepath}
        if [my defined? $path] {
            error "Component $path already defined"
        } else {
            dict set Components $path title    $title            
            dict set Components $path script   $body
            dict set Components $path object   {}
        }
    }
    
    method defined? {path} {
        if {$path in [dict keys $Components]} {
            return 1
        } else {
            return 0
        }
    }
    
    method active? {path} {
        set obj [dict get $Components $path object]
        if {$obj ne {}} {
            return [in $obj [info class instances "Container"]]
        }
        return 0
    }
    
    method Init {path} {
        set Path $path
        set title [dict get $Components $Path title]
        set body [dict get $Components $Path script]
        set Frame [::Container new $Path /$title]
        dict set Components $Path object $Frame
        my hire $Frame
        uplevel 1 $body
        set options [list -side bottom -anchor e -padx 5p -pady 5p]
        pack [::ttk::button ${Path}.close_tab -text "Close" -command "[self] close $Path"] {*}$options
        set Path {}
        set Frame {}
    }

    method Reveal {path} {
        $Parent select $path
    }
       
    method display {basepath} {
        set path ${Parent}.${basepath}
        if [my defined? $path] {
            if [my active? $path] {
                my Reveal $path
            } else {
                my Init $path
            }
        } else {
            error "Component unknown: $path"
        }
    }
    
    method close {path} {
        if [my active? $path] {
            $Parent forget $path            
            my dismiss [dict get $Components $path object]
            dict set Components $path object {}
        }
    }
    
    destructor {
        my terminate
    }
}