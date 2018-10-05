#import packages
package require Tk
package require starkit

#initialize starpack
starkit::startup
set vfs_root [file dirname [file normalize [info script]]]

#import namespaces
namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::abs
namespace import ::tcl::mathfunc::ceil
namespace import ::tcl::mathfunc::floor
namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min
namespace import ::tcl::mathfunc::rand
namespace import ::tcl::mathfunc::round
namespace import ::tcl::mathfunc::srand

#import classes
source [file join $vfs_root window.tcl]
source [file join $vfs_root container.tcl]
source [file join $vfs_root repository.tcl]
source [file join $vfs_root validation.tcl]
source [file join $vfs_root form.tcl]

oo::class create AgentConfig {
	superclass Form
	
	method submit {} {
		my validate_form
		my debug_input
	}
}

set rules {
	required		.
	optional		{}
	task_type	^deploy|build$
	min_size		......
}

set fields {
	name		text:required
	exec		text:optional
	pwd		password:required,min_size
	options		text:optional
	enable		bool:required
	choose		list:required,task_type
}

#main widget layout
set main			[Window new .]
set app			[Section new ".app"]
set left			[Section new "[$app id].left"]
set right			[Section new "[$app id].right"]

#popups
set conf_popup	[Window new "[$app id].conf_popup"]
set form			[AgentConfig new "[$conf_popup id].agentconfig" "Agent Settings" $fields $rules ]

$main assign_members [list $app $left $right]
$main title "Odin Administrator Interface"
$conf_popup assign_members $form
$conf_popup configure [list -padx 4p -pady 4p]
$conf_popup title "Configuration..."

pack [$app id] -fill both
pack [$left id] -side left -fill y
pack [$right id] -side right -fill y
pack [$form id] -side left -expand 1

tk_optionMenu [$right id].foo myVar Foo Bar Boo Spong Wibble
pack [$right id].foo
