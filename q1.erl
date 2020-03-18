-module(q1).
-export([main/1, rest/3, first/3]).

rest(Own_num, N, Fh) ->
    Next_num = (Own_num + 1) rem N,
    Prev_num = (Own_num - 1) rem N,
    Next_id = list_to_atom(integer_to_list(Next_num)),
    receive 
        Token ->
            io:format(Fh, "Process ~w received token ~w from process ~w.~n",[Own_num, Token, Prev_num]),
            Next_id ! Token
    end.

first(Token, N, Fh) ->
    Next_num = (1) rem N,
    Prev_num = N-1,
    Next_id = list_to_atom(integer_to_list(Next_num)),
    Next_id ! Token,
    receive
        Token ->
            io:format(Fh, "Process ~w received token ~w from process ~w.~n",[0, Token, Prev_num])
    end.
    

loop(0, Token, Num_processes, Fh)->
    register(list_to_atom(integer_to_list(0)), spawn(q1, first, [Token, Num_processes, Fh]));
    % io:format("this the culprit~n", []);
loop(N, Token, Num_processes, Fh)->
    register(list_to_atom(integer_to_list(N)), spawn(q1, rest, [N, Num_processes, Fh])),
    loop(N-1, Token, Num_processes, Fh).

main([Input_file, Output_file]) ->
    % if 
    %     Num_processes > 1 ->
    %         loop(Num_processes-1, Token, Num_processes);
    %     true ->
    %         io:format("~n",[])

    % end.
    Input_file_string = atom_to_list(Input_file),
    Output_file_string = atom_to_list(Output_file),
    {ok, Fh} = file:open(Output_file_string, [write]),
    {ok, Data} = file:read_file(Input_file_string),
    Parts = string:lexemes(Data, " \n"),
    Num_processes = binary_to_integer(lists:nth(1, Parts)),
    Token = binary_to_integer(lists:nth(2, Parts)),
    loop(Num_processes-1, Token, Num_processes, Fh).

% look at registering of processes/ spawning together/ knowing 
% each other's Pid.


