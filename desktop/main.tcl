#import packages
package require Tk
package require starkit
package require sha256
package require sqlite3

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
source [file join $vfs_root database.tcl]
source [file join $vfs_root dbaccess.tcl]
source [file join $vfs_root container.tcl]
source [file join $vfs_root repository.tcl]
source [file join $vfs_root validation.tcl]
source [file join $vfs_root form.tcl]

oo::class create Login {
  superclass Form
  mixin DbAccess
    	
  method auth_error? {} {
    my variable Db
    
    set name   [my repo_val login]
    set hash   [sha2::sha256 [my repo_val password]]
    set search [$Db query {
          SELECT u.name
          FROM user u
          INNER JOIN user_type t	on u.type_id = t.rowid
          WHERE u.active = 1 AND t.name = 'admin' AND u.name = :name AND u.pass = :hash
    }]

    return [ne $name $search]
  }
    	
  method submit {} {        		
    if {[my input_error?]} {
      my update_help "ERROR"
    } elseif {[my auth_error?]} {
      my update_help "ERROR" "Invalid User/Password"
    } else {
      my update_help "SUCCESS" "Authentication Successful"
    }
        		
    my debug_input
  }	
}

oo::class create AgentConfig {
  superclass Form	
    	
  method submit {} {
    if [my input_error?] {
      my update_help "ERROR"
    }

    my debug_input
  }
}

#initialize configuration
set rules {
  required		    .
  optional		    {}
  task_type		    ^deploy|build$
  password_size		........
}

set login_fields {
  login       text:required
  password		password:required,password_size
}

set config_fields {
  name	  	text:required
  exec	  	text:optional
  pwd	      password:required,password_size
  options	  text:optional
  enable		bool:required
  choose		list:required,task_type
}

#open main database
set db [Database new "[file dirname $::vfs_root]/db/odin.db"]

#main widget layout
set app       [Window new .]
set main	  	[Section new ".main"]
set left		 	[Section new "[$main id].left"]
set right			[Section new "[$main id].right"]

#popups
set auth_popup  	[Window new "[$main id].auth_popup"]
set signin	  		[Login new "[$auth_popup id].login" {} $login_fields $rules ]

set conf_popup  	[Window new "[$main id].conf_popup"]
set form	    		[AgentConfig new "[$conf_popup id].agentconfig" "Agent Settings" $config_fields $rules ]

$app title "Odin Administrator Interface"
$app assign_member [list $main $left $right]
$app assign_resource $db

$auth_popup title "Login"
$auth_popup assign_member $signin
$signin use_db $db

$conf_popup title "Configuration..."
$conf_popup assign_member $form
$conf_popup configure [list -padx 4p -pady 4p]

pack [$main id] -fill both
pack [$left id] -side left -fill y
pack [$right id] -side right -fill y
pack [$signin id]
pack [$form id] -side left -expand 1

tk_optionMenu [$right id].foo myVar Foo Bar Boo Spong Wibble
pack [$right id].foo

$auth_popup focus