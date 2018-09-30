oo::class create Container {
	variable Name Path

	method setup_container {name path} {
		set Name $name
		set Path $path
		set frame [::ttk::frame $Path]
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
}

oo::class create Section {
	superclass Container
	
	constructor {args} {
		my setup_container {*}$args
	}
}

