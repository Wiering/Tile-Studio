{ Tile Studio include file }

  // {$DEFINE IMPORTEDLEV}      // import levels from old DOS version: GRED
  // {$DEFINE PATCHBMP}         // some systems won't write a correct BMP header
                                //   when using pf24bit, this corrects the header
  {$DEFINE SAVETOTALTIME}       // keep track of the total amount of time spent
                                //   on a project
  // {$DEFINE SHOWTOTALTIME}    // show the total time

  {$DEFINE PNGSUPPORT}

  {$DEFINE CREATE_BACKUP_FILES} // keep backup (.$$$) instead of overwriting

  {$DEFINE SCRIPTING}           // uses the IFPS3 library by Carlo Kok


  {$R+}   // range checking on
