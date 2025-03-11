.ifndef _OPTION_UTIL_INC
_OPTION_UTIL_INC = 1
.macro __bool_option name, default
.local DefaultVal
  .ifnblank default
  DefaultVal .set default
  .else
  DefaultVal .set 0
  .endif
  .if .not .defined(.ident(.string(name)))
    .ident(.string(name)) .set DefaultVal
  .elseif .not ((.ident(.string(name))=1) .or (.ident(.string(name))=0))
    ; if you get this error then you've set a boolean config option to something other than 0 or 1
    .error .sprintf("Boolean Option `%s` was set to a value other than 0 or 1", .string(name))
    .fatal "Invalid Options selected"
  .endif
  .ifdef PRINT_OPTIONS_FOR_C
    .if PRINT_OPTIONS_FOR_C
      .out .sprintf("#ifndef %s", .string(name))
      .out .sprintf("  #define %s %d", .string(name), DefaultVal)
      .out "#endif"
    .endif
  .endif
.endmacro

.macro __num_option name, default
; work around to check if something is numeric
.local Num, DefaultVal
Num = 123
  .ifnblank default
  DefaultVal .set default
  .else
  DefaultVal .set 0
  .endif
  .if .not .defined(.ident(.string(name)))
    .ident(.string(name)) .set DefaultVal
    ; Check if its numeric
    ; match only checks that the types are the same between the two tokens.
  .elseif .not ( .match ( {.ident(.string(name))}, Num ) )
    ; if you get this error then you've set a numeric config option to something other than a number
    .error .sprintf("Number Option `%s` was set to a non numeric value %d", .string(name), .ident(.string(name)))
    .fatal "Invalid Options selected"
  .endif
  .ifdef PRINT_OPTIONS_FOR_C
    .if PRINT_OPTIONS_FOR_C
      .out .sprintf("#ifndef %s", .string(name))
      .out .sprintf("  #define %s %d", .string(name), DefaultVal)
      .out "#endif"
    .endif
  .endif
.endmacro

.endif
