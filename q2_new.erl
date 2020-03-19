-module(q2_new).
-compile(export_all).


proc(X) ->
    main_proc ! lists:sort(X).


receive_stuff(0, L, Output_file_string) ->
    {ok, Fh} = file:open(Output_file_string, [write]), 
    Output_list = [integer_to_list(X) ++ " " || X <- lists:merge(L)],
    io:format(Fh,"~s~n", [Output_list]);

receive_stuff(N, L, Output_file_string) ->
    receive 
        X ->
            Intermediate = [X|L],
            receive_stuff(N-1, Intermediate, Output_file_string)
    end.

split([],_)->[];
split(L, N) when length(L) < N -> [L];
split(L, N) ->
    {A, B} = lists:split(N, L),
    [A | split(B, N)].

spawn_processes(1, Lol) ->
    spawn(q2_new, proc, [lists:nth(1, Lol)]);

spawn_processes(N, Lol) ->
    spawn(q2_new, proc, [lists:nth(N, Lol)]),
    spawn_processes(N-1, Lol).

modify(0, Lol_raw) ->
    Lol_raw;
modify(N, Lol_raw) ->
    modify(N-1, [[]|Lol_raw]).


main([Input_file, Output_file]) ->

    % Set up output file
    Num_processes = 8,
    Output_file_string = atom_to_list(Output_file),

    % Read input into a list
    Input_file_string = atom_to_list(Input_file),
    {ok, Data} = file:read_file(Input_file_string), 
    Big_list = [binary_to_integer(X) || X <- string:lexemes(Data, " \t\n")],
    Size = (length(Big_list) div Num_processes) + 1,

    %Split into list of lists and sending them!
    Lol_raw= split(Big_list, Size),
    Diff = Num_processes - length(Lol_raw),
    Lol = modify(Diff, Lol_raw),

    register(main_proc , self()),
    spawn_processes(Num_processes, Lol),
    L = [],
    receive_stuff(Num_processes, L, Output_file_string).