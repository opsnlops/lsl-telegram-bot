# lsl-telegram-bot
A barebones Telegram bot, written in LSL.

To use this bot you will need, at a minimum, an API key from Telegram. See:

https://core.telegram.org/bots

...for how to get one.

This was mostly a proof of concept I made for myself because I wanted to see if I could do it. Turns out it's not nearly as bad as I'd feared, thanks to LSL's new [JSON parser](http://wiki.secondlife.com/wiki/Json_usage_in_LSL).

There's not a lot here to work with. This is just a framework to play with. There's no a lot of actual bot functionally here, other than being able to request 

Enjoy! Let me know if you do anything cool with it. :)



## Things to Know

This script polls the Telegram API and doesn't work in [webhook mode](https://core.telegram.org/bots/api#setwebhook). There's no technical reason why LSL shouldn't be able to handle the incoming requests from Telegram via [llRequestSecureURL()](http://wiki.secondlife.com/wiki/LlRequestSecureURL), other than Telegram refuses to talk to port tcp/12043. (Boo! Why Telegram, why??)

Since this is just a proof-of-concept I did for myself, I'm not offering any form of tech support. You can ask me if you have a question, but I can't promise I'll have time to answer. (I'm a very very gal!)

Pull requests would be lovely if you find this useful and make it better!



## How to Contact the Author

You can reach me two easy-ish ways:

* Twitter: [@bunnyhalberd](https://twitter.com/bunnyhalberd)
* In-World: [Bunny Halberd](https://my.secondlife.com/bunny.halberd) 