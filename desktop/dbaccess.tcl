oo::class create DbAccess {
  variable Db
  
  method use_db {handle} {
    set Db $handle
  }
}
