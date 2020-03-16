-module(q1).
-export([main/2, rest/2, first/2]).

rest(Own_num, N) ->
    Next_num = (Own_num + 1) rem N,
    Prev_num = (Own_num - 1) rem N,
    Next_id = list_to_atom(integer_to_list(Next_num)),
    receive 
        Token ->
            io:format("Process ~w received token ~w from process ~w.~n",[Own_num, Token, Prev_num]),
            Next_id ! Token
    end.

first(Token, N) ->
    Next_num = (1) rem N,
    Prev_num = N-1,
    Next_id = list_to_atom(integer_to_list(Next_num)),
    Next_id ! Token,
    receive
        Token ->
            io:format("Process ~w received token ~w from process ~w.~n",[0, Token, Prev_num])
    end.
    

loop(0, Token, Num_processes)->
    register(list_to_atom(integer_to_list(0)), spawn(q1, first, [Token, Num_processes]));
    % io:format("this the culprit~n", []);
loop(N, Token, Num_processes)->
    register(list_to_atom(integer_to_list(N)), spawn(q1, rest, [N, Num_processes])),
    loop(N-1, Token, Num_processes).

readlines()


main(Num_processes, Token) ->
    % if 
    %     Num_processes > 1 ->
    %         loop(Num_processes-1, Token, Num_processes);
    %     true ->
    %         io:format("~n",[])

    % end.
    loop(Num_processes-1, Token, Num_processes).

% look at registering of processes/ spawning together/ knowing 
% each other's Pid.


