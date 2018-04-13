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
set FN := 0..(F-1);               /*Index numbers*/

set L within {DN,DN,NN,NN};   /*Link*/

param v{DN,NN} integer;       /*Global Node what Domain i has*/
param c{L} integer;           /*INDEX NOT USE*/
/*3-tuple Request*/
param s{RN} integer;          /*Request Source node*/
param d{RN} integer;          /*Request Destination node*/
param r{RN} integer;          /*Request need number of Index*/

var xp{RN,L,FN},binary;       /*First Index in Primary Route*/
var xb{RN,L,FN},binary;       /*First Index in Backup Route*/
var yp{RN,L,FN},binary;       /*Using Index in Primary Route*/
var yb{RN,L,FN},binary;       /*Using Index in Backup Route*/





/* Objective Function */
minimize Index: sum{n in RN}(sum{f in FN}(sum{i in DN,j in DN,k in NN,m in NN:(i,j,k,m) in L}(
  yp[n,i,j,k,m,f] + yb[n,i,j,k,m,f])));

/* Constraint function */

s.t. FIRST_INDEX_PRIMARY1{n in RN,i in DN,j in DN,k in NN, m in NN:(i,j,k,m) in L}:
	sum{f in FN}(xp[n,i,j,k,m,f]) <= 1;  
 
s.t. FIRST_INDEX_BACKUP1{n in RN,i in DN,j in DN,k in NN, m in NN:(i,j,k,m) in L}:
  sum{f in FN}(xb[n,i,j,k,m,f]) <= 1;

s.t. FIRST_INDEX_PRIMARY2{n in RN,i in DN, j in DN, k in NN, m in NN,f in {0..(F - r[n])},fp in {f..(f+r[n]-1)}:(i,j,k,m) in L}:
	xp[n,i,j,k,m,f] <= yp[n,i,j,k,m,f];


s.t. FIRST_INDEX_BACKUP2{n in RN,i in DN, j in DN, k in NN, m in NN,f in {0..(F - r[n])},fp in {f..(f+r[n]-1)}:(i,j,k,m) in L}:
	xb[n,i,j,k,m,f] <= yb[n,i,j,k,m,f];

s.t. FIRST_INDEX_PRIMARY3{n in RN,i in DN,j in DN,k in NN,m in NN,f in {(F - r[n]+1)..(F-1)}:(i,j,k,m) in L}:
	xp[n,i,j,k,m,f]=0;

s.t. FIRST_INDEX_BACKUP3{n in RN,i in DN,j in DN,k in NN,m in NN,f in {(F - r[n]+1)..(F-1)}:(i,j,k,m) in L}:
	xb[n,i,j,k,m,f]=0;

s.t. INDEX_CONSTRAINT{i in DN,j in DN,k in NN,m in NN,f in FN:(i,j,k,m) in L}:
	sum{n in RN}(yp[n,i,j,k,m,f] + yb[n,i,j,k,m,f]) <= 1;

/* ここから上はインデックスの制約条件 */
/* ここから下はフロー制約条件 */

s.t. FLOW_CONSERVE_PRIMARY1{i in DN,k in NN,n in RN:v[i,k] = s[n]}:
	sum{f in FN}(sum{j in DN,m in NN:(i,j,k,m) in L}yp[n,i,j,k,m,f]) - sum{f in FN}(sum{j in DN,m in NN:(j,i,m,k) in L}yp[n,j,i,m,k,f])=r[n];

s.t. FLOW_CONSERVE_PRIMARY2{i in DN,k in NN,n in RN:v[i,k] = d[n]}:
	sum{f in FN}(sum{j in DN,m in NN:(i,j,k,m) in L}yp[n,i,j,k,m,f]) - sum{f in FN}(sum{j in DN,m in NN:(j,i,m,k) in L}yp[n,j,i,m,k,f])=-r[n];

s.t. FLOW_CONSERVE_PRIMARY3{i in DN,k in NN,n in RN:v[i,k] != s[n] && v[i,k] != d[n]}:
	sum{f in FN}(sum{j in DN,m in NN:(i,j,k,m) in L}yp[n,i,j,k,m,f]) - sum{f in FN}(sum{j in DN,m in NN:(j,i,m,k) in L}yp[n,j,i,m,k,f])=0;


s.t. FLOW_CONSERVE_BACKUP1{i in DN,k in NN,n in RN:v[i,k] = s[n]}:
	sum{f in FN}(sum{j in DN,m in NN:(i,j,k,m) in L}yb[n,i,j,k,m,f]) -
	sum{f in FN}(sum{j in DN,m in NN:(j,i,m,k) in L}yb[n,j,i,m,k,f])=r[n];

s.t. FLOW_CONSERVE_BACKUP2{i in DN,k in NN,n in RN:v[i,k] = d[n]}:
	sum{f in FN}(sum{j in DN,m in NN:(i,j,k,m) in L}yb[n,i,j,k,m,f]) -
	sum{f in FN}(sum{j in DN,m in NN:(j,i,m,k) in L}yb[n,j,i,m,k,f])=-r[n];

s.t. FLOW_CONSERVE_BACKUP3{i in DN,k in NN,n in RN:v[i,k] != s[n] && v[i,k] != d[n]}:
	sum{f in FN}(sum{j in DN,m in NN:(i,j,k,m) in L}yb[n,i,j,k,m,f]) -
	sum{f in FN}(sum{j in DN,m in NN:(j,i,m,k) in L}yb[n,j,i,m,k,f])=0;

s.t. LIMIT_SUM_INDEX{i in DN,j in DN,k in NN,m in NN:(i,j,k,m) in L}:
	sum{f in FN}(sum{n in RN}(yp[n,i,j,k,m,f] + yb[n,i,j,k,m,f])) <= c[i,j,k,m];
/*
s.t. LINK_DISJOINTNESS{n in RN,i in DN,j in DN,k in NN,m in NN:(i,j,k,m) in L}:
	sum{f in FN}(xp[n,i,j,k,m,f]+xb[n,i,j,k,m,f])<=1;
*/
s.t. SAME_DOMAIN_SEQUENCE{n in RN,i in DN, j in DN:i != j}:
	sum{k in NN, m in NN:(i,j,k,m) in L}(sum{f in FN}(xp[n,i,j,k,m,f])) =
	sum{k in NN, m in NN:(i,j,k,m) in L}(sum{f in FN}(xb[n,i,j,k,m,f]));

s.t. PRIMARY_PASS_IS_GOOD{n in RN}:
	sum{i in DN,j in DN,k in NN,m in NN:(i,j,k,m) in L}(sum{f in FN}(xp[n,i,j,k,m,f])) <=
	sum{i in DN,j in DN,k in NN,m in NN:(i,j,k,m) in L}(sum{f in FN}(xb[n,i,j,k,m,f]));

s.t. PRIMARY_INDEX_MAXIMUM{n in RN,i in DN,j in DN,k in NN,m in NN:(i,j,k,m) in L}:
	sum{f in FN}(yp[n,i,j,k,m,f]) <= sum{f in FN}(xp[n,i,j,k,m,f]) * c[i,j,k,m];
s.t. PRIMARY_INDEX_MINIMUM{n in RN,i in DN,j in DN,k in NN,m in NN:(i,j,k,m) in L}:
	sum{f in FN}(yp[n,i,j,k,m,f]) >=sum{f in FN}(xp[n,i,j,k,m,f]);

s.t. BACKUP_INDEX_MAXIMUM{n in RN,i in DN,j in DN,k in NN,m in NN:(i,j,k,m) in L}:
	sum{f in FN}(yp[n,i,j,k,m,f]) <=sum{f in FN}(xb[n,i,j,k,m,f]) * c[i,j,k,m];
s.t. BACKUP_INDEX_MINIMUM{n in RN,i in DN,j in DN,k in NN,m in NN:(i,j,k,m) in L}:
	sum{f in FN}(yp[n,i,j,k,m,f]) >=sum{f in FN}(xb[n,i,j,k,m,f]);

end;
