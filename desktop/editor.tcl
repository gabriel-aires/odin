oo::class create Editor {
	superclass Container
	variable TclCommands EditorScheme ColorSchemes HighlightClasses

	constructor {parent label} {
		my setup_container $parent $label
		my setup_scrollbar
		my setup_text
		set HighlightClasses 				{}
		set ColorSchemes 					{}
		set EditorScheme					{}
		set TclCommands {
			after append array binary break case catch clock close concat continue eof error eval \
			expr fblocked fcopy fileevent flush for foreach format gets global if incr info interp join lappend \
		  	lindex linsert list llength lrange lreplace lsearch lsort namespace package pid proc puts read regexp \
		  	regsub rename return scan seek set split string subst switch tell time trace unset update uplevel upvar \
		  	variable vwait while cd encoding exec exit fconfigure file glob load open pwd socket source \
		}
	}
	
	method colorscheme_choose {name} {
		switch $name {
			"Monokai" {
				dict set ColorSchemes $name blocks 			firebrick
				dict set ColorSchemes $name strings 		khaki
				dict set ColorSchemes $name comments		gray
				dict set ColorSchemes $name commands		DeepPink
				dict set ColorSchemes $name variables	DeepSkyBlue
				set EditorScheme $name
				my config_text	{-background #222 -foreground #ccc -insertbackground white}
				my highlight_classes
			}
			default {
				error "Invalid editor theme: $name"
			}
		}
	}
	
	method highlight_classes {} {
		my highlight_on blocks    chars {[]{}}         												[dict get $ColorSchemes $EditorScheme blocks]
		my highlight_on strings   regex {"[^\"]*"}     												[dict get $ColorSchemes $EditorScheme strings]
		my highlight_on comments  regex {^[[:blank:]]*#[^\n\r]*} 			[dict get $ColorSchemes $EditorScheme comments]
		my highlight_on commands  words $TclCommands 												[dict get $ColorSchemes $EditorScheme commands]
		my highlight_on variables start \$             												[dict get $ColorSchemes $EditorScheme variables]
	}

	method highlight_on {name cond value color} {

		if {$name ni $HighlightClasses} {

			switch $cond {
				words {
					::ctext::addHighlightClass [my id].text $name $color $value
				}
				start {
					::ctext::addHighlightClassWithOnlyCharStart [my id].text $name $color $value
				}
				chars {
					::ctext::addHighlightClassForSpecialChars [my id].text $name $color $value
				}
				regex {
					::ctext::addHighlightClassForRegexp [my id].text $name $color $value
				}
			}

		} else {
			error "Highlight Class $name already exists."
		}
	}
		
	method setup_scrollbar {} {
		set scroll [ttk::scrollbar [my id].scroll -command "[my id].text yview"]
		pack $scroll -side right -fill y
	}

	method setup_text {} {
		set text [ctext [my id].text -background #222 -foreground #ccc -yscrollcommand "[my id].scroll set"]
		pack $text -fill both -expand 1
	}
	
	method config_text {options} {
		[my id].text configure {*}$options
	}
}
