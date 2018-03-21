-module(ring_upp_mail).

-export([send_push/1]).

start_workers()->
	{ok,WorkersAmount} = application:get_env(ring_upp,mail_workers_amount),
    wpool:start_pool(
        ring_upp_mail_pool,
        [{workers, WorkersAmount}, {worker, {ring_upp_mail_worker, []}}]
    ).

send_mail(Data)->
	ring_upp_mail_worker:send_event(Data).