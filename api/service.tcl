namespace eval service {

	variable workers	{}
	variable master
	variable name
	variable self			[thread::id]

	proc add_worker {name id} {
		variable self
		variable workers
		if {$self ne $id && $id ni $workers} {
			lappend workers $name $id
		}
	}

	proc get_worker {query} {
		variable workers
		foreach {name id} $workers {
			if [eq $query $name] {
				return $id
			}
		}
		error "unknown worker: $query"
	}

  proc remove_worker {name} {
    variable workers
    if [catch {get_worker $name} id] {
      return
    }
		set workers [::utils::lremove [list $name $id]]
  }

  proc callout {procname {args ""}} {
    thread::broadcast [list $procname {*}$args]
  }

	proc call {worker procname {args ""}} {
		variable workers
		set target [get_worker $worker]
		thread::send $target [list $procname {*}$args]
	}

	proc callback {varname worker procname {args ""}} {
		variable workers
		upvar $varname result
		set target [get_worker $worker]
		thread::send -async $target [list $procname {*}$args] result
	}

  proc startup {name} {
		set id [thread::create [format {
			package require json
			set argv0			%s
			set vfs_root 	%s
			source [file join $vfs_root common include.tcl]
			source [file join $vfs_root service.tcl]
			namespace eval conf {
				dict with ::settings targets server {}
				setup_path
			}
			namespace eval service {
				set master 	%s
				set name		%s
			}
			source [file join $vfs_root $::service::name.tcl]
			thread::wait
		} $::argv0 $::starkit::topdir [thread::id] $name]]
		add_worker $name $id
		callout ::service::add_worker $name $id
  }

	proc shutdown {} {
		variable $name
		callout remove_worker $name
		thread::release
	}
}
