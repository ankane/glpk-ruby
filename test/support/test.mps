* Problem:
* Class:      MIP
* Rows:       3
* Columns:    2 (2 integer, 0 binary)
* Non-zeros:  6
* Format:     Free MPS
*
NAME
ROWS
 N R0000000
 E R0000001
 E R0000002
 E R0000003
COLUMNS
 M0000001 'MARKER' 'INTORG'
 C0000001 R0000000 8 R0000003 2
 C0000001 R0000002 3 R0000001 2
 C0000002 R0000000 10 R0000003 1
 C0000002 R0000002 4 R0000001 2
 M0000002 'MARKER' 'INTEND'
RHS
 RHS1 R0000001 7 R0000002 12
 RHS1 R0000003 6
RANGES
 RNG1 R0000001 1E30 R0000002 1E30
 RNG1 R0000003 1E30
BOUNDS
 UP BND1 C0000001 1E30
 UP BND1 C0000002 1E30
ENDATA
