oo::class create Database {
  variable Db File
  
  constructor {path} {
    set Db db
    set File $path
    sqlite3 $Db $File
  }
  
  method query {sql} {
    uplevel 1 [list $Db eval $sql]
  }
  
  method write {sql} {
    set error 0
    set begin [list $Db eval "BEGIN TRANSACTION;"]
    set stmt  [list $Db eval $sql]
    set end   [list $Db eval "COMMIT;"]
    set reset [list $Db eval "ROLLBACK TRANSACTION;"]
    try {
      uplevel 1 $begin
      uplevel 1 $stmt
    } on ok {} {
      uplevel 1 $end
    } on error {result} {
      set error 1
      uplevel 1 $reset
      puts "Database write failed:\n $sql\nCause: $result\n"
    } finally {
      return $error
    }
  }
  
  destructor {
    $Db close
    puts "database $File closed, ref: [self]"
  }
}
