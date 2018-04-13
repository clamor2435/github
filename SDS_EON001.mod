/* EON_SDS.mod */

/* Parameters */
param D integer, >0;          /*Domain*/
param R integer, >0;          /*Request*/
param F integer, >0;          /*Quantities of Index*/
param N integer, >0;         /*Maximum nodes whitch domain has*/

/*Setting & Variables*/

set DN := 1..D;               /*Domain numbers*/
set RN := 1..R;               /*Request numbers*/
set NN := 1..N;               /*Node numbers*/
set FN := 1..F;               /*Index numbers*/

set L within {DN,DN,NN,NN};   /*Link*/

param v{DN,NN} integer;       /*Global Node what Domain i has*/

/*3-tuple Request*/
param s{RN} integer;          /*Request Source node*/
param d{RN} integer;          /*Request Destination node*/
param r{RN} integer;          /*Request need number of Index*/

var xp{RN,L,FN},binary;       /*First Index in Primary Route*/
var xb{RN,L,FN},binary;       /*First Index in Backup Route*/
var yp{RN,L,FN},binary;       /*Using Index in Primary Route*/
var yb{RN,L,FN},binary;       /*Using Index in Backup Route*/
var p{RN,L},binary;           /*Through Link or not as Primary Route*/
var b{RN,L},binary;           /*Through Link or not as Backup Route*/


/* Objective Function */
minimize Index: sum{n in RN}(sum{f in FN}(sum{i in DN,j in DN,k in NN,m in NN:(i,j,k,m) in L}(
                yp[n,i,j,k,m,f] + yb[n,i,j,k,m,f])));

/* Constraint function */
s.t. FIRST_INDEX_P1{n in RN,i in DN,j in DN,k in NN,m in NN:p[n,i,j,k,m] = 1}:
	sum{f in FN}(p[n,i,j,k,m]*xp[n,i,j,k,m,f])=1;

s.t. FIRST_INDEX_P2{n in RN,i in DN,j in DN,k in NN,m in NN:p[n,i,j,k,m] = 0}:
	sum{f in FN}(p[n,i,j,k,m]*xp[n,i,j,k,m,f])=0;



s.t. FIRST_INDEX_B1{n in RN,i in DN,j in DN,k in NN,m in NN:b[n,i,j,k,m]=1}:
	sum{f in FN}(b[n,i,j,k,m]*xb[n,i,j,k,m,f])=1;

s.t. FIRST_INDEX_B2{n in RN,i in DN,j in DN,k in NN,m in NN:b[n,i,j,k,m]=0}:
	sum{f in FN}(b[n,i,j,k,m]*xb[n,i,j,k,m,f])=0;
end;
