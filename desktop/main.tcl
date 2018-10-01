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
source [file join $vfs_root container.tcl]
source [file join $vfs_root repository.tcl]
source [file join $vfs_root form.tcl]

oo::class create AgentConfig {
	mixin Form
	
	method submit {} {
		my debug_input
	}
}

set fields			{name text:required exec text:optional pwd password:required options text:optional enable bool:required choose list:required,deploy,build}
set app			[Section new ".app"]
set left			[Section new "[$app id].left"]
set right			[Section new "[$app id].right"]
set form			[AgentConfig new "[$left id].agentconfig" "Agent Settings" $fields ]

pack [$app id] -fill both
pack [$left id] -side left -fill y
pack [$right id] -side right -fill y
pack [$form id] -side left -expand 1
