//
// LSL Telegram Bot
//
// Written by Bunny Halberd!
//
//
//  This is just a simple bot that I wrote to see if I could do it. It
//  turns out that, yeah, I can! Neat! :)
//
//  You need to get an API Token from Telegram before this will work. I
//  removed mine from my source because it doesn't belong in here, duh.
//
// December, 2015
//



// Telegram Endpoint
string apiUrl = "https://api.telegram.org";
string apiToken = "XXXXXXXXXXXXXXXXX";


// Telegram ID of my owner
integer ownerId = 0000;
integer ownerGroup = -0000;

key getMeRequestId = NULL_KEY;
key getUpdatesRequestId = NULL_KEY;
key sendMessageRequestId = NULL_KEY;

string botName = "";
string botUserName = "";
integer botId = -1;


/*
    Telegram works by message offsets. Keep track of the higest update_id
    we've seen, so we can tell Telegram which ones we've processed aready.
*/
integer higestUpdateIdSeen = -1;

/**
    Sends a message to Telegram and and returns the request ID of the message
    as a parameter.
*/
key sendJsonToTelegram(string method, list parameters)
{
    string outgoingUrl = apiUrl + "/bot" + apiToken + "/" + method;
    debug("Calling: " + outgoingUrl);
    
    string json = "";
    
    if(llGetListLength(parameters) > 0)
    {
        json = llList2Json(JSON_OBJECT, parameters);
        debug("encoded json: " + json);
    }
    
    key requestId = llHTTPRequest(outgoingUrl, [HTTP_METHOD, "POST",
                                                HTTP_MIMETYPE, "Content-Type: application/json",
                                                HTTP_BODY_MAXLENGTH, 16384],
                                                json);
    debug("Outgoing requestId: " + (string)requestId);
    
    return requestId;
         
}

getMe()
{
    getMeRequestId = sendJsonToTelegram("getMe", []);
}

getUpdates()
{
    getUpdatesRequestId = sendJsonToTelegram("getUpdates", ["limit", 10, "offset", (higestUpdateIdSeen + 1)]);
}

sendMessageToTelegram(integer chatId, string message)
{ 
    sendMessageRequestId = sendJsonToTelegram("sendMessage", ["chat_id", chatId, "text", message]); 
}





debug(string message)
{
    //llOwnerSay(message);
}

error(string message)
{
    llOwnerSay("ERR: " + message);   
}


parseGetMeReponse(string json)
{
    debug("parsing getMe response");    

    //
    // Sample response from Telegram:
    //
    
    /*
        {
          "ok": true,
          "result": {
            "id": 130140000,
            "first_name": "Cuddles",
            "username": "SomeBot"
          }
        }
    */


    if( JSON_TRUE == llJsonGetValue(json, ["ok"]) )
    {
        debug("message is okay!");
        
        string result = llJsonGetValue(json, ["result"]);
        
        botName = llJsonGetValue(result, ["first_name"]);
        botId = (integer)llJsonGetValue(result, ["id"]);
        botUserName = llJsonGetValue(result, ["user_name"]); 
        
        llSay(0, "My name is " + botName + "!");
        llSay(0, "My user ID is " + (string)botId + "."); 
        
        llSetText(botName + "\n" + (string)botId, <1,1,1>, 1.0); 
    }      
    else
    {
        error("ok wasn't true on a getMe request");
        error("message: " + json);
    } 
}

parseSendMessageResponse(string json)
{
    //
    // This is a sample message:
    //

    /*
        {
          "ok": true,
          "result": {
            "message_id": 23,
            "from": {
              "id": 130142058,
              "first_name": "Cuddles",
              "username": "SomeBot"
            },
            "chat": {
              "id": 000000000000000,
              "first_name": "Bunny",
              "last_name": "Mickley",
              "username": "bunnyhalberd",
              "type": "private"
            },
            "date": 1449443372,
            "text": "Bunny Mickley touched me."
           }
        }
    */
    
    if( JSON_TRUE == llJsonGetValue(json, ["ok"]) )
    {
        debug("message was sent okay!");
        
        string result = llJsonGetValue(json, ["result"]);
        integer messageId = (integer)llJsonGetValue(result, ["message_id"]);
        
        string chat = llJsonGetValue(result, ["chat"]);
        integer targetId = (integer)llJsonGetValue(chat, ["id"]);
        string targetUserName = llJsonGetValue(chat, ["username"]);
        
        string messageText = llJsonGetValue(result, ["text"]);
        
        debug("message id was " + (string)messageId + " sent to " + targetUserName + " ("+ (string)targetId + "): " + messageText); 
    }      
    else
    {
        error("ok wasn't true on a sendMessage request");
        error("message: " + json);
    } 
}



parseUpdateResponse(string json)
{
    //
    // This is a sample message with two updates in it:
    //
    
    /*
        {
          "ok": true,
          "result": [
            {
              "update_id": 631562246,
              "message": {
                "message_id": 3,
                "from": {
                  "id": 000000000000000,
                  "first_name": "Bunny",
                  "last_name": "Mickley",
                  "username": "bunnyhalberd"
                },
                "chat": {
                  "id": 000000000000000,
                  "first_name": "Bunny",
                  "last_name": "Mickley",
                  "username": "bunnyhalberd",
                  "type": "private"
                },
                "date": 1449436190,
                "text": "hi"
              }
            },
            {
              "update_id": 631562247,
              "message": {
                "message_id": 7,
                "from": {
                  "id": 000000000000000,
                  "first_name": "Bunny",
                  "last_name": "Mickley",
                  "username": "bunnyhalberd"
                },
                "chat": {
                  "id": 000000000000000,
                  "first_name": "Bunny",
                  "last_name": "Mickley",
                  "username": "bunnyhalberd",
                  "type": "private"
                },
                "date": 1449437488,
                "text": "hi"
              }
            }
          ]
        }
    */

    if( JSON_TRUE == llJsonGetValue(json, ["ok"]) )
    {
        debug("getUpdate returned ok data, starting to parse...");
        string result = llJsonGetValue(json, ["result"]);
        
        list updates = llJson2List(result);
        integer numberOfUpdates = llGetListLength(updates);
        debug("found " + (string)numberOfUpdates + " updates");
        
        integer i = 0;
        for(i = 0; i < numberOfUpdates; i++)
        {
            string updateJson = llList2String(updates, i);
            debug(updateJson);
            
            integer updateId = (integer)llJsonGetValue(updateJson, ["update_id"]);
       
            string messageJson = llJsonGetValue(updateJson, ["message"]);  
            string messageText = llJsonGetValue(messageJson, ["text"]);
            integer messageId = (integer)llJsonGetValue(messageJson, ["message_id"]);
            
            string chatJson = llJsonGetValue(messageJson, ["chat"]);
            integer chatId = (integer)llJsonGetValue(chatJson, ["id"]);
            string chatType = llJsonGetValue(chatJson, ["type"]);
            
            // If this is a group message, get the group title, too
            string chatTitle = "(DM)";
            if( "group" == chatType )
            {
                chatTitle = llJsonGetValue(chatJson, ["title"]);
            }
            
            string fromJson = llJsonGetValue(messageJson, ["from"]);
            integer fromId = (integer)llJsonGetValue(fromJson, ["id"]);
            string fromUserName = llJsonGetValue(fromJson, ["username"]);
            string fromFirstName = llJsonGetValue(fromJson, ["first_name"]);
            string fromLastName = llJsonGetValue(fromJson, ["last_name"]);
            
            string prettyName = fromFirstName;
            if( fromLastName != JSON_INVALID ) prettyName = prettyName + " " + fromLastName;
            
            
            
            // If this was a status request, get what the user requested
            if(llSubStringIndex(messageText, "/status") != -1)
            {
                sendMessageToTelegram(chatId, getStatus());
            }
            else
            { 
                // Otherwise, just say the message out loud!
                llSay(0, "[" + chatTitle + "] <" + prettyName + "> " + messageText);
            }
            

            
            // If this is the highest message ID we've seen, update the flag
            // in the script.
            if( updateId > higestUpdateIdSeen )
            {
                higestUpdateIdSeen = updateId;
                debug("new updateId high water mark: " + (string)higestUpdateIdSeen);
            } 
        }
    }      
    else
    {
        error("ok wasn't true on a getUpdate request");
        error("message: " + json);
    } 
}


//
// Get Region Status
//
//  Returns some really basic information on the health of a region. This
//  is just an example of things a bot can do!
//
string getStatus()
{
    string status = "";
    
    status += "Region Name: " + llGetRegionName() + "\n";
    status += "Sim Name: " + llGetSimulatorHostname() + "\n";
    status += "Time Dilation: " + (string)llGetRegionTimeDilation() + "\n";
    status += "FPS: " + (string)llGetRegionFPS() + "\n";
    status += "Number AVs: " + (string)llGetRegionAgentCount();
    
    return status;
}


default
{

    state_entry()
    {
        getMe();
    
        sendMessageToTelegram(ownerId, llGetObjectName() + " started up.");  
        
        // Relay messages on channel 5
        llListen(5, "", NULL_KEY, "");
        
        llSetTimerEvent(5.0);
    }

    listen(integer channel, string name, key id, string message)
    {
        if(channel == 5)
        {
            sendMessageToTelegram(ownerGroup, llGetDisplayName(id) + ": " + message);
            llSay(0, llGetDisplayName(id) + ": " + message);
        }
    }
  
    touch_start(integer total_number)
    {
        sendMessageToTelegram(ownerId, llGetDisplayName(llDetectedKey(0)) + " touched me.");
    }
    
    timer()
    {  
        getUpdates();
    }
    
    http_response(key requestId, integer status, list metadata, string body)
    {
        //debug("starting to decode a response - id: " + (string)requestId + ", status: " + (string)status + ", body: " + body);
        
        if(requestId == getMeRequestId)
        {
            debug("request was a getMe response");
            parseGetMeReponse(body);   
        }
        else if(requestId == sendMessageRequestId)
        {
            debug("request was a sendMessageRequestId response");
            parseSendMessageResponse(body);   
        }
        else if(requestId == getUpdatesRequestId)
        {
            debug("request was a getUpdatesRequestId response");
            parseUpdateResponse(body);   
        }
        else
        {
            error("Received a requestID I was not expecting in http_response()...?");
        }
    }

}