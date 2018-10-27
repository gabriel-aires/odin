oo::class create Component {
    mixin Holder
    variable Components Container Path Parent
    
    constructor {parent} {
        my setup_contents
        set Components  {}
        set Path        {}
        set Parent      $parent
        set Container   [::Section new $parent /]
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
            return [in $obj [info class instances "Section"]]
        }
        return 0
    }
    
    method Init {path} {
        set Path $path
        set title [dict get $Components $Path title]
        set body [dict get $Components $Path script]
        set resource [::Section new $Path /$title]
        dict set Components $Path object $resource
        my assign_resource $resource
        my assign_member $Path
        uplevel 1 $body
        set options [list -side bottom -anchor e -padx 5p -pady 5p]
        pack [::ttk::button ${Path}.close_tab -text "Close" -command "[self] close $Path"] {*}$options
        set Path {}
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
            set child [dict get $Components $path object]
            dict set Components $path object {}
            my remove_member $path
            my remove_resource $child
            $child destroy
            $Parent forget $path
            destroy $path
        }
    }
    
    destructor {    
        my release_resources
        my destroy_members
        destroy $Parent
        $Container destroy
    }
}