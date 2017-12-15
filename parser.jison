%lex
%options flex
%x comment
%%
<comment>'*/'
	{ this.popState() }
<comment>'/*'
	{ this.begin('comment') }
<comment>[^=#]+
	/* eat comments */
<comment>.
	/* eat comments */
[ \f\r\n\t\v]+
	/* eat whitespace */
\/\/[^\n]*
	/* eat comments */
'/*'
	{ this.begin('comment') }
'||'|'&&'|'=='|'!='|'<='|'>='|'>>'|'<<'|[,&!><=+%/*^()\-]
	{ return yytext }
if|then|elseif|else|true|false
	{ return yytext.toUpperCase() }
["](?:\\.|[^\\"])*["] {
	yytext = yytext.slice(1,-1).replace(/\\([nrt"\\]|x[a-fA-F0-9]{2}|u[a-fA-F0-9]{4})/g,function(m,g){
		switch(g[0]){
			case 'x':
			case 'u':
				return String.fromCodePoint(parseInt(g.slice(1),16))=='"'?
				'""':String.fromCodePoint(parseInt(g.slice(1),16))
			case 'n': return '\n'
 			case 'r': return '\r'
 			case 't': return '\t'
			case '"': return '""'
		}
		return g
	})
	return 'STRING'
}
(?:\'[^\']+\'\!|\[[^\]]+\][^!]+\!)?\$?[A-Za-z]+\$?\d+(?:\:\$?[A-Za-z]+\$?\d+)?
	{ return 'CELL' }
[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?
	{ return 'NUMBER' }
0[Xx][0-9a-fA-F]+
	{ yytext = yytext.slice(2); return 'HEXNUMBER' }
0[bB][01]+
	{ yytext = yytext.slice(2); return 'BINNUMBER' }
[a-zA-Z\u0100-\uffff][a-zA-Z0-9.\u0100-\uffff]*
	{ yytext = yytext.toUpperCase(); return 'NAME' }
.
	{ return 'INVALID_TOKEN' }

/lex
%right 'THEN' 'ELSEIF' 'ELSE'
%left '||'
%left '&&'
%left '==' '!='
%left '<' '<=' '>=' '>'
%left '<<' '>>'
%left '&' '+' '-'
%left '*' '/' '%'
%right '^'
%right '!' 'NEG'
%%

program: expression { output = $1 } ;

expression:
	NAME '(' expressions ')'
		{ $$ = call($1,$3) } |
	IF ifexpression
		{ $$ = $2 } |
	'('	expression ')'
		{ $$ = $2 } |
	expression '||' expression
		{ $$ = call('OR',[$1,$3]) } |
	expression '&&' expression
		{ $$ = call('AND',[$1,$3]) } |
	expression '^' expression
		{ $$ = operator('^',$1,$3) } |
	expression '==' expression
		{ $$ = operator('=',$1,$3) } |
	expression '!=' expression
		{ $$ = operator('<>',$1,$3) } |
	expression '<' expression
		{ $$ = operator('<',$1,$3) } |
	expression '<=' expression
		{ $$ = operator('<=',$1,$3) } |
	expression '>=' expression
		{ $$ = operator('>=',$1,$3) } |
	expression '>' expression
		{ $$ = operator('>',$1,$3) } |
	expression '<<' expression
		{ $$ = call('BITLSHIFT',[$1,$3]) } |
	expression '>>' expression
		{ $$ = call('BITRSHIFT',[$1,$3]) } |
	expression '+' expression
		{ $$ = operator('+',$1,$3) } |
	expression '&' expression
		{ $$ = operator('&',$1,$3) } |
	expression '-' expression
		{ $$ = operator('-',$1,$3) } |
	expression '*' expression
		{ $$ = operator('*',$1,$3) } |
	expression '/' expression
		{ $$ = operator('/',$1,$3) } |
	expression '%' expression
		{ $$ = call('MOD',[$1,$3]) } |
	'!' expression
		{ $$ = call(@1,'BOT',[$2]) } |
	'-' expression %prec NEG
		{ $$ = operator('-',undefined,$2) } |
	CELL
		{ $$ = value('cell',$1) } |
	NUMBER
		{ $$ = value('number',parseFloat($1)) } |
	HEXNUMBER
		{ $$ = value('number',parseInt($1,16)) } |
	BINNUMBER
		{ $$ = value('number',parseInt($1,2)) } |
	STRING
		{ $$ = value('string',$1) } |
	TRUE
		{ $$ = call('TRUE',[]) } |
	FALSE
		{ $$ = call('FALSE',[]) }
;

expressions:
	expressions ',' expression
		{ $$ = $1; $1.push($3) } |
	expression
		{ $$ = [$1] }
;

ifexpression:
	expression THEN expression
		{ $$ = call('IF',[$1,$3,call('FALSE',[])]) } |
	expression THEN expression ELSE expression
		{ $$ = call('IF',[$1,$3,$5]) } |
	expression THEN expression ELSEIF ifexpression
		{ $$ = call('IF',[$1,$3,$5]) }
;

%%
function call(name,args){
	return {type:'call',function:name,arguments:args}
}
function operator(op,a,b){
	return {type:'operator',operator:op,left:a,right:b}
}
function value(t,v){
	return {type:t,value:v}
}
var output = null
parser._parse = parser.parse
parser.parse = function(input){
	this._parse(input)
	return output
}
