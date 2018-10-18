oo::class create Editor {
	superclass Container
	variable HighlightClasses

	constructor {parent label} {
		my setup_container $parent $label
		my setup_scrollbar
		my setup_text
		set HighlightClasses {}
	}

	method setup_scrollbar {} {
		set scroll [ttk::scrollbar [my id].scroll -command "[my id].text yview"]
		pack $scroll -side right -fill y
	}

	method setup_text {} {
		set text [ctext [my id].text -background #222 -foreground #ccc -yscrollcommand "[my id].scroll set"]
		pack $text -fill both -expand 1
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
}