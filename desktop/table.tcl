oo::class create Table {
  superclass Container
  mixin DbAccess Event
  variable Db Table Records Headers Item

  constructor {args} {
		set path    [lindex $args 0]
		set label   [lindex $args 1]
		set Headers	[lindex $args 2]
		set Item    {}
		next $path $label
		my setup_scrollbar
		my setup_table
		my bind_method $Table <Button-1> "read_item %x %y"
  }

	method setup_scrollbar {} {
		set scroll [ttk::scrollbar [my id].scroll -command "[my id].table yview"]
		pack $scroll -side right -fill y
	}
	
	method setup_table {} {
		set Table [::ttk::treeview [my id].table \
		  -yscrollcommand "[my id].scroll set" \
		  -columns $Headers \
		  -displaycolumns $Headers \
    ]
		foreach heading $Headers {
		  $Table heading $heading -text $heading -anchor center
		}
		pack $Table -fill both -expand 1
	}
	
	method clear_table {} {
	  $Table delete [$Table children {}]
	}
	
	method insert_group {parent name} {
	  $Table insert $parent end -id $name -text $name
	}
	
	method insert_record {parent name values} {
	  $Table insert $parent end -text $name -values $values
	}
	
	method insert_batch {parent sql} {
	  set result  [$Db query $sql]
	  set columns [llength $Headers]
	  set index   0

	  foreach item $result {
	    if {$index < $columns} {
	      if {$index == 0} {
	        set name $item
	        set values  {}
	      } else {
	        lappend values $item
	      }
	      incr index
	    } else {
	      lappend values $item
	      my insert_record $parent $name $values
	      set index 0
	    }
	  }
	}
	
	method read_item {x y} {
	  set Item [$Table identify item $x $y]
	}
	
	method this_data {} {
	  return [$Table item $Item -values]
	}
	
  method this_id {} {
	  return [$Table item $Item -text]
  }
	
	method this_parent {} {
	  return [$Table parent $Item]
	}
}
