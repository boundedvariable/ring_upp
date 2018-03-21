-module(ring_upp_push).

-export([send_push/1]).

start_workers()->
	{ok,WorkersAmount} = application:get_env(ring_upp,push_workers_amount),
    wpool:start_pool(
        ring_upp_push_pool,
        [{workers, WorkersAmount}, {worker, {ring_upp_push_worker, []}}]
    ).

send_push(Data)->
	ring_upp_push_worker:send_event(Data).