oo::class create Container {
	variable Path Label

	method setup_container {path {label ""}} {
		set Path $path
		set Label $label
		set default_options [list -padding 5p]
		
		switch -glob $Label {
			/				{::ttk::notebook $Path {*}$default_options ; ::ttk::notebook::enableTraversal $Path}
			/*				{::ttk::frame $Path {*}$default_options ;	[my parent] add $Path -text [string trimleft $Label /]}
			[A-z]*		{::ttk::labelframe $Path -text $Label {*}$default_options}
			default	{::ttk::frame $Path {*}$default_options}
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
