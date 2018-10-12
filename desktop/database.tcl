oo::class create Database {
  variable Db
  
  constructor {path} {
    set Db db
    sqlite3 $Db $path
  }
  
  method query {sql} {
    set query [list $Db eval $sql]
    uplevel 1 $query
  }
  
  destructor {
    $Db close
  }
}
