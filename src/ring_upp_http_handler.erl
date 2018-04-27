-module(ring_upp_http_handler).
-export([handle/2, handle_event/3]).

-include_lib("elli/include/elli.hrl").
-behaviour(elli_handler).

handle(Req, _Args) ->
    %% Delegate to our handler function
    handle(Req#req.method, elli_request:path(Req), Req).

handle('GET',[<<"hello">>, <<"world">>], _Req) ->
    %% Reply with a normal response. 'ok' can be used instead of '200'
    %% to signal success.
    {ok, [], <<"Hello World!">>};

handle('POST',[<<"api">>,<<"v1">>,<<"os">>,Os, <<"push">>], Req) ->
	io:format("The req body : ~p",[Req]),
	Event = jsx:decode(elli_request:body(Req)),
	io:format("The req body : ~p",[Event]),
    %% Reply with a normal response. 'ok' can be used instead of '200'
    %% to signal success.
    ok = ring_upp_push_if:push(Event),
    {ok, [], <<"ok">>};

handle('POST',[<<"api">>,<<"v1">>,<<"template">>,Temp, <<"mail">>], Req) ->
    io:format("The req body : ~p",[Req]),
    Event = jsx:decode(elli_request:body(Req)),
    io:format("The req body : ~p",[Event]),
    %% Reply with a normal response. 'ok' can be used instead of '200'
    %% to signal success.
    ok = ring_upp_mail_if:send(Event),
    {ok, [], <<"ok">>};

handle(_, _, _Req) ->
    {404, [], <<"Not Found">>}.

%% @doc: Handle request events, like request completed, exception
%% thrown, client timeout, etc. Must return 'ok'.
handle_event(_Event, _Data, _Args) ->
    ok.