-module(sleepy).
-export([sleep/0]).

sleep() ->
  case erl_ddll:load_driver(".", "sleepy") of
    ok -> ok;
    {error, already_loaded} -> ok;
    _ -> exit({error, could_not_load_driver})
  end,
  Pid=spawn(fun() ->
                Port = open_port({spawn, "sleepy"}, []),
                loop(Port)
            end),
  io:format("call port ~n"),
  Ret=call_port(Pid,{sleep,23}),
  io:format("call port ret ~p ~n", [Ret]),
  ok.


call_port(Pid,Msg) ->
  Pid ! {call, self(), Msg},
  receive
    {Pid, Result} ->
      Result
  end.

loop(Port) ->
  receive
    {call, Caller, Msg} ->
      Port ! {self(), {command, encode(Msg)}},
      receive
        {Port, {data, Data}} ->
          io:format("recv ~n"),
          Caller ! {self(), decode(Data)}
      end,
      loop(Port);
    {'EXIT', Port, Reason} ->
      io:format("xx ~p ~n", [Reason]),
      exit(port_terminated)
  end.

encode({sleep, X}) -> [1, X].

decode([Int]) -> Int.
