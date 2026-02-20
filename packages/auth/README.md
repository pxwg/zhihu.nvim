# auth

A library to get cookies from firefox or chrome.

## Usage

Get cookies from firefox cookies database:

```lua
local auth = require 'auth.firefox'.Auth()
print(tostring(auth:get_cookies ".zhihu.com"))
-- ******
print(auth.path)
-- /home/wzy/.mozilla/firefox/dl1wxlz0.default/cookies.sqlite
```

Get cookies from firefox/chrome cookies database:

```lua
local auth = require 'auth.chained'.Auth {
  auths = {
    require 'auth.firefox'.Auth(),
    require 'auth.chrome'.Auth()
  }
}
print(tostring(auth:get_cookies ".zhihu.com"))
-- ******
```

Get cookies from chrome cookies database and cache it:

```lua
local auth = require 'auth.cache'.Auth {
  auth = require 'auth.chrome'.Auth()
}
print(tostring(auth:get_cookies ".zhihu.com"))
-- ******
os.remove(auth.path)
-- still work!
print(tostring(auth:get_cookies ".zhihu.com"))
-- ******
```

## Related Projects

- [lua-cookie](https://github.com/mah0x211/lua-cookie): parse cookies string to
  a table
