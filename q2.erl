-module(q2).
-compile(export_all).


% receive_lol(0, L) ->
%     lists:merge(L), 
%     io:format("~w~n", [L]);

% receive_lol(N, L) ->
%     receive 
%         X ->
%             Intermediate = [X|L],
%             receive_lol(N-1, Intermediate)
%     end.

receive_lol(1, L) ->
    receive
        X ->
            io:format(group_leader(), "~w~n", [X])
    end;

receive_lol(N, L) ->
    receive
        X ->
            io:format(group_leader(),"~w~n", [X])
    end,
    receive_lol(N-1, L).
    

send(Lol, 1)->
    % list_to_atom(integer_to_list(1)) ! lists:nth(1, Lol);
    list_to_atom(integer_to_list(1)) ! hi;

send(Lol, N) ->
    % list_to_atom(integer_to_list(N)) ! lists:nth(N, Lol), 
    list_to_atom(integer_to_list(N)) ! hi, 
    send(Lol, N-1).

proc() ->
    receive 
        L ->
            % start_process ! lists:sort(L)
            start_process ! self()
    end.


split([],_)->[];
split(L, N) when length(L) < N -> [L];
split(L, N) ->
    {A, B} = lists:split(N, L),
    [A | split(B, N)].

start([Input_file, Output_file]) ->
    % Set up output file
    % Output_file_string = atom_to_list(Output_file),

    % Read input into a list
    % Input_file_string = atom_to_list(Input_file),
    % {ok, Fh} = file:open(Output_file_string, [write]), 
    % {ok, Data} = file:read_file(Input_file_string), 
    % Big_list = [binary_to_integer(X) || X <- string:lexemes(Data, " \t\n")],
    % Size = (length(Big_list) div 8) + 1,

    % Split into list of lists and sending them!
    % Lol = split(Big_list, Size),
    io:format("~w~n", [started]),
    Lol = 123,
    io:format("~w~n", [next]),
    send(Lol, 1),
    io:format("~w~n", [after_this]),
    

    receive_lol(2, []).

reg_others(1) ->
    register(list_to_atom(integer_to_list(1)), spawn(q2, proc, []));

reg_others(N) ->
    register(list_to_atom(integer_to_list(1)), spawn(q2, proc, [])).

main(Io) ->
    register(start_process, spawn(q2, start, [Io])), 
    reg_others(1).





