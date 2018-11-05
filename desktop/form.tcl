oo::class create Form {
	superclass Container
	mixin Repository Validation
	variable Entries HelpMsg DefaultColor

	constructor {args} {
		set path	[lindex $args 0]
		set label	[lindex $args 1]
		set fields	[lindex $args 2]
		set rules	[lindex $args 3]
		
		next $path $label
		my setup_repository
		my setup_validation $rules

		foreach {key type} $fields {
			my setup_input $key $type
			my display_input $key	
			set ruleset [lindex [split $type :] 1]
			set child [my input_id $key]
			dict set Entries $child name $key
			dict set Entries $child ruleset $ruleset
		}
		
		my setup_submit
		my display_submit
		my setup_help
		my display_help	
		set DefaultColor [lindex [my config_help -foreground] end]
	}
	
	method input_label {key} {
		return "[my id].label_$key"
	}
	
	method input_id {key} {
		return "[my id].input_$key"
	}
	
	method setup_input {key type} {
		
		set label			[my input_label $key]
		set entry			[my input_id $key]
		set ruleset			[split [lindex [split $type :] 1] ,]
		set width			30
		set name			$key
		
		if {"required" in $ruleset} {
			append name { *}
		}
		
		switch -glob $type {
			text:* {
				::ttk::label $label -text $name
				::ttk::entry $entry	-textvariable [my repo_key $key] -width $width
			}
			password:* {
				::ttk::label $label -text $name
				::ttk::entry $entry	-textvariable [my repo_key $key] -show "*" -width $width
			}
			bool:* {
				::ttk::label $label -text $name
				::ttk::checkbutton $entry -variable [my repo_key $key]
			}
			list:* {
				set rule [lindex $ruleset end]
				set pattern [my get_rule $rule]
				set values [split [string trimright [string trimleft $pattern ^] $] |]
				::ttk::label $label -text $name
				::ttk::combobox $entry -textvariable [my repo_key $key] -state readonly -values $values -width [- $width 3]
			}
			default {
				puts "Unsuported type: $type" 	
			}
		}
	}
	
	method display_input {key} {
		set label [my input_label $key]
		set entry [my input_id $key]
		grid $label $entry -padx 2p -pady 2p -sticky w
	}
	
	method setup_help {} {
		set HelpMsg "Enter required information (*)"
		::ttk::label "[my id].help" -text $HelpMsg -justify center		
	}
	
	method config_help {options} {
		[my id].help configure {*}$options
	}
	
	method update_help {level {msg ""}} {
		if {$msg ne ""} {
			set HelpMsg $msg
		}
		
		switch $level {
			INFO {
				my config_help [list -text $HelpMsg -foreground $DefaultColor]
			}
			ERROR {
				my config_help [list -text $HelpMsg -foreground #c3063c]
			}
			SUCCESS {
				my config_help [list -text $HelpMsg -foreground #2bdb64]		
			}
		}
	}
	
	method display_help {} {
		set window "[my id].help"
		grid $window -columnspan 2
			
	}
	
	method setup_submit {} {
		::ttk::button "[my id].submit" -text "OK" -command "[self] submit"
	}

	method display_submit {} {
		set button "[my id].submit"
		grid $button -columnspan 2 -pady 4p
	}

	method debug_input {} {
		puts ""
		puts "Data submitted from [my name] at [my parent]"
		puts "-----------------------------------------------------"
		foreach {k v} [my repo_dump] {
			puts "$k:\t$v"
		}
	}
	
	method input_error? {} {
		set details {}
		set error	0
		
		foreach child [dict keys $Entries] {
			set key			[dict get $Entries $child name]
			set value			[my repo_val $key]
			set rule_list		[dict get $Entries $child ruleset]
			set rules			[split $rule_list ,]
			
			foreach rule $rules {
				if [! [my match_rule $rule $value]] {
					lappend details "Invalid input for $key ($rule)"
					set error 1
				}
			}
		}
		
		set HelpMsg [join $details "\n"]
		return $error
	}
}
