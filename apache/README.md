Apache
===========

Check for things like `/phpmyadmin`.

If that is accessible, set it to only be viewed from `localhost` in `.htaccess`

If your pages `include()` files, try and move them to files to files outside of the public directory. Like `/var/www`, just up a directory from  `/var/www/html`.

Check Version
------

```
apache2 -v
```

If you are running Apache 2.4, you can use this syntax in `.htaccess` to allow a folder only to be accessed by the apache user (www-data) and not world readable [rw-r-----

# protect .htaccess
<Files ~ "^.*\.([Hh][Tt][Aa])">
	Order allow,deny
	Deny from all
	Satisfy all
</Files>

Protect .htpasswd

# protect .htpasswd
<Files ~ "^.*\.([Hh][Tt][Pp])">
	Order allow,deny
	Deny from all
	Satisfy all
</Files>

Protect both files

# protect .htaccess and .htpasswd
<Files ~ "^.*\.([Hh][Tt])">
	Order allow,deny
	Deny from all
	Satisfy all
</Files>

Protect all files beginning with a dot

# protect all dot files
<Files ~ "^.*\.">
	Order allow,deny
	Deny from all
	Satisfy all
</Files>

Protect with mod_alias

Here is a simple .htaccess snippet that will protect all files that begin with a dot:

# protect files beginning with .
RedirectMatch 403 /\.(.*)

This will protect all .htaccess files, .htpasswd files, and any other file that begins with a literal dot. You could refine the technique a bit by requiring that the dot be proceeded by the letters “ht”:

# protect files beginning with .ht
RedirectMatch 403 /\.ht(.*)

This is more specific, so better if you are concerned about false positives.
Protect with mod_rewrite

Here is the same basic technique as before, but using Apache's mod_rewrite and RewriteRule:

# protect files beginning with .
RewriteRule /\.(.*) - [NC,F]


