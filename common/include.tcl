#import procedures
namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::abs
namespace import ::tcl::mathfunc::ceil
namespace import ::tcl::mathfunc::floor
namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min
namespace import ::tcl::mathfunc::rand
namespace import ::tcl::mathfunc::round
namespace import ::tcl::mathfunc::srand

#import settings
set json_file [open $vfs_root/tcl.json r]
set settings  [::json::json2dict [read $json_file]]
close $json_file

#import namespaces / classes
source [file join $vfs_root common utils.tcl]
source [file join $vfs_root common database.tcl]
source [file join $vfs_root common dbaccess.tcl]
source [file join $vfs_root common contract.tcl]

#configuration namespace
namespace eval conf {

  proc setup_path {} {
    variable src_pkgs
    variable dll_pkgs
    variable mod_path
    set pkgs {}
    lappend pkgs {*}$src_pkgs {*}$dll_pkgs
    foreach pkg_name $pkgs {
      lappend ::auto_path [file join $mod_path $pkg_name]
    }
  }

  dict with ::settings {}
  set asset_path  [file join $::vfs_root $asset_folder]
  set schema_path [file join $::vfs_root $db_folder]
  set mod_path    [file join $::vfs_root $mod_folder]
}

