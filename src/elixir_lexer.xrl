% Lexer syntax for the Elixir language done with leex
% Copyright (C) 2011 Jose Valim
%
% Some bits of this lexer were retrieved from from Reia lexer
% Copyright (C)2008-09 Tony Arcieri

Definitions.

Digit = [0-9]
UpperCase = [A-Z]
LowerCase = [a-z]
Whitespace = [\s]
IdentifierBase = ({UpperCase}|{LowerCase}|{Digit}|_)
DoubleQuoted = "[^\"\\n]*"
Comment = %.*

Rules.

%% Numbers
{Digit}+\.{Digit}+ : { token, { float, TokenLine, list_to_float(TokenChars) } }.
{Digit}+           : { token, { integer, TokenLine, list_to_integer(TokenChars) } }.

%% Atoms
\'({UpperCase}|{LowerCase}|_){IdentifierBase}* : build_atom(TokenChars, TokenLine, TokenLen). % '
\'{DoubleQuoted} : build_quoted_atom(TokenChars, TokenLine, TokenLen). % '

%% Constant and identifier names
{UpperCase}({IdentifierBase}|::)* : build_constant(TokenLine, TokenChars).
({LowerCase}|_){IdentifierBase}*  : build_identifier(TokenLine, TokenChars).
({LowerCase}|_){IdentifierBase}*[?!] : build_punctuated_identifier(TokenLine, TokenChars).

%% Operators
\+    : { token, { '+', TokenLine } }.
-     : { token, { '-', TokenLine } }.
\*    : { token, { '*', TokenLine } }.
/     : { token, { '/', TokenLine } }.
\(    : { token, { '(', TokenLine } }.
\)    : { token, { ')', TokenLine } }.
\[    : { token, { '[', TokenLine } }.
\]    : { token, { ']', TokenLine } }.
\{    : { token, { '{', TokenLine } }.
\}    : { token, { '}', TokenLine } }.
=     : { token, { '=', TokenLine } }.
;     : { token, { ';', TokenLine } }.
\:    : { token, { ':', TokenLine } }.
,     : { token, { ',', TokenLine } }.
\.    : { token, { '.', TokenLine } }.
\@    : { token, { '@', TokenLine } }.
->    : { token, { '->', TokenLine } }.

%% Skip
{Comment} : skip_token.
{Whitespace}+ : skip_token.

%% Newlines (with comment and whitespace checks)
({Comment}|{Whitespace})*(\n({Comment}|{Whitespace})*)+ : { token, { eol, TokenLine } }.

Erlang code.

build_constant(Line, Chars) ->
  { token, { constant, Line, list_to_atom(Chars) } }.

build_identifier(Line, Chars) ->
  Atom = list_to_atom(Chars),
  case reserved_word(Atom) of
      true -> {token, {Atom, Line}};
      false -> {token, {identifier, Line, Atom}}
  end.

build_punctuated_identifier(Line, Chars) ->
  {token, {punctuated_identifier, Line, list_to_atom(Chars)}}.

build_atom(Chars, Line, Len) ->
  String = lists:sublist(Chars, 2, Len - 1),
  {token, {atom, Line, list_to_atom(String)}}.

build_quoted_atom(Chars, Line, Len) ->
  String = lists:sublist(Chars, 2, Len - 2),
  build_atom(String, Line, Len - 2).

reserved_word('end')       -> true;
reserved_word('do')        -> true;
reserved_word('module')    -> true;
reserved_word('object')    -> true;
reserved_word('def')       -> true;
reserved_word('erl')       -> true;
% reserved_word('nil')     -> true;
% reserved_word('true')    -> true;
% reserved_word('false')   -> true;
% reserved_word('class')   -> true;
% reserved_word('begin')   -> true;
% reserved_word('case')    -> true;
% reserved_word('receive') -> true;
% reserved_word('after')   -> true;
% reserved_word('when')    -> true;
% reserved_word('if')      -> true;
% reserved_word('elseif')  -> true;
% reserved_word('else')    -> true;
% reserved_word('unless')  -> true;
% reserved_word('and')     -> true;
% reserved_word('or')      -> true;
% reserved_word('not')     -> true;
% reserved_word('for')     -> true;
% reserved_word('in')      -> true;
% reserved_word('try')     -> true;
% reserved_word('catch')   -> true;
% reserved_word('throw')   -> true;
reserved_word(_)           -> false.