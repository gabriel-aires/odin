oo::class create Database {
  variable Db File
  
  constructor {path} {
    set Db db
    set File $path
    sqlite3 $Db $File
  }
  
  method query {sql} {
    set query [list $Db eval $sql]
    uplevel 1 $query
  }
  
  destructor {
    $Db close
    puts "database $File closed, ref: [self]"
  }
}
