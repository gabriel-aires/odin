#import packages
package require Tk
package require starkit

#initialize starpack
starkit::startup
set vfs_root [file dirname [file normalize [info script]]]

#import classes
source [file join $vfs_root container.tcl]
source [file join $vfs_root form.tcl]

oo::class create AgentConfig {
	mixin Form
	
	method submit {} {
		my debug_input
	}
}

set fields			{name text:required exec text:bool pwd text:required options text:optional}
set app			[Section new "app" ".app"]
set left			[Section new "left" "[$app id].left"]
set right			[Section new "right" "[$app id].right"]
set form			[AgentConfig new "agentconfig" "[$left id].agentconfig" $fields ]

pack [$app id] -fill both
pack [$left id] -side left -fill y
pack [$right id] -side right -fill y
pack [$form id] -side left -expand 1
