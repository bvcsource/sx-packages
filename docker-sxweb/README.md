## WHAT IS THIS?

A ready to use SXWeb Docker container.

## HOW TO USE IT?

TL;DR

   docker run --restart=always -d --name sxweb_db -e MYSQL_ROOT_PASSWORD=testme -e MYSQL_DATABASE=sxweb -e MYSQL_USER=sxweb -e MYSQL_PASSWORD=mypass mysql/mysql-server:5.5

Then start a SXWeb container linked to this MySQL container:

   docker run -p 8443:443 --restart=always -d --name sxweb_frontend --link sxweb_db:sxweb_db skylable/sxweb

Then open https://localhost:8443 to complete the setup.

## DEMO

You can also try out SXWeb demo at https://sxweb-demo.skylable.com

## MORE INFO

Visit http://www.sxdrive.io to learn more about SXDrive.

How this madness started: http://www.skylable.com/blog/2015/10/sxweb-with-2-commands-using-docker

