oo::class create Form {
	superclass Container
	mixin Repository Validation
	variable Entries

	constructor {args} {
		
		set path 		[lindex $args 0]
		set label		[lindex $args 1]
		set fields [lindex $args 2]
		set rules		[lindex $args 3]
		
		my setup_container $path $label
		my setup_repository
		my setup_validation $rules
		set parent [my id]

		foreach {key type} $fields {
			my setup_input $parent $key $type
			my display_input $parent $key	
			set rule [lindex [split $type :] 1]
			set child [my input_id $parent $key]
			dict set Entries $child name $key
			dict set Entries $child ruleset $rule
		}
		
		my setup_submit $parent
		my display_submit $parent
		
	}
	
	method input_label {parent key} {
		return "$parent.label_$key"
	}
	
	method input_id {parent key} {
		return "$parent.input_$key"
	}
	
	method setup_input {parent key type} {
		
		set label [my input_label $parent $key]
		set entry [my input_id $parent $key]
		set width 30
		
		switch -glob $type {
			text:optional* - text:required* {
				::ttk::label $label -text $key
				::ttk::entry $entry	-textvariable [my repo_key $key] -background white -foreground black	-width $width
			}
			password:optional* - password:required* {
				::ttk::label $label -text $key
				::ttk::entry $entry	-textvariable [my repo_key $key] -show "*" -background white -foreground black -width $width
			}
			bool:optional* - bool:required* {
				::ttk::label $label -text $key
				::ttk::checkbutton $entry -variable [my repo_key $key]
			}
			list:optional* - list:required* {
				set rule [lindex [split $type ,] 1]
				set pattern [my get_rule $rule]
				set values [split [string trimright [string trimleft $pattern ^] $] |]
				::ttk::label $label -text $key
				::ttk::combobox $entry -textvariable [my repo_key $key] -state readonly -values $values -width [- $width 3]
			}
			default {
				puts "Unsuported type: $type" 	
			}
		}
	}
	
	method display_input {parent key} {
		set label [my input_label $parent $key]
		set entry [my input_id $parent $key]
		grid $label $entry -padx 2p -pady 2p -sticky w
	}
	
	method setup_submit {parent} {
		::ttk::button "$parent.submit" -text "OK" -command "[self] submit"
	}

	method display_submit {parent} {
		set button "$parent.submit"
		grid $button -padx 2p -pady 2p -columnspan 2
	}

	method debug_input {} {
		puts ""
		puts "Data submitted from [my name] at [my parent]"
		puts "-----------------------------------------------------"
		foreach {k v} [my repo_dump] {
			puts "$k:\t$v"
		}
	}	
}

