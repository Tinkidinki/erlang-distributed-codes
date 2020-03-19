# Assignment 4 : Distributed Systems in Erlang
Mahathi Vempati, 20161003

## Problem Statement 1 : Token Passing

### Problem
Taking input as the number of processes and a token value, pass the token around in a ring.

### Solution

In the main function, we call a function called `loop` that spawns a processes differently based on whether it is Process `1` or any other process.
```
main([Input_file, Output_file]) ->

    Input_file_string = atom_to_list(Input_file),
    Output_file_string = atom_to_list(Output_file),
    {ok, Data} = file:read_file(Input_file_string),
    Parts = string:lexemes(Data, " \n"),
    Num_processes = binary_to_integer(lists:nth(1, Parts)),
    Token = binary_to_integer(lists:nth(2, Parts)),
    loop(Num_processes-1, Token, Num_processes, Output_file_string).
```
As seen below, loop spawns the first process to start at the function `first` and the rest of the processes to start at the function `rest`.

An important aspect here is that an atom corresponding to a process number is registered as the process id for every process. Using this, other processes can easily send messages to this process. 

```
loop(0, Token, Num_processes, Output_file_string)->
    register(list_to_atom(integer_to_list(0)), spawn(q1, first, [Token, Num_processes, Output_file_string]));
 
loop(N, Token, Num_processes, Output_file_string)->
    register(list_to_atom(integer_to_list(N)), spawn(q1, rest, [N, Num_processes, Output_file_string])),
    loop(N-1, Token, Num_processes, Output_file_string)
```

The Process that starts at `first` has the token when it spawns itself. It first sends out the token, and then waits to receive it. 

```
first(Token, N, Output_file_string) ->
    Next_num = (1) rem N,
    Prev_num = N-1,
    Next_id = list_to_atom(integer_to_list(Next_num)),
    Next_id ! Token,
    receive
        Token ->
            {ok, Fh} = file:open(Output_file_string, [append]),
            io:fwrite(Fh, "Process ~w received token ~w from process ~w.~n",[0, Token, Prev_num])
    end.
```

The other processes first wait to receive the token, and then send it the moment they receive it. Every process calculates their next process using modulus. 
The integer corresponding to the next process number is converted to an atom, and since this was registered with the process id at the beginning, it can be used to send the process. 

```
rest(Own_num, N, Output_file_string) ->
    Next_num = (Own_num + 1) rem N,
    Prev_num = (Own_num - 1) rem N,
    Next_id = list_to_atom(integer_to_list(Next_num)),
    receive 
        Token ->
            {ok, Fh} = file:open(Output_file_string, [append]),
            io:fwrite(Fh, "Process ~w received token ~w from process ~w.~n",[Own_num, Token, Prev_num]),
            Next_id ! Token
    end.
```
### Output
input_file
```
10 23
```
To compile and execute
```
erlc 20161003_2.erl
erl -noshell -s 20161003_2 main input_file output_file -s init stop
```
output_file
```
Process 1 received token 23 from process 0.
Process 2 received token 23 from process 1.
Process 3 received token 23 from process 2.
Process 4 received token 23 from process 3.
Process 5 received token 23 from process 4.
Process 6 received token 23 from process 5.
Process 7 received token 23 from process 6.
Process 8 received token 23 from process 7.
Process 9 received token 23 from process 8.
Process 0 received token 23 from process 9.
```

## Problem Statement 2: Merge Sort

### Problem
Perform parallel mergesort using a fixed number of processes.

### Solution

In the `main` process, we read the input file into a list and split the list into parts using two functions `split` and `modify`:

```
 % Read input into a list
    Input_file_string = atom_to_list(Input_file),
    {ok, Data} = file:read_file(Input_file_string), 
    Big_list = [binary_to_integer(X) || X <- string:lexemes(Data, " \t\n")],
    Size = (length(Big_list) div Num_processes) + 1,

    %Split into list of lists and sending them!
    Lol_raw= split(Big_list, Size),
    Diff = Num_processes - length(Lol_raw),
    Lol = modify(Diff, Lol_raw),
```

The `split` function divides the big list into smaller lists, which will be sent to each process.
```
split([],_)->[];
split(L, N) when length(L) < N -> [L];
split(L, N) ->
    {A, B} = lists:split(N, L),
    [A | split(B, N)].
```

The `modify` function appends empty lists to the list of lists in case there are lesser than 8 lists.
```
modify(0, Lol_raw) ->
    Lol_raw;
modify(N, Lol_raw) ->
    modify(N-1, [[]|Lol_raw]).
```

Then, the main process is registered as `main_proc`, other processes are spawned, and the main process calls `receive_stuff` to get back sorted lists from other processes. 

```
register(main_proc , self()),
    spawn_processes(Num_processes, Lol),
    L = [],
    receive_stuff(Num_processes, L, Output_file_string).
```
Each process returns a sorted list:

```
proc(X) ->
    main_proc ! lists:sort(X).
```

The `main` process receives theses lists, and merges them into a big list. It is then written onto the output file:

```
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
```

### Output

input_file

```
10 9 8 7 6 5 4 3 2 1
81	62	79
28	15	40	44	40

```
To compile and execute
```
erlc 20161003_2.erl
erl -noshell -s 20161003_2 main input_file output_file -s init stop
```


output_file
```
1 2 3 4 5 6 7 8 9 10 15 28 40 40 44 62 79 81 
```

______________________________