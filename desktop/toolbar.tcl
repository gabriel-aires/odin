oo::class create Toolbar {
	superclass Container
	mixin Repository Event
	variable Widget Controls Elements

	constructor {parent label} {
		next $parent $label
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

	method parse_values {values} {
		set parsed_values {}
		set default_value {}
		foreach value $values {
			if [regexp {\+$} $value] {
				set default_value [string trimright $value +]
				lappend parsed_values $default_value
			} else {
				lappend parsed_values $value
			}
		}
		return [list $parsed_values $default_value]
	}

	method add_spacer {} {
		lappend Elements x
	}

	method config {prefix name option value} {
		set widget [my id].${prefix}_$name
		if [in $widget $Elements] {
			$widget configure $option $value
		} else {
			error "error: element $widget not found."
		}
	}

	method add_button {name label command} {
		my add_control $name
		lappend Elements [::ttk::button	[my id].button_$name -text $label -command $command -width -10]
	}

	method add_selector {name label method values} {
		my add_control $name
		lassign [my parse_values $values] options default_option
		lappend Elements [::ttk::label	[my id].selector_label_$name -text $label]
		lappend Elements [::ttk::combobox [my id].selector_input_$name -textvariable [my repo_key $name] -state readonly -values $options]
		[my id].selector_input_$name set $default_option
		my send_command $method $name
		my bind_method "[my id].selector_input_$name" <<ComboboxSelected>> "send_command $method $name"
	}

	method send_command {method name} {
		set cmd [list $Widget $method [my repo_val $name]]
		uplevel 1 $cmd
	}

	method display_toolbar {} {
		grid {*}$Elements -sticky ew
		set spacers [lsearch -exact -all $Elements x]
		if {$spacers ne {}} {
			grid columnconfigure [my id] $spacers -weight 1 -uniform spacers
		}
	}
}
