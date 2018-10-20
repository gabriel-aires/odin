oo::class create Toolbar {
	superclass Container
	mixin Repository
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
	
	method add_selector {name label method values} {
		if {$name in $Controls} {
			error "Control already registered for [my id]: $name"
		} elseif {$Widget eq {}} {
			error "No widget assigned for toolbar [my id]"
		} else {
			lappend Controls $name
			lappend Elements [::ttk::label	[my id].label_$name -text $label]
			lappend Elements [::ttk::combobox [my id].input_$name -textvariable [my repo_key $name] -state readonly -values $values]
			bind [my id].input_$name <<ComboboxSelected>> "if \{\"%W\" eq \"[my id].input_$name\"\} \{[self] send_command $method $name\}"
		}
	}
	
	method send_command {method name} {
		set cmd [list $Widget $method [my repo_val $name]]
		uplevel 1 $cmd
	}
	
	method display_toolbar {} {
		grid {*}$Elements
	}
}
