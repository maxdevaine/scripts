-- history list of users with last login date (this is history, so a user may not exist)
select username, DATE_FORMAT(MAX(authdate), '%Y-%m-%d-%h%i') AS authdate,id
   from radpostauth
     group by username
     order by MAX(radpostauth.authdate) DESC

-- list users with IP address, creation date
select userinfo.username,userinfo.creationdate,userinfo.updateby,radreply.value
   from userinfo
     left join radreply on userinfo.username = radreply.username;

-- list users with IP address, creation date and group membership
select userinfo.username, radusergroup.groupname, userinfo.creationdate, userinfo.updateby, radreply.value
  from userinfo 
    left join radreply on userinfo.username = radreply.username
    left join radusergroup on userinfo.username = radusergroup.username

-- list last login of current users + ip address, creation date, group membership etc. (very slow)
select userinfo.username, radusergroup.groupname, userinfo.creationdate, userinfo.updateby, radreply.value, DATE_FORMAT(MAX(radpostauth.authdate), '%Y-%m-%d-%h%i') AS radpostauth.authdate
  from userinfo
    left join radreply on userinfo.username = radreply.username
    left join radusergroup on userinfo.username = radusergroup.username 
    left join radpostauth on userinfo.username = radpostauth.username
   
-- last 10 login dates for user
SELECT * FROM `radacct` WHERE username = 'user' order by acctstarttime desc limit 10;

-- last login date for all specific users with same prefix
SELECT username,acctstarttime FROM 
(
 SELECT * FROM `radacct`
 WHERE username like 'userxy%'
 ORDER BY acctstarttime desc
) t1
GROUP BY username desc
;
