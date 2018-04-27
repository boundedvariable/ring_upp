-module(ring_upp_push_if).

-export([start/0,
                register_device/4,
                deregister_device/1,
         push/2]).

%-- apns callbacks ---%%
-export([handle_apns_error/2,
         handle_apns_delete_subscription/1]). 

start() ->
    ApnsConectionName = config:get_local_option(ios_apns_connection_name),
    connect_apns(ApnsConectionName),
    GoogleApiKey = string:concat("key=", config:get_local_option(google_api_key)),
    gcm:start(google, GoogleApiKey),
    ok.
 
register_device(Token, Type, User, Resource) ->
  case db_resource:get_token_user(Token) of
      {ok, User} ->
        already_registered;
      {ok, _OtherUser} ->
        fail;
      _ ->
        db_resource:add_to_token_user(User, Resource, Token),
        case db_resource:is_token_exists(User, Token, Type) of
          true ->
            already_registered;
          _ ->
            db_resource:add_to_user_token(User, Token, Type),
            registered
        end
  end.

deregister_device(Token) ->
    case db_resource:get_token_user(Token) of
        {ok, User} ->
            db_resource:delete_token(User, Token),
            deregistered;
        _ ->
            deregistered
    end.

push(User, Data) ->
    case db_resource:get_user_tokens(User) of
        {ok, Tokens} ->
            lists:foreach(fun({Token, Type}) ->
                                  {ok, Resource} = db_resource:get_token_resource(Token),
                                  Badge = db_user:get_incremented_badge(User, Resource),
                                  Token2 = erlang:binary_to_list(Token),
                                  push_to_device(Type, Token2, Data, Badge)
                          end, Tokens);
        _ ->
            ok
    end.

push_to_device(?PUSH_GOOGLE, Token, #{<<"alert_msg">> := Msg} = _Data, Badge) ->
    gcm:push(google, [Token], [{<<"data">>, [{<<"message">>, Msg}, {<<"badge">>, Badge}]}]);
 
push_to_device(?PUSH_APPLE, Token, Data, Badge) ->
    ExpT = utils:get_expiration_time_in_secs(),
    ApnsConection = config:get_local_option(ios_apns_connection_name),
    #{<<"alert_msg">> := Msg} = Data,
    MetaData = maps:without([<<"alert_msg">>, <<"id">>, <<"ack">>], Data),
    apns:send_message(ApnsConection, #apns_msg{
      alert  = Msg ,
      badge  = Badge,
      sound  = "default" ,
      expiry = ExpT,
      device_token = Token,
      extra = [{<<"meta-data">>, MetaData}]
    });

push_to_device(_, _, _, _) ->  ok.


%%------ apns related funtions --------%%
connect_apns(ApnsConectionName) ->
  apns:connect(
        ApnsConectionName,
        fun ?MODULE:handle_apns_error/2,
        fun ?MODULE:handle_apns_delete_subscription/1
      ).

%%------- apns callbacks to handle feedback -------%%
handle_apns_error(_MsgId, Status) ->
  lager:error("APNs Error: ~p", [Status]).

handle_apns_delete_subscription(Feedback) ->
  {_DateTime, Token} = Feedback,
  TokenLower = string:to_lower(Token),
  spawn_link(fun() -> deregister_device(TokenLower) end),
  ok.