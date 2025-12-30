#!/usr/bin/env -S sqlite3 -batch -init
-- $ /the/path/of/firefox.sql ~/.mozilla/firefox/*.default/cookies.sqlite .quit
-- d_c0|************************************|**********
-- z_c0|*|*:*|**:**********|*:z_c0|**:********************************************************************************************|****************************************************************
SELECT
  name,
  value
FROM
  moz_cookies
WHERE
  host = '.zhihu.com'
  AND name = 'd_c0'
  OR name = 'z_c0';
