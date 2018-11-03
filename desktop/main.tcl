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
  
    set new_script_fields {
      name          text:required
      description   text:optional
      dependencies  text:optional
      arguments     text:optional
    }
  
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
    foreach pkg_name $src_pkgs {
      lappend ::auto_path [file join $mod_path $pkg_name]
    }
    package require ttk::theme::awdark
    package require ttk::theme::awlight
    package require ctext
    package require menubar
    
    #load database
    set db_exists [file exists $db_path]
    set db [Database new $db_path]
    if [! $db_exists] {
      set db_schema [open [file join $schema_path db.sql]]
      set db_sql    [read $db_schema]
      close $db_schema      
      $db write $db_sql      
    }
    set rules [$db query {SELECT * FROM rule}]
    
    #load themes
    set theme [Theme new [file join $asset_path logo_black.png] [file join $asset_path logo_white.png]]
    if {$tcl_platform(platform) eq "unix"} {
      $theme theme_choose "Light"
    } else {
      $theme theme_choose "Default"
    }  
  }
  
  #runtime variables
  namespace eval state {
    set user    {}
    set hash    {}
    set state   {}
    set changes 0
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
      set form [Form new ${Path}.form {} $::conf::auth_fields $::conf::rules]
      
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
            after 1000 "set ::state::user $User ; set ::state::hash $Hash ; [self] finish"
          }
          
          my debug_input
        }
  
        method finish {} {
          if {$::state::user eq {}} {
            $::app::app destroy
          } else {
            [self] destroy
          }
        }
      }

      pack [$form id]
      $form configure [list -padding 9p]
      $form use_db $::conf::db
      $form bind_method [$form input_id "password"] <Key-Return> "submit"
      $form bind_method [$form id] <Destroy> "finish"    
      $form hire $Window
      $Window title "Authentication"
      $Window focus
    }
    
    $popup define .new_script_popup {
      set form [Form new ${Path}.form {} $::conf::new_script_fields $::conf::rules]
  
      oo::objdefine $form {
        mixin DbAccess
        variable Name Desc Args

        method init_vars {} {
          set Name  [my repo_val name]
          set Desc  [my repo_val description]
          set Args  [my repo_val arguments]
        }
        
        method name_error? {} {
          my variable Db
          set saved_names [$Db query {SELECT name FROM script}]
          return [in $Name $saved_names]
        }
        
        method save_error? {} {
          my variable Db
          set retval [catch {$Db write "INSERT INTO `script` VALUES (:Name,:Desc,1,'',:Args,'');"}]
          return $retval
        }
        
        method submit {} {
          my variable Db
          my init_vars
          
          if [my input_error?] {
            my update_help "ERROR"     
          } elseif [my name_error?] {
            my update_help "ERROR" "A script named $Name already exists"
          } elseif [my save_error?] {
            my update_help "ERROR" "Unable to write into database"
          } else {
            my update_help "SUCCESS" "Script $Name created"
            set ::state::editor.script $Name
            set editor_obj [set ::state::editor.object]
            set template_args [::components::editor::search_script $Name]
            $editor_obj insert_template {*}$template_args
            after 1000 "[self] destroy"
          }
          
          my debug_input
        }
      }

      pack [$form id]
      $form use_db $::conf::db
      $form hire $Window
      $Window title "New Script..."
      $Window focus
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
      pack [$form id]  
      $Window title "Configuration..."
      $Window hire $form
      $Window focus
    }
    
    $popup define .help_popup {
      set about_logo  [Container new ${Path}.logo]
      set about_text  [Container new ${Path}.text]
      set logo        [$::conf::theme create_banner [$about_logo id]]
      set information [text "[$about_text id].msg"]
      pack [$about_logo id] -side top -fill x
      pack [$about_text id] -fill both -expand 1
      pack $logo
      pack $information
      $information insert 1.0 $conf::about_msg
      $information configure -state disabled -wrap word -height 10p -width 60
      $Window title "About"
      $Window hire [list $about_logo $about_text]
      $Window center
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
    [$statusbar id] configure -relief groove
    pack [$statusbar id] -side bottom -fill x
    set user_frame  [Container new [$statusbar id].user]
    set user_label  [::ttk::label [$user_frame id].label -text "User: " -justify left]
    set user_info   [::ttk::label [$user_frame id].info -textvariable ::state::user -justify left]
    set sync_frame  [Container new [$statusbar id].sync]
    set sync_label  [::ttk::label [$sync_frame id].label -text "Changes: " -justify right]
    set sync_info   [::ttk::label [$sync_frame id].info -textvariable ::state::changes -justify left]
    set rev_frame   [Container new [$statusbar id].rev]
    set rev_info    [::ttk::label [$rev_frame id].info -text "ODIN v1.0" -justify right]
    $statusbar hire [list $user_frame $sync_frame $rev_frame]
    grid [$user_frame id] x [$sync_frame id] x [$rev_frame id] -sticky ew
    grid columnconfigure [$statusbar id] {1 3} -weight 1 -uniform a
    grid $user_label $user_info -sticky e
    grid $sync_label $sync_info -sticky ew
    grid $rev_info -sticky w
  }
  
  #sidebar
  namespace eval sidebar {
    variable sidebar	[Sidebar new $layout::left]
    
    pack [$::conf::theme create_banner $layout::left]
    
    $sidebar install {
      "Script Editor"   "$::components::component display editor"
    }
  }
  
  #components
  namespace eval components {
    variable component [::Component new $::layout::right]
    
    $component define editor "Script Editor" {
      variable ns [namespace current]
      variable input [Editor new ${Path}.input {}]
      variable tools [Toolbar new ${Path}.tools {}]
      set ::state::editor.object $input
      set ::state::editor.state  disabled
      set ::state::editor.script {}

      proc search_script {name} {
        $::conf::db query "SELECT * FROM script WHERE name = :name ORDER BY revision DESC LIMIT 1;"
      } 
      
      proc new_script {} {
        $::popups::popup display .new_script_popup
      }
      
      $input config_text [list -state [set ::state::editor.state]]
      $tools assign $input
      $tools add_button new "New" ${ns}::new_script
      $tools add_spacer
      $tools add_selector theme "Theme: " colorscheme_choose {Standard+ Solarized Monokai}
      $tools display_toolbar
      pack [$tools id] -side top -fill x
      pack [$input id] -fill both -expand 1
      $Frame hire [list $input $tools]
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
    
    after 100 "$::popups::popup display .auth_popup"    
  }
}

main