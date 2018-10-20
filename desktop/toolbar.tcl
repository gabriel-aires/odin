oo::class create Toolbar {
	superclass Container
	mixin Repository Event
	variable Widget Controls Elements
	
	constructor {parent label} {
		my setup_container $parent $label
		my setup_repository
		set Widget {}
		set Controls {}
	}
	
	method assign {widget} {
		set Widget $widget
	}
	
	method add_control {name} {
		if {$name in $Controls} {
			error "Control already registered for [my id]: $name"
		} elseif {$Widget eq {}} {
			error "No widget assigned for toolbar [my id]"
		} else {
			lappend Controls $name
		}
	}
	
	method add_selector {name label method values} {
		my add_control $name
		lappend Elements [::ttk::label	[my id].label_$name -text $label]
		lappend Elements [::ttk::combobox [my id].input_$name -textvariable [my repo_key $name] -state readonly -values $values]
		my bind_method "[my id].input_$name" <<ComboboxSelected>> "send_command $method $name"
	}
	
	method send_command {method name} {
		set cmd [list $Widget $method [my repo_val $name]]
		uplevel 1 $cmd
	}
	
	method display_toolbar {} {
		grid {*}$Elements
	}
}
