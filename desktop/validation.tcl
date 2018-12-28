oo::class create Validation {
	variable Rule

	method setup_validation {ruleset} {
		array set Rules {}

		foreach {rule pattern} $ruleset {
			my set_rule $rule $pattern
		}
	}

	method check_rule {name} {
		set list [array names Rule]
		return [in $name $list]
	}

	method notfound_rule {name} {
		error "Error: rule $name not found"
	}

	method get_rule {name} {
		if [my check_rule $name] {
			return $Rule($name)
		} else {
			my notfound_rule $name
		}
	}

	method set_rule {name pattern} {
		set Rule($name) "$pattern"
	}

	method set_rule_strict {name pattern} {
		my set_rule $name [join {^ $} $pattern]
	}

	method match_rule {rule_name value} {
		if [my check_rule $rule_name] {
			return [regexp $Rule($rule_name) "$value"]
		} else {
			my notfound_rule $rule_name
		}
	}
}

