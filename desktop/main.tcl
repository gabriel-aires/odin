#import packages
package require Tk
package require starkit
package require sha256
package require sqlite3
package require json

#initialize starpack
starkit::startup
set vfs_root [file dirname [file normalize [info script]]]

#load settings
set json_file [open $vfs_root/tcl.json r]
set conf [::json::json2dict [read $json_file]]
close $json_file

namespace eval conf {
  
  dict with conf {}
  dict with conf targets desktop {}
  
  set asset_path  [file join $vfs_root $asset_folder]
  set schema_path [file join $vfs_root $db_folder]
  set mod_path    [file join $vfs_root $mod_folder]
  set db_path     [file join [pwd] "odin.db"]

}

lappend ::auto_path $conf::mod_path/awthemes2.2 $conf::mod_path/ctext3.3 $conf::mod_path/menubar0.5
package require ttk::theme::awdark
package require ttk::theme::awlight
package require ctext
package require menubar

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
source [file join $vfs_root event.tcl]
source [file join $vfs_root theme.tcl]
source [file join $vfs_root window.tcl]
source [file join $vfs_root popup.tcl]
source [file join $vfs_root database.tcl]
source [file join $vfs_root dbaccess.tcl]
source [file join $vfs_root container.tcl]
source [file join $vfs_root editor.tcl]
source [file join $vfs_root repository.tcl]
source [file join $vfs_root toolbar.tcl]
source [file join $vfs_root validation.tcl]
source [file join $vfs_root form.tcl]

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

#main window
proc main {} {
  
  #popups
  $::popup define [$::main id].conf_popup {
    set form [Form new ${Path}.agentconfig "Agent Settings" $::config_fields $::rules]

    oo::objdefine $form {        
      method submit {} {
        if [my input_error?] {
          my update_help "ERROR"
        }
        my debug_input
      }
    }

    pack [$form id]
    
    $Window title "Configuration..."
    $Window assign_member $form
    $Window configure [list -padx 4p -pady 4p]
    $Window focus
  }
  
  $::popup define [$::main id].help_popup {
    set about_logo  [Section new ${Path}.logo]
    set about_text  [Section new ${Path}.text]
    set logo        [$::theme create_banner [$about_logo id]]
    set information [::ttk::label "[$about_text id].msg" -text {
      ODIN - Open Deployment Information Network
  
      Description:
  
      Distributed system for software deployment automation and developer aiding
      facilities (log visualization, custom runtime metrics, etc). It's based off   
      another project of mine called "deploy-utils", originally written in pure
      shell script as a proof of concept.
      
      Author:
  
      Gabriel Aires Guedes - airesgabriel@gmail.com
    }]

    pack [$about_logo id] -side top -fill x
    pack [$about_text id] -fill both -expand 1
    pack $logo
    pack $information
    
    $Window title "About"
    $Window assign_member [list $about_logo $about_text]
    $Window configure [list -padx 4p -pady 4p]
    $Window center
  }

  #menubar
  set menubar   [menubar new]
  
  namespace eval menubar {
    proc quit {_} {
      destroy [$::app id]
    }
    
    proc theme {_ _ name} {
      $::theme theme_choose $name
    }
    
    proc about {_} {
      $::popup display [$::main id].help_popup
    }
    
    proc agent {_} {
      $::popup display [$::main id].conf_popup
    }
  }
  
  $menubar define {
    File M:file {
      Quit        C       quit
    }
    View M:view {
      Theme       S       separator1
      Default     R       theme_selector
      Light       R       theme_selector
      Dark        R       theme_selector
    }
    Settings M:settings {
      Agent       C       agent
    }    
    Help M:help {
      About       C       about
    }
  }
  
  $menubar install [$::app id] {
    $menubar menu.configure -command {
      quit                ::menubar::quit
      theme_selector      ::menubar::theme
      agent               ::menubar::agent
      about               ::menubar::about
    } -bind {
      quit                {0 Ctrl+Q Control-Key-q}
    }
  }  
  
  #banners
  set banner      [$::theme create_banner [$::left id]]
  
  #editor
  set editor [Editor new "[$::right id].editor" {Step Editor} ]
  set editor_tools [Toolbar new [$::right id].tools {}]

  $editor_tools assign $editor
  $editor_tools add_selector theme "Theme: " colorscheme_choose {Standard Solarized Monokai}
  $editor_tools display_toolbar
  
  pack [$::main id] -fill both -expand 1
  pack [$::left id] -side left -fill y
  pack [$::right id] -fill both -expand 1 -padx 4p -pady 4p
  pack [$editor_tools id] -side top -fill x
  pack [$editor id] -fill both -expand 1
  pack $banner
      
  #display	
  $::app title "Odin Administrator Interface"
  $::app assign_resource $menubar
  $::app center
}

#login form
oo::class create Login {
  superclass Form
  mixin DbAccess Event
  
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
      after 1000 "[self] destroy; ::main"
    }
                  
    my debug_input
  }
  
  destructor {
    destroy [my id]
  }
}

#setup themes
set theme     [Theme new "$conf::asset_path/logo_black.png" "$conf::asset_path/logo_white.png"]
if {$tcl_platform(platform) eq "unix"} {
  $theme theme_choose "Light"
} else {
  $theme theme_choose "Default"
}

#open main database
set db_schema [open [file join $conf::schema_path db.sql]]
set db_sql    [read $db_schema]
close $db_schema
set db [Database new $conf::db_path]
catch {$db query $db_sql}

#setup widgets
set app     [Window new .]
set popup   [PopUp new]  
set signin  [Login new .login {} $login_fields $rules ]
set main    [Section new ".main"]
set left    [Section new "[$main id].left"]
set right   [Section new "[$main id].right"]

$app title "Odin login"
$app assign_member [list $signin $main $left $right]
$app assign_resource $db
$signin use_db $db
$signin bind_method [$signin input_id "password"] <Key-Return> "submit"

pack [$signin id]
$app center