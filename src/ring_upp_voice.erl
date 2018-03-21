-module(ring_upp_voice).

-export([send_push/1]).

start_workers()->
	{ok,WorkersAmount} = application:get_env(ring_upp,voice_workers_amount),
    wpool:start_pool(
        ring_upp_voice_pool,
        [{workers, WorkersAmount}, {worker, {ring_upp_voice_worker, []}}]
    ).

send_voice(Data)->
	ring_upp_voice_worker:send_event(Data).