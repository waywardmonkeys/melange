Module: c-types


//=========================================================================
//  C Types
//=========================================================================
//  All C types are either primitive or derived from other types.

define abstract class <c-type> (<object>)
end class;

define abstract class <c-primitive-type> (<c-type>)
  slot c-primitive-type-name :: <string>,
    required-init-keyword: name:;
end class;

define abstract class <c-derived-type> (<c-type>)
end class;


//=========================================================================
//  Complete and Incomplete Types
//=========================================================================
//  Certain type declarations are incomplete and may not be used in other
//  kinds of declarations.

define generic c-type-complete? (type :: <c-type>) => (complete? :: <boolean>);

define method c-type-complete? (type :: <c-type>) => (complete? :: <boolean>)
  #t;
end;


//=========================================================================
//  Primitive Types
//=========================================================================
//  Primitive types are either numeric or void types.

define class <c-void-type> (<c-primitive-type>)
end;

define abstract class <c-numeric-type> (<c-primitive-type>)
end;

define abstract class <c-integer-type> (<c-numeric-type>)
  slot c-integer-type-sign-specifier :: <c-sign-specifier>,
    required-init-keyword: sign:;
end;

define class <c-char-type> (<c-integer-type>)
end;

define class <c-short-type> (<c-integer-type>)
end;

define class <c-int-type> (<c-integer-type>)
end;

define class <c-long-type> (<c-integer-type>)
end;

define class <c-long-long-type> (<c-integer-type>)
end;

define class <c-floating-point-type> (<c-numeric-type>)
end;

// Legal sign specifiers
define constant <c-sign-specifier> =
  one-of(#"signed", #"unsigned", #"unspecified");

// Void
define constant $c-void-type =
  make(<c-void-type>, name: "void");

// Integers
define constant $c-char-type =
  make(<c-char-type>, name: "char", sign: #"unspecified");
define constant $c-signed-char-type =
  make(<c-char-type>, name: "signed char", sign: #"signed");
define constant $c-unsigned-char-type =
  make(<c-char-type>, name: "unsigned char", sign: #"unsigned");
define constant $c-short-type =
  make(<c-short-type>, name: "short", sign: #"unspecified");
define constant $c-signed-short-type =
  make(<c-short-type>, name: "signed short", sign: #"signed");
define constant $c-unsigned-short-type =
  make(<c-short-type>, name: "unsigned short", sign: #"unsigned");
define constant $c-int-type =
  make(<c-int-type>, name: "int", sign: #"unspecified");
define constant $c-signed-int-type =
  make(<c-int-type>, name: "signed int", sign: #"signed");
define constant $c-unsigned-int-type =
  make(<c-int-type>, name: "unsigned int", sign: #"unsigned");
define constant $c-long-type =
  make(<c-long-type>, name: "long", sign: #"unspecified");
define constant $c-signed-long-type =
  make(<c-long-type>, name: "signed long", sign: #"signed");
define constant $c-unsigned-long-type =
  make(<c-long-type>, name: "unsigned long", sign: #"unsigned");
define constant $c-long-long-type =
  make(<c-long-long-type>, name: "long long", sign: #"unspecified");
define constant $c-signed-long-long-type =
  make(<c-long-long-type>, name: "signed long long", sign: #"signed");
define constant $c-unsigned-long-long-type =
  make(<c-long-long-type>, name: "unsigned long long", sign: #"unsigned");

// Floats
define constant $c-float-type =
  make(<c-floating-point-type>, name: "float");
define constant $c-double-type =
  make(<c-floating-point-type>, name: "double");
define constant $c-long-double-type =
  make(<c-floating-point-type>, name: "long double");


//=========================================================================
//  Tagged types
//=========================================================================
//  Tagged types include structs, unions and enums. They have an optional
//  "tag" that names the type. If this tag is omitted, each struct, etc.,
//  defines a unique anonymous type.

// XXX - make this thread safe
define variable *anonymous-tag-counter* = 0;

define abstract class <c-tagged-type> (<c-derived-type>)
  slot c-type-tag :: false-or(<string>),
    init-keyword: tag:,
    init-value: #f;
  slot c-type-anonymous-tag :: false-or(<integer>),
    init-value: #f;
end;

define method initialize
    (type :: <c-tagged-type>, #next next-method, #rest keys, #key, #all-keys)
  next-method();
  unless (type.c-type-tag)
    type.c-type-anonymous-tag := *anonymous-tag-counter*;
    *anonymous-tag-counter* := *anonymous-tag-counter* + 1;
    type.c-type-tag := format-to-string("$%d", type.c-type-anonymous-tag);
  end;
end;


//=========================================================================
//  Structs and Unions
//=========================================================================
//  Structures and unions are essentially identical (in terms of the type
//  model) except for the handling of bit fields in structs.

define abstract class <c-struct-or-union-type> (<c-tagged-type>)
  slot c-type-members :: false-or(<stretchy-vector>) = make(<stretchy-vector>),
    init-keyword: members:;
end;

define class <c-struct-type> (<c-struct-or-union-type>)
  // elements of c-type-members are of type <c-struct-member>
end;

define class <c-union-type> (<c-struct-or-union-type>)
  // elements of c-type-members are of type <c-member-variable>
end;

define method c-type-complete?
    (type :: <c-struct-or-union-type>)
 => (complete? :: <boolean>)
  type.c-type-members ~= #f;
end;

define abstract class <c-struct-member> (<object>)
end;

define class <c-member-variable> (<c-struct-member>)
  slot c-member-variable-name :: <string>,
    required-init-keyword: name:;
  slot c-member-variable-type :: <c-type>,
    required-init-keyword: type:;
  // MSVC - Need packing information
end;

define class <c-bit-field> (<c-struct-member>)
  slot c-bit-field-name :: false-or(<string>),
    required-init-keyword: name:;
  slot c-bit-field-sign-specifier :: <c-sign-specifier>,
    required-init-keyword: sign:;
  slot c-bit-field-width :: <integer>,
    required-init-keyword: width:;
end;


//=========================================================================
//  Enums
//=========================================================================
//  Enumerations define a number of constant values. By the time an enum
//  reaches this code, all values should have been computed--we don't
//  support the "counting" mechanism used by ANSI C.

define class <c-enum-type> (<c-tagged-type>)
  slot c-enum-members :: <stretchy-vector> = make(<stretchy-vector>);
  // elements of c-enum-members are of type <c-enum-constant>
end;

define class <c-enum-constant> (<object>)
  slot c-enum-constant-name :: <string>,
    required-init-keyword: name:;
  slot c-enum-constant-value :: <integer>,
    required-init-keyword: value:;
end;


//=========================================================================
//  Pointer-valued types
//=========================================================================
//  According to ANSI C, arrays and pointers are entirely different things.
//  However, array names will evaluate to a pointer in many cases, so it
//  makes sense to treat them as similar in our object model.

define class <c-pointer-valued-type> (<c-derived-type>)
  slot c-pointer-referent-type :: <c-type>,
    required-init-keyword: referent:;
end;

define class <c-pointer-type> (<c-pointer-valued-type>)
end;

define class <c-array-type> (<c-pointer-valued-type>)
  slot c-array-size :: false-or(<integer>),
    init-keyword: size:,
    init-value: #f;
end;

define method c-type-complete?
    (type :: <c-array-type>)
 => (complete? :: <boolean>)
  type.c-array-size ~= #f;
end;


//=========================================================================
//  Function types
//=========================================================================
//  Functions have complex derived types.

define class <c-function-type> (<c-derived-type>)
  slot c-function-return-type :: <c-type>,
    required-init-keyword: return-type:;
  slot c-function-parameters :: <stretchy-vector> = make(<stretchy-vector>);
  // members of c-function-parameters are of type <c-function-parameter>

  // Record new and old style declarations exactly.
  slot c-function-explicit-varargs? :: <boolean>,
    init-keyword: explicit-varargs?:,
    init-value: #f;
  slot c-function-explicit-void? :: <boolean>,
    init-keyword: explicit-void?:,
    init-value: #f;

  // MSVC - need to handle __stdcall, maybe others.
end;

define class <c-function-parameter> (<object>)
  slot c-function-parameter-name :: false-or(<string>),
    required-init-keyword: name:;
  slot c-function-parameter-type :: <c-type>,
    required-init-keyword: type:;
end;


//=========================================================================
//  Typedef types
//=========================================================================
//  In C, a typedef is a transparent alias for another type. In our type
//  model, we attempt to represent typedefs explicitly. If we're careful,
//  this shouldn't cause any problems.

define class <c-typedef-type> (<c-derived-type>)
  slot c-typedef-name :: <string>,
    required-init-keyword: name:;
  slot c-typedef-type :: <c-type>,
    required-init-keyword: type:;
end;


//=========================================================================
//  Type Names
//=========================================================================
//  Print out a simple name for a given type, when available. Otherwise,
//  return false.

define generic c-type-name
    (type :: <c-type>)
 => (name :: false-or(<string>));

define method c-type-name
    (type :: <c-type>)
 => (name :: singleton(#f))
  #f;
end;

define method c-type-name
    (type :: <c-primitive-type>)
 => (name :: <string>)
  type.c-primitive-type-name;
end;

define method c-type-name
    (type :: <c-struct-type>)
 => (name :: <string>)
  concatenate("struct ", type.c-type-tag);
end;

define method c-type-name
    (type :: <c-union-type>)
 => (name :: <string>)
  concatenate("union ", type.c-type-tag);
end;

define method c-type-name
    (type :: <c-enum-type>)
 => (name :: <string>)
  concatenate("enum ", type.c-type-tag);
end;

define method c-type-name
    (type :: <c-typedef-type>)
 => (name :: <string>)
  type.c-typedef-name;
end;

define constant <c-named-type> =
  type-union(<c-primitive-type>, <c-tagged-type>, <c-typedef-type>);


//=========================================================================
//  Formatting type declarators
//=========================================================================
//  Format a declarator for a given type and declaration name. If no
//  declaration name is specified, format an abstract declarator. This is a
//  really obnoxious problem, to say the least.
//
//  Oh, yeah--this conses like crazy, so don't expect it to run fast.

define function format-c-type-declarator
    (type :: <c-type>,
     #key decl-name :: false-or(<string>), parameter-names? :: <boolean>)
 => (decl :: <string>)
  let type-name = c-type-name(type);
  if (type-name)
    // Short-circuit the common cases for performance.
    if (decl-name)
      concatenate(type-name, " ", decl-name);
    else
      type-name;
    end if;
  else
    // Oh, well. This will take some work, then.
    let types = nested-type-list(type);

    let last-was-direct? = #t;
    let decl = decl-name | "";

    for (type in types)
      select (type by instance?)

	<c-pointer-type> =>
	  decl := concatenate("*", decl);
	  last-was-direct? := #f;

	<c-array-type> =>
	  let size = type.c-array-size;
	  let size-str =
	    if (size)
	      format-to-string("[%d]", size);
	    else
	      "[]"
	    end;
	  decl :=
	    if (last-was-direct?)
	      concatenate(decl, size-str);
	    else
	      concatenate("(", decl, ")", size-str);
	    end;
	  last-was-direct? := #t;

	<c-function-type> =>
	  let arguments = ""; // XXX - this is wrong
	  decl :=
	    if (last-was-direct?)
	      concatenate(decl, "(", arguments, ")");
	    else
	      concatenate("(", decl, ")(", arguments, ")");
	    end;
	  last-was-direct? := #t;

	<c-named-type> =>
	  // Always our final time through the loop...
	  decl := concatenate(c-type-name(type), " ", decl);

	otherwise =>
	  error("did not expect %= when formatting C declarator");

      end select;
    end for;
    // Ugh. That was *way* too hard.
    decl;
  end if;
end function format-c-type-declarator;

define generic nested-type-list
    (type :: <c-type>)
 => (nested :: <list>);

define method nested-type-list
    (type :: <c-named-type>)
 => (nested :: <list>)
  pair(type, #());
end;

define method nested-type-list
    (type :: <c-pointer-valued-type>)
 => (nested :: <list>)
  pair(type, nested-type-list(type.c-pointer-referent-type));
end;

define method nested-type-list
    (type :: <c-function-type>)
 => (nested :: <list>)
  pair(type, nested-type-list(type.c-function-return-type));
end;