#import packages
package require Tk
package require starkit
package require sha256
package require sqlite3
package require json

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

#initialize starpack
starkit::startup
set vfs_root  [file dirname [file normalize [info script]]]
set json_file [open $vfs_root/tcl.json r]
set settings  [::json::json2dict [read $json_file]]
close $json_file

#import classes
source [file join $vfs_root event.tcl]
source [file join $vfs_root contract.tcl]
source [file join $vfs_root theme.tcl]
source [file join $vfs_root window.tcl]
source [file join $vfs_root popup.tcl]
source [file join $vfs_root database.tcl]
source [file join $vfs_root dbaccess.tcl]
source [file join $vfs_root container.tcl]
source [file join $vfs_root sidebar.tcl]
source [file join $vfs_root component.tcl]
source [file join $vfs_root editor.tcl]
source [file join $vfs_root repository.tcl]
source [file join $vfs_root toolbar.tcl]
source [file join $vfs_root validation.tcl]
source [file join $vfs_root form.tcl]

#main
proc main {} {
      
  #configuration
  namespace eval conf {
    
    #load settings
    dict with ::settings {}
    dict with ::settings targets desktop {}
    set asset_path  [file join $::vfs_root $asset_folder]
    set schema_path [file join $::vfs_root $db_folder]
    set mod_path    [file join $::vfs_root $mod_folder]
    set db_path     [file join [pwd] "odin.db"]
    set tk_user     {}
    set tk_hash     {}
  
    set auth_fields {
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
  
    #load info
    set about_file [open [file join $asset_path "about.txt"] r]
    variable about_msg  [read $about_file]
    close $about_file
    
    #load additional dependencies
    lappend ::auto_path [file join $mod_path awthemes2.2] [file join $mod_path ctext3.3] [file join $mod_path menubar0.5]
    package require ttk::theme::awdark
    package require ttk::theme::awlight
    package require ctext
    package require menubar  
    
    #load database
    set db_schema [open [file join $schema_path db.sql]]
    set db_sql    [read $db_schema]
    close $db_schema
    set db [Database new $db_path]
    catch {$db query $db_sql}
    set rules [$db query {SELECT * FROM rule}]
    
    #load themes
    set theme [Theme new [file join $asset_path logo_black.png] [file join $asset_path logo_white.png]]
    if {$tcl_platform(platform) eq "unix"} {
      $theme theme_choose "Light"
    } else {
      $theme theme_choose "Default"
    }  
  }
  
  #layout
  namespace eval layout {
    set left 			.sidebar
    set right 		.tabview
    set bottom		.status
  }
  
  #popups
  namespace eval popups {
    
    variable popup [::PopUp new]
  
    $popup define .auth_popup {
      set form [Form new ${Path}.form Authentication $::conf::auth_fields $::conf::rules]
      
      oo::objdefine $form {
        mixin DbAccess
        variable User Hash
  
        method auth_error? {} {
          my variable Db
          
          set User   [my repo_val login]
          set Hash   [sha2::sha256 [my repo_val password]]
          set search [$Db query {
               SELECT u.name
               FROM user u
               INNER JOIN user_type t	on u.type_id = t.rowid
               WHERE u.active = 1 AND t.name = 'admin' AND u.name = :User AND u.pass = :Hash
          }]
          
          return [ne $User $search]
        }
        
        method submit {} {       
          if {[my input_error?]} {
            my update_help "ERROR"
          } elseif {[my auth_error?]} {
            my update_help "ERROR" "Invalid User/Password"
          } else {
            my update_help "SUCCESS" "Authentication Successful"
            after 1000 "set ::conf::tk_user $User ; set ::conf::tk_hash $Hash ; [self] finish"
          }
          
          my debug_input
        }
  
        method finish {} {
          if {$::conf::tk_user eq {}} {
            $::app::app destroy
          } else {
            [self] destroy
          }
        }
      }
      
      $form configure [list -labelanchor n -padding 9p]
      $form use_db $::conf::db
      $form bind_method [$form input_id "password"] <Key-Return> "submit"
      $form bind_method [$form id] <Destroy> "finish"    
      $form hire $Window
      $Window title "Login"
      $Window focus
      pack [$form id]
    }
    
    $popup define .conf_popup {
      set form [Form new ${Path}.agentconfig "Agent Settings" $::conf::config_fields $::conf::rules]
  
      oo::objdefine $form {        
        method submit {} {
          if [my input_error?] {
            my update_help "ERROR"
          }
          my debug_input
        }
      }
  
      $Window title "Configuration..."
      $Window hire $form
      $Window focus
      pack [$form id]
    }
    
    $popup define .help_popup {
      set about_logo  [Container new ${Path}.logo]
      set about_text  [Container new ${Path}.text]
      set logo        [$::conf::theme create_banner [$about_logo id]]
      set information [text "[$about_text id].msg"]
      $information insert 1.0 $conf::about_msg
      $information configure -state disabled -wrap word -height 10p -width 60
      $Window title "About"
      $Window hire [list $about_logo $about_text]
      $Window center
      pack [$about_logo id] -side top -fill x
      pack [$about_text id] -fill both -expand 1
      pack $logo
      pack $information
    }
  }
  
  #menubar
  namespace eval menubar {
    variable menubar [::menubar new]
    
    proc quit {_} {
      $::app::app destroy
      exit 0
    }
    
    proc theme {_ _ name} {
      $::conf::theme theme_choose $name
    }
    
    proc about {_} {
      $::popups::popup display .help_popup
    }
    
    proc agent {_} {
      $::popups::popup display .conf_popup
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
    
    $menubar install . {
      $menubar menu.configure -command {
        quit                ::menubar::quit
        theme_selector      ::menubar::theme
        agent               ::menubar::agent
        about               ::menubar::about
      } -bind {
        quit                {0 Ctrl+Q Control-Key-q}
      }
    }
  }
  
  #status
  namespace eval statusbar {
    set statusbar 	[Container new $layout::bottom]
    [$statusbar id] configure -relief groove -borderwidth 2p
    pack [$statusbar id] -side bottom -fill x
    set user_label  [::ttk::label [$statusbar id].user_label -text "User: " -justify left]
    set user_info   [::ttk::label [$statusbar id].user_info -textvariable ::conf::tk_user -justify left]
    set rev_info    [::ttk::label [$statusbar id].rev_info -text "ODIN v1.0" -justify right]
    pack $user_label -side left
    pack $user_info -side left
    pack $rev_info -side right
  }
  
  #sidebar
  namespace eval sidebar {
    variable sidebar	[Sidebar new $layout::left]
    
    pack [$::conf::theme create_banner $layout::left]
    
    $sidebar install {
      "Step Editor"   "$::components::component display editor"
    }
  }
  
  #components
  namespace eval components {
    variable component [::Component new $::layout::right]
    
    $component define editor "Step Definition" {
      set editor_input [Editor new ${Path}.input {}]
      set editor_tools [Toolbar new ${Path}.tools {}]
      $editor_tools assign $editor_input
      $editor_tools add_selector theme "Theme: " colorscheme_choose {Standard+ Solarized Monokai}
      $editor_tools display_toolbar
      pack [$editor_tools id] -side top -fill x
      pack [$editor_input id] -fill both -expand 1
      $Frame hire [list $editor_input $editor_tools]
    }
  }
  
  #app setup
  namespace eval app {
    variable app [Window new .]
    
    $app title "Odin Administrator Interface"
    $app maximize
    $app hire [list \
      $::popups::popup \
      $::menubar::menubar \
      $::components::component \
      $::sidebar::sidebar \
      $::statusbar::statusbar \
      $::conf::db \
      $::conf::theme]
    
    $::popups::popup display .auth_popup
  }
}

main
