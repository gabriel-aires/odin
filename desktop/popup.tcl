oo::class create PopUp {
    variable PopUps Window Path
    
    constructor {} {
        set PopUps  {}
        set Window  {}
        set Path    {}
    }

    method define {path body} {
        if [my defined? $path] {
            error "Popup $path already defined"
        } else {
            dict set PopUps $path script   $body
            dict set PopUps $path object   {}
        }
    }
    
    method defined? {path} {
        if {$path in [dict keys $PopUps]} {
            return 1
        } else {
            return 0
        }
    }
    
    method active? {path} {
        set obj [dict get $PopUps $path object]
        if {$obj ne {}} {
            return [in $obj [info class instances "Window"]]
        }
        return 0
    }
    
    method Init {path} {
        set Path $path
        set Window [::Window new $Path]
        dict set PopUps $Path object $Window
        set body [dict get $PopUps $Path script]
        uplevel 1 $body
        set Window  {}
        set Path    {}
    }
    
    method Reveal {path} {
        set obj [dict get $PopUps $path object]
        $obj center
    }
       
    method display {path} {
        if [my defined? $path] {
            if [my active? $path] {
                my Reveal $path
            } else {
                my Init $path
            }
        } else {
            error "Popup unknown: $path"
        }
    }
}