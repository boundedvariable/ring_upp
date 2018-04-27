-module(ring_upp_mail_if).

-export([send/1]).


inform_devops(Type)->
	{ok,Gateway} = application:get_env(zataas,email_gateway),
  	{ok,From} = application:get_env(zataas,email_from),
  	EmailRelayB = list_to_binary(Gateway),
  	EmailFromB = list_to_binary(From),
  	EmailReceiver = <<"shahid.shaik@live.com">>,
  	EmailReceiverList = [<<"shahid.shaik@live.com">>],%application:get_env(support_mails),
  	Data = {<<"text">>, <<"html">>, [
    	            {<<"From">>, EmailFromB},
        	        {<<"To">>, EmailReceiver},
            	    {<<"Subject">>, <<"ZATAAS(Kakfa universal Plug):Alert:",Type/binary>>}],
         	[], <<"Hey...It's an Alert">>},
   	DataB = mimemail:encode(Data),
   	gen_smtp_client:send({EmailFromB, EmailReceiverList, DataB}, [{relay, EmailRelayB}]),
   	ok.