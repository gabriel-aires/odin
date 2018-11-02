oo::class create Component {
    mixin Contract
    variable Components CallerNamespace Namespaces Parent
    
    constructor {parent} {
        my setup_contract
        set Components      {}
        set CallerNamespace [uplevel 1 "namespace current"]
        set Namespaces      {}
        set Parent          $parent
        my hire [::Container new $Parent /]
        pack $Parent -fill both -expand 1
    }

    method define {basepath title body} {
        set path ${Parent}.${basepath}
        if [my defined? $path] {
            error "Component $path already defined"
        } else {
            dict set Components $path namespace ${CallerNamespace}::${basepath}
            dict set Components $path title     $title
            dict set Components $path script    $body
            dict set Components $path object    {}
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
        set title       [dict get $Components $path title]
        set script      [dict get $Components $path script]
        set namespace   [dict get $Components $path namespace]
        set frame       [::Container new $path /$title]
        dict set Components $path object $frame
        my hire $frame
        namespace eval $namespace "variable Frame $frame Path $path ; try {$script}"
        lappend Namespaces $namespace
        set options [list -side bottom -anchor e -padx 5p -pady 5p]
        pack [::ttk::button ${path}.close_tab -text "Close" -command "[self] close $path"] {*}$options
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
        foreach ns $Namespaces {
            namespace delete $ns
            puts "namespace $ns deleted"
        }
    }
}