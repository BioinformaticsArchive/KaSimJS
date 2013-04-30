caml_callbacks.write_file_content("input",
"%agent: a(x~u~p)\n\
%agent: b(y~u~p)\n\
\n\
a(x), b(y) -> a(x!1), b(y!1) @1\n\
a(x!1), b(y!1) -> a(x), b(y) @1\n\
a(x!1), b(y~u!1) -> a(x!1), b(y~p!1) @1\n\
\n\
%init: 100000 a(x~u)\n\
%init: 200000 b(y~u)\n\
%obs: 'a phos' b(y~u)" );
