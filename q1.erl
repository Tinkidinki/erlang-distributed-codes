-module(q1).
-export([main/2, task/0, first/1]).


main(Num_processes, Token) ->
    First_process = spawn()

