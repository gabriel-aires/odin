oo::class create Table {
  superclass Container
  mixin DbAccess Event
  variable Db Table Records Headers Item Data

  constructor {args} {
		set path    [lindex $args 0]
		set label   [lindex $args 1]
		set Headers	[lindex $args 2]
		set Item    {}
		set Data    {}
		next $path $label
		my setup_scrollbar
		my setup_table
		my bind_method $Table <<TreeviewSelect>> "read_data %x %y"
	}

	method setup_scrollbar {} {
		set scroll [ttk::scrollbar [my id].scroll -command "[my id].table yview"]
		pack $scroll -side right -fill y
	}
	
	method setup_table {} {
		set Table [::ttk::treeview [my id].table \
		  -yscrollcommand "[my id].scroll set" \
		  -s {*}$Headers \
		  -displays #all \
    ]
		foreach heading $Headers {
		  $Table heading $heading -text $heading -anchor center
		}
		pack $Table -fill both -expand 1
	}
	
	method insert_group {parent name} {
	  $Table insert $parent end -id $name -text $name
	}
	
	method insert_record {parent name values} {
	  $Table insert $parent end -text $name -values $values
	}
	
	method insert_batch {parent sql} {
	  set recordset [$Db query {$sql}]
	  foreach record $recordset {
	    my append_record $parent [lindex $record 0] [lrange $record 1 end]
	  }
	}
	
	method read_data {x y} {
	  set Item [$Table identify item $x $y]
	  set Data [$Table set $item]
	}
	
	method this_column {column} {
	  return [dict get $Data $column]
	}
	
  method this_id {} {
	  return [my this_value #0]
  }
	
	method this_parent {} {
	  return [$Table parent $Item]
	}
}
