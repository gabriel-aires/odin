#standard worker procedures
namespace eval service {

	proc shutdown {} {
		thread::release
	}

	proc add_worker {name id} {
		variable self
		variable workers

		if [ne $self $id] {
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
}

