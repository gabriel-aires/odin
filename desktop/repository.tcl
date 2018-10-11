oo::class create Repository {
	variable Repository

	method setup_repository {} {
		array set Repository {}
	}
	
	method repo_key {key} {
		return [my varname Repository($key)]
	}
	
	method repo_val {key} {
		if [catch {set value $Repository($key)}] {
			return {}
		} else {
			return $value
		}
	}
	
	method repo_dump {} {
		return [array get Repository]
	}
	
	method repo_print {} {
		parray Repository
	}
}
