SELECT
  name,
  value
FROM
  moz_cookies
WHERE
  host = '.zhihu.com'
  AND name = 'd_c0'
  OR name = 'z_c0';
