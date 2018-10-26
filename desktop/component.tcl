oo::class create Component {
    mixin Holder
    variable Components Container Path Parent
    
    constructor {parent} {
        my setup_contents
        set Components  {}
        set Path        {}
        set Parent      $parent
        set Container   [::Section new $parent /]
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
    
    destructor {    
        my release_resources
        my destroy_members
        destroy $Parent
        $Container destroy
    }
}