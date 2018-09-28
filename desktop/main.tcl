package require Tk

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

oo::class create InputField {
	method label_id {parent key} {
		return "$parent.label_$key"
	}
	
	method input_id {parent key} {
		return "$parent.input_$key"
	}
}

oo::class create Repository {
	variable Repository
	
	method setup_repository {} {
		array set Repository {}
	}
	
	method repo_key {key} {
		return [my varname Repository($key)]
	}
	
	method repo_val {key} {
		return $Repository($key)
	}
	
	method repo_dump {} {
		return [array get Repository]
	}
	
	method repo_print {} {
		parray Repository
	}
}

oo::class create TxtInput {
	mixin -append InputField

	method setup_txt_input {parent key} {
		array set Value {}
		set label [my label_id $parent $key]
		set entry [my input_id $parent $key]
		::ttk::label $label -text $key
		::ttk::entry $entry	-textvariable [my repo_key $key] -background white -foreground black
		grid $label $entry
	}
}

oo::class create Form {
	mixin -append TxtInput
	variable Entries

	method setup_form {fields} {

		foreach {key type} $fields {
			switch -glob -- $type {
				text:* {
					set rule [lindex [split $type :] 1]
					set parent [my id]
					set child [my input_id $parent $key]
					my setup_txt_input $parent $key
					dict set Entries $child name $key
					dict set Entries $child rule $rule
				}
				default {
					puts "Unsupported type: $type"
				}
			}
		}
	}
}

oo::class create Section {
	mixin -append Container
	
	constructor {args} {
		my setup_container {*}$args
	}
}

oo::class create AgentConfig {
	mixin -append Container Form Repository
	
	constructor {args} {
		set name [lindex $args 0]
		set path [lindex $args 1]
		set fields [lindex $args 2]
		
		my setup_repository
		my setup_container $name $path
		my setup_form $fields
		
		set submit [::ttk::button "[my id].submit" -text "Done" -command "[self] submit"]
		grid $submit
	}
	
	method debug {} {
		puts ""
		puts "Data submitted from [my name] at [my parent]"
		puts "-----------------------------------------------------"
		foreach {k v} [my repo_dump] {
			puts "$k:\t$v"
		}
	}
	
	method submit {} {
		my debug
	}
}

set fields	{name text:required exec text:bool pwd text:required options text}
set app		[Section new "app" ".app"]
set left	[Section new "left" "[$app id].left"]
set right	[Section new "right" "[$app id].right"]
set form	[AgentConfig new "agentconfig" "[$left id].agentconfig" $fields ]

pack [$app id] -fill both
pack [$left id] -side left -fill y
pack [$right id] -side right -fill y
pack [$form id] -side left -expand 1