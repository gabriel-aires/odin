package require Tk

oo::class create Container {

	variable Name Path

	method setup {name path} {
		set Name $name
		set Path $path
		set frame [frame $Path]
	}

	method parent {} {
		return [join [lrange [split $Path .] 0 end-1] .]
	}

	method id {} {
		return $Path
	}
}

oo::class create Section {
	
	superclass Container

	constructor {args} {
		my setup {*}$args
	}
}

oo::class create Form {

	superclass Container
	variable Children Submit

	constructor {name path entries} {
		my setup $name $path

		foreach {input type} $entries {
			switch $type {
				text {
					set widget [TxtInput new [my id] $input]
					dict set Children $widget key $input
					dict set Children $widget type $type
				}
				default {
					error "Unsupported type: $type"
				}
			}
		}

		set Submit [button "[my id].submit" -text "OK" -command "[self] submit"]
	}
}

oo::class create TxtInput {

	variable Config Parent Key Value Submit

	constructor {parent key} {
		set Parent 	$parent
		set Key 	$key
		set Config(label)	[label 	"$Parent.label_$Key" 	-text $Key]
		set Config(entry)	[entry 	"$Parent.entry_$Key" 	-textvariable [my varname Value] -background white -foreground black]
		grid $Config(label) $Config(entry)
	}
}

set entries	{name text exec text pwd text options text}
set app		[Section new "app" ".app"]
set left	[Section new "left" "[$app id].left"]
set right	[Section new "right" "[$app id].right"]
set form	[Form new "form" "[$left id].form" $entries ]

pack [$app id] -fill both
pack [$left id] -side left -fill y
pack [$right id] -side right -fill y
pack [$form id] -side left -expand 1