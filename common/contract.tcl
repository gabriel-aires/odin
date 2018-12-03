oo::class create Contract {
  variable Workers

  method setup_contract {} {
    set Workers {}
  }

  method hire {objects} {
	  lappend Workers {*}$objects
  }

  method dismiss {objects} {
    foreach object $objects {
      catch {$object destroy}
    }
    set Workers [::utils::lremove $objects $Workers]
  }

  method terminate {} {
    my dismiss $Workers
  }
}
