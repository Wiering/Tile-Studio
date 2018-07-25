{ Tile Studio include file }

{$I jedi.inc}


  // {$DEFINE IMPORTEDLEV}      // import levels from old DOS version: GRED
  // {$DEFINE PATCHBMP}         // some systems won't write a correct BMP header
                                //   when using pf24bit, this corrects the header
  {$DEFINE SAVETOTALTIME}       // keep track of the total amount of time spent
                                //   on a project
  // {$DEFINE SHOWTOTALTIME}    // show the total time

  {$DEFINE CREATE_BACKUP_FILES} // keep backup (.$$$) instead of overwriting


  {$R+}   // range checking on
  
