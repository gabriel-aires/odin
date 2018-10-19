oo::class create Editor {
	superclass Container
	variable TclCommands EditorScheme ColorSchemes HighlightClasses

	constructor {parent label} {
		my setup_container $parent $label
		my setup_scrollbar
		my setup_text
		set HighlightClasses	{}
		set ColorSchemes		{}
		set EditorScheme		{}
		set TclCommands			{after append array binary break case catch clock close concat continue eof error eval \
			expr fblocked fcopy fileevent flush for foreach format gets global if incr info interp join lappend \
		  	lindex linsert list llength lrange lreplace lsearch lsort namespace package pid proc puts read regexp \
		  	regsub rename return scan seek set split string subst switch tell time trace unset update uplevel upvar \
		  	variable vwait while cd encoding exec exit fconfigure file glob load open pwd socket source \
		}
	}
	
	method colorscheme_choose {name} {
		switch $name {
			Standard {
				my colorscheme_update [list $name white black purple maroon brown green navy chocolate]
			}
			Monokai {
				my colorscheme_update [list $name #222 #ccc firebrick green khaki gray DeepPink DeepSkyBlue]
			}
			Solarized {
				my colorscheme_update [list $name cornsilk DarkSlategray DarkKhaki green MediumSeaGreen DodgerBlue DarkGoldenRod brown]
			}			
			default {
				error "Invalid editor theme: $name"
			}
		}
	}
	
	method colorscheme_update {scheme} {
		set EditorScheme [lindex $scheme 0]
		dict set ColorSchemes $EditorScheme bg			[lindex $scheme 1]
		dict set ColorSchemes $EditorScheme fg			[lindex $scheme 2]
		dict set ColorSchemes $EditorScheme opts		[lindex $scheme 3]
		dict set ColorSchemes $EditorScheme blocks		[lindex $scheme 4]
		dict set ColorSchemes $EditorScheme strings		[lindex $scheme 5]
		dict set ColorSchemes $EditorScheme comments	[lindex $scheme 6]
		dict set ColorSchemes $EditorScheme commands	[lindex $scheme 7]
		dict set ColorSchemes $EditorScheme variables	[lindex $scheme 8]
		my highlight_classes
		my paint_editor
	}
	
	method paint_editor {} {
		my config_text	[list \
			-background [dict get $ColorSchemes $EditorScheme bg] \
			-foreground [dict get $ColorSchemes $EditorScheme fg] \
			-insertbackground [dict get $ColorSchemes $EditorScheme fg] \
			-linemapbg [dict get $ColorSchemes $EditorScheme bg] \
			-linemapfg [dict get $ColorSchemes $EditorScheme fg] \
		]
	}
	
	method highlight_classes {} {
		my highlight_on opts		start \-						[dict get $ColorSchemes $EditorScheme opts]
		my highlight_on blocks		chars {[]{}}					[dict get $ColorSchemes $EditorScheme blocks]
		my highlight_on strings		regex {"[^\"]*"}				[dict get $ColorSchemes $EditorScheme strings]
		my highlight_on comments	regex {^[[:blank:]]*#[^\n\r]*}	[dict get $ColorSchemes $EditorScheme comments]
		my highlight_on commands	words $TclCommands				[dict get $ColorSchemes $EditorScheme commands]
		my highlight_on variables	start \$						[dict get $ColorSchemes $EditorScheme variables]
	}

	method highlight_on {name cond value color} {

		if {$name ni $HighlightClasses} {
			
			lappend HighlightClasses $name
			
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
		set text [ctext [my id].text -yscrollcommand "[my id].scroll set"]
		pack $text -fill both -expand 1
	}
	
	method config_text {opts} {
		[my id].text configure {*}$opts
	}
}
