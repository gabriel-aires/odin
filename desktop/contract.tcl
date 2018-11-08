oo::class create Contract {
  mixin Utils
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
    set Workers [my Lremove $objects $Workers]
  }

  method terminate {} {
    my dismiss $Workers
  }
}
