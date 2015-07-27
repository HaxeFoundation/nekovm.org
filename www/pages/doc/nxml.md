====== NXML ======

Neko sources syntax is easy to read but can sometimes be difficult to generate. Also, it does not permit embedding file and line numbers informations. For example if your generate from a file in your language ''MyFile.mylang'' to ''myfile.neko'' you would like to get errors traces in terms of position in the original ''MyFile.mylang'' file.

For these reasons, an extension of the neko syntax is allowed which is called NXML. This is not a different format in sense that you easily mix NXML and Neko sources together. You can put some NXML expressions in Neko sources and some Neko sources into an NXML document. NXML is based on XML and is representing a Neko Abstract Syntax Tree (AST).

====== NXML Nodes ======

NXML is not a different Neko syntax but a syntax extension. It means that you can put some NXML expressions inside a Neko program and some Neko program inside NXML as well.

In order to use the NXML syntax you need to start with ''<nxml>'' and finish with ''</nxml>''. All NXML nodes inside are Neko expressions. An NXML block is like a Neko block. For example ''<nxml></nxml>'' is the equivalent of the empty Neko block ''{ }''.

Other nodes are the following :

  * ''<i v="3"/>'' the literal integer 3
  * ''<f v="1.5"/>'' the literal float 1.5
  * ''<s v="a string"/>'' the literal string ''a string''
  * ''<v v="id"/>'' the identifier ''id'' (includes special identifiers such as null, true, false and this)
  * ''<b>e1 e2 e3...</b>'' a block having several subexpressions
  * ''<p>e</p>'' parenthis around a subexpression
  * ''<g v="field">e</g>'' field access of a subexpression ''(e).field''
  * ''<c>e0 e1 e2 e3...</c>'' call of ''e0(e1,e2,e3...)''
  * ''<a>e1 e2</a>'' array access ''e1[e2]''
  * ''<var><v v="x">e</v><v v="y"/></var>'' local variable declaration, equivalent of ''var x = e, y''
  * ''<while>e1 e2</while>'' while loop : ''while e1 e2''
  * ''<do>e1 e2</do>'' do...while loop : ''do e1 while e2''
  * ''<if>e0 e1</if>'' equivalent of ''if e0 e1''
  * ''<if>e0 e1 e2</if>'' equivalent of ''if e0 e1 else e2''
  * ''<o v="*">e1 e2</o>'' a binary operation such as ''e1 * e2''
  * ''<try v="exc">e1 e2</try>'' a try..catch block ''try e1 catch exc e2''
  * ''<function v="x:y:z">e</function>'' a function declaration such as ''function(x,y,z) e''
  * ''<return/>'' the return statement without expression
  * ''<return>e</return>'' return of an expression value
  * ''<break/>'' the break statement without expression
  * ''<break>e</break>'' break with an expression value
  * ''<continue/>'' the continue statement
  * ''<next>e1 e2</next>'' a way to tie two expressions together (such as ''e1;e2'')
  * ''<label v="here"/>'' the goto label ''here:''
  * ''<switch>e0 <case>e1 e2</case> <case>e1 e2</case> <default>edef</default></switch>'' a switch with several cases and an optional default
  * ''<object><v v="f0"><i v="42"/></v><v v="f1"><s v="foo"/></v></object>'' an object literal, equivalent to the neko code ''{ f0 => 42, f1 => "foo" }''
  * ''<neko>....</neko>'' some neko source, can be embedded into a ''%%<!CDATA[[...]]%%>'' section.

For example, if we want to represent the fibonnaci function in NXML :

<code neko>
fib = function(n) {
    if( n <= 1 ) 1 else fib(n-1)+fib(n-2)
}
</code>

<code>
<o v="=">
    <v v="fib"/>
    <function v="n">
        <if>
             <o v="<="><v v="n"/><i v="1"/></o>
             <i v="1"/>
             <o v="+">
                 <c><v v="fib"/><o v="-"><v v="n"/><i v="1"/></o></c>
                 <c><v v="fib"/><o v="-"><v v="n"/><i v="2"/></o></c>
             </o>
        </if>
    </function>
</o>
</code>

====== File Position ======

The additional attribute ''p'' can be placed on every NXML node in order to specify from which original file and line the expression is generated. For example ''<i v="33" p="myfile.l:478"/>'' is the integer 33 referenced in ''myfile.l'' at line 478.

When encountered, such position is stored and remains valid for all NXML nodes. For example ''<nxml><i v="33" p="myfile.l:478"/><i v="34"/></nxml>'' is listing two integers from ''myfile.l'', both at line 478.

If you don't specify the filename in the ''p'' attribute, it's considered to be a number of lines skipped since the last ''p'' information. For example ''<nxml><i v="33" p="myfile.l:478"/><i v="34" p="2"/></nxml>'' is listing two integers from ''myfile.l'', the first ''33'' at line 478 and the second ''34'' at line 480 (478 + 2).

====== NXML to Neko ======

There is a NXML to Neko generator which is available using the ''nekoc'' compiler. Simply run ''nekoc myfile.neko'' containing Neko/NXML syntax, it will create a ''myfile2.neko'' that will only contain Neko source code.

There is not a Neko to NXML generator right now, although it should be possible to write one very easily.