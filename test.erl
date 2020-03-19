-module(test).
-compile(export_all).

proc_print(file_target) ->
    io:display(proc_process),
    io:format(gloabl:whereis_name(file_target), "~w~n", [lalamimifarina]).

print() ->
    % {ok, Fh} = file:open("output_file", [write]),
    % io:format(Fh, "~w~n", [hello]).
    {ok, Fh} = file:open("output_file", [write]),
    global:register_name(file_target, Fh),
    spawn(test, proc_print, [file_target]).


