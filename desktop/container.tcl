oo::class create Container {
	variable Path Label

	method setup_container {path {label ""}} {
		set Path $path
		set Label $label
		
		if {$Label eq ""} {		
			::ttk::frame $Path -padding 2p
		} else {
			::ttk::labelframe $Path -text $Label -padding 2p
		}
	}

	method parent {} {
		return [join [lrange [split $Path .] 0 end-1] .]
	}
	
	method name {} {
		return [lindex [split $Path .] end]
	}
	
	method id {} {
		return $Path
	}
	
	method configure {options} {
		$Path configure {*}$options
	}
}

oo::class create Section {
	superclass Container
	
	constructor {args} {
		my setup_container {*}$args
	}
}

