# Handle

The Handle.Net Registry (HNR) is run by Corporation for National Research Initiatives (CNRI). CNRI is a Multi-Primary Administrator (MPA) of the Global Handle Registry (GHR), authorized by the DONA Foundation to allot prefixes to users of the Handle System. The DONA Foundation is a non-profit organization based in Geneva that has taken over responsibility for the evolution of CNRI's Digital Object (DO) Architecture including outreach around the world. One of the Foundation's responsibilities is to administer and maintain the overall operation of the GHR, a task that was previously performed by CNRI.

## Version

As of 12/1/2023 our currenty Handle version is 9.0.3

## Handle Prefixes at Tufts

* Our production prefix is : 10427
* Our test prefix is : 10427.TEST

10427 appears in our handle resolver URLs.  For example, https://dl.tufts.edu/concern/pdfs/9z903d650, has a handle of http://hdl.handle.net/10427/9Z903D650 which resolves back to the dl URL.  10427 indicates the object is stored at Tufts.

## Cost

* TARC pays $50 a year for the Handle servie, we've fallen behind on payments in the past, they will not take an update configuration if we are behind on payment.

## Important URLs
* https://www.handle.net/prefix_request.html
* https://www.handle.net/download_hnr.html

# Handle Server Setup

## Setup after an IP Change

## Reconfigure the server:

On the handle server you have to re-run the handle server set up as follows:

```
[mkorcy01@handle-prod-01 ~]$ sudo /bin/su - handle
[sudo] password for mkorcy01:
Last login: Wed Nov 15 09:19:47 EST 2023
[handle@handle-prod-01 ~]$ cd /usr/local/handle
[handle@handle-prod-01 ~]$ ls
config  java  logs  scripts  versions
[handle@handle-prod-01 ~]$ cd config
[handle@handle-prod-01 config]$ ls
svr_1
[handle@handle-prod-01 config]$ cd svr_1
[handle@handle-prod-01 svr_1]$ ls
admpriv.bin  bdbje       contactdata.dct  logs         pubkey.bin             sitebndl.zip   txn_id  webapps          webapps-temp
admpub.bin   config.dct  handle.sql       privkey.bin  serverCertificate.pem  siteinfo.json  txns    webapps-storage
[handle@handle-prod-01 svr_1]$ pwd
/usr/local/handle/config/svr_1
[handle@handle-prod-01 svr_1]$ cd ..
[handle@handle-prod-01 config]$ cd ..
[handle@handle-prod-01 ~]$ cd versions/handle-9.0.3/
[handle@handle-prod-01 handle-9.0.3]$ cd bin
[handle@handle-prod-01 bin]$ ls
cpappend.bat               hdl-convert-siteinfo      hdl-dbresolve.bat        hdl-getrootinfo      hdl-keygen.bat                    hdl-qresolverGUI          hdl-setup-server.bat
hdl                        hdl-convert-siteinfo.bat  hdl-dbtool               hdl-getrootinfo.bat  hdl-keyutil                       hdl-qresolverGUI.bat      hdl-splitrecoverylog
hdl-admintool              hdl-convert-values        hdl-dbtool.bat           hdl-getsiteinfo      hdl-keyutil.bat                   hdl-recoverbdbje          hdl-splitrecoverylog.bat
hdl-admintool.bat          hdl-convert-values.bat    hdl-delete               hdl-getsiteinfo.bat  hdl-list                          hdl-recoverbdbje.bat      hdl-splitserver
hdl.bat                    hdl-create                hdl-delete.bat           hdl-home-na          hdl-list.bat                      hdl-recoverjdb            hdl-splitserver.bat
hdl-bdbje-util             hdl-create.bat            hdl-docheckpoint         hdl-home-na.bat      hdl-migrate-storage-to-bdbje      hdl-recoverjdb.bat        hdl-testtool
hdl-bdbje-util.bat         hdl-dblist                hdl-docheckpoint.bat     hdl-java             hdl-migrate-storage-to-bdbje.bat  hdl-server                hdl-testtool.bat
hdl-convert-key            hdl-dblist.bat            hdl-dumpfromprimary      hdl-java.bat         hdl-oldadmintool                  hdl-server.bat            hdl-trace
hdl-convert-key.bat        hdl-dbremove              hdl-dumpfromprimary.bat  hdl-jython           hdl-oldadmintool.bat              hdl-server-perf-test      hdl-trace.bat
hdl-convert-localinfo      hdl-dbremove.bat          hdl-genericbatch         hdl-jython.bat       hdl-qresolver                     hdl-server-perf-test.bat
hdl-convert-localinfo.bat  hdl-dbresolve             hdl-genericbatch.bat     hdl-keygen           hdl-qresolver.bat                 hdl-setup-server
[handle@handle-prod-01 bin]$ ./hdl-setup-server /usr/local/handle/config/svr_1

To configure your new Handle server, please answer
the questions which follow; default answers, shown in
[square brackets] when available, can be chosen by
pressing Enter.


Will this be a "primary" server (ie, not a mirror of another server)?(y/n) [y]: y

Will this be a dual-stack server (accessible on both IPv6 and IPv4)?(y/n) [n]: n

Through what network-accessible IP address should clients connect to this server? [10.246.108.254]: 10.250.108.107

If different, enter the IP address to which the server should bind. [10.250.108.107]:

Enter the (TCP/UDP) port number this server will listen to [2641]:

What port number will the HTTP interface be listening to? [8000]:

Would you like to log all accesses to this server?(y/n) [y]: y

Please indicate whether log files should be automatically
rotated, and if so, how often.

("N" (Never), "M" (Monthly), "W" (Weekly), or "D" (Daily))? [Monthly] : D

Each handle site has a version/serial number assigned
to it.  This is so that a client can tell if a particular
site's configuration has changed since the last time it
accessed a server in the site.  Every time you modify a site
(by changing an IP address, port, or adding a server, etc),
you should increment the version/serial number for that site.

Enter the version/serial number of this site [1]: 23

Please enter a short description of this server/site: Tufts Digital Repository Handle Server

Please enter the name of your organization: Tufts University

Please enter the name of a contact person
for Tufts University (optional) [(none)]: Mike Korcynski

Please enter the telephone number of Mike Korcynski or of Tufts University (optional) [(none)]: 617-627-4957

Please enter the email address of Mike Korcynski or of Tufts University: dlsystems@elist.tufts.edu

The handle server can communicate via UDP and/or TCP sockets.
Since UDP messages are blocked by many network firewalls, you may
want to disable UDP services if you are behind such a firewall.

  Do you need to disable UDP services?(y/n) [n]: y

Server keys already exist, do you want to create new ones? (y/n) [n]:

Administrator keys already exist, do you want to create new ones? (y/n) [n]:
Generating site info record...

Your server already has a webapps directory for Java servlets.
This Handle software distribution comes with an admin.war servlet
which provides a browser-based admin tool.  This admin.war can
be copied into your server which will replace any existing
admin.war.  This is recommended unless you believe your existing
admin.war to be newer.

  Would you like to copy this admin.war into your server?(y/n) [y]: n

-------------------------------------------------------

You have finished configuring your (primary) Handle service.

This service now needs to be registered with your prefix
administrator.  Organizations credentialed by DONA to
register prefixes are listed at the dona.net website.

If your prefix administrator is CNRI, go to
http://hdl.handle.net/20.1000/111 to register to
become a resolution service provider and then upload
your newly created sitebndl.zip file. Please read the
instructions on this page carefully. When the handle
administrator receives your file, a prefix will be
created and you will receive notification via email.

Please send all questions to your prefix administrator,
if CNRI at hdladmin@cnri.reston.va.us.
```

## After running setup
* go to cnri website and upload new sitebndl.zip created by the setup process
* start services locally

## Testing handle

On the MIRA server, which is the handle client machine.
### Create a handle

Using sample.txt with following format:
```
[rubyadm@tdrmira-prod-02 bin]$ cat sample.txt
AUTHENTICATE PUBKEY:300:0.NA/10427
/usr/local/samvera/handle_keys/prod/admpriv.bin

CREATE 10427/nov272023test
2 URL 86400 1110 UTF8 https://it.tufts.edu
6 EMAIL 86400 1110 UTF8 archives@tufts.edu
100 HS_ADMIN 86400 1110 ADMIN
300:111111111111:0.NA/10427
```

```
cd /usr/local/samvera/handle_software/handle-9.3.0/bin
./hdl-genericbatch ./sample.txt -verbose  
```
Handle should get created successfully.

### Trace a Handle

Even if you can't create a handle you should verify you can read to determin if its a read or writing issue.  If there is a problem with reading a handle, this should help you debug where it is blocked.

```
cd /usr/local/samvera/handle_software/handle-9.3.0/bin
./hdl-trace 10427/1
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to [2a09:bd00:ffc9:1:100:0:0:0]:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to [2001:638:60f:e2f0::30:197]:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to [2001:550:100:6::4]:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to [2602:80d:300c::15:153]:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to [2001:638:60f:e2f0::30:197]:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to [2a09:bd00:ffc9:1:100:0:0:0]:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to [2602:80d:300c::15:153]:2641
  sending HDL-TCP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to [2a09:bd00:ffc9:1:100:0:0:0]:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to [2001:550:100:6::4]:2641
  sending HDL-TCP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to [2001:638:60f:e2f0::30:197]:2641
  sending HDL-TCP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to [2602:80d:300c::15:153]:2641
  sending HDL-TCP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to [2001:550:100:6::4]:2641
  sending HDL-TCP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to [2a09:bd00:ffc9:1:100:0:0:0]:2641
  sending HDL-TCP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to [2001:638:60f:e2f0::30:197]:2641
  sending HDL-TCP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to [2001:550:100:6::4]:2641
  sending HDL-TCP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to [2602:80d:300c::15:153]:2641
  sending HDL-HTTP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to [2001:638:60f:e2f0::30:197]:8000
  sending HDL-HTTP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to [2a09:bd00:ffc9:1:100:0:0:0]:8000
  sending HDL-HTTP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to [2602:80d:300c::15:153]:8000
  sending HDL-HTTP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to [2001:550:100:6::4]:8000
  sending HDL-HTTP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to [2a09:bd00:ffc9:1:100:0:0:0]:8000
  sending HDL-HTTP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to [2001:638:60f:e2f0::30:197]:8000
  sending HDL-HTTP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to [2001:550:100:6::4]:8000
  sending HDL-HTTP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to [2602:80d:300c::15:153]:8000
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 38.100.138.131:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 38.100.138.131:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 38.100.138.131:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 38.100.138.131:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 38.100.138.131:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 38.100.138.131:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 132.151.1.179:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 132.151.15.153:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 132.151.1.179:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 132.151.15.153:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 132.151.15.153:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 132.151.1.179:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 47.90.103.77:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 132.151.1.179:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 132.151.1.179:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 47.90.103.77:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 132.151.1.179:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 47.90.103.77:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 134.76.10.100:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 218.58.81.51:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 134.76.10.100:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 218.58.81.51:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 134.76.10.100:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 218.58.81.51:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 212.193.120.1:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 132.151.1.179:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 212.193.120.1:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 132.151.1.179:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 212.193.120.1:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 132.151.1.179:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 132.151.15.153:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 132.151.15.153:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 134.76.30.197:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 132.151.15.153:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 134.76.30.197:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 134.76.30.197:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 156.106.193.155:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 156.106.193.155:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 132.151.1.179:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 156.106.193.155:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 132.151.1.179:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 134.76.30.197:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 132.151.1.179:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 134.76.30.197:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 134.76.30.197:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 156.106.193.155:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 156.106.193.155:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 113.209.196.34:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 156.106.193.155:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 113.209.196.34:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 113.209.196.34:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 134.76.10.100:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 134.76.10.100:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 47.90.103.77:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 134.76.10.100:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 47.90.103.77:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 47.90.103.77:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 212.193.120.1:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 212.193.120.1:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 218.58.81.51:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 212.193.120.1:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 218.58.81.51:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 218.58.81.51:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 113.209.196.34:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 113.209.196.34:2641
  sending HDL-TCP request (version=2.10; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.NA/10427 [HS_SITE, HS_SITE.6, HS_SERV, HS_NAMESPACE, ] [ ]) to 38.100.138.131:2641
  sending HDL-UDP request (version=2.10; oc=1; rc=0; snId=0 crt caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 0.0/0.0 [ ] [ ]) to 113.209.196.34:2641
    received HDL-TCP response: version=2.10; oc=1; rc=1; snId=0 caCrt auth noAuth expires:Thu Nov 30 00:06:13 EST 2023 0.NA/10427
    index=4 type=HS_SITE rwr- "0001020B0018800200000000000000010000000464657363000000115444522048616E646C652053657276657200000001000000010000000000000000000000008240D42C000001210000000B5253415F5055425F4B45590000000000030100010000010100B37727669E55B479606C04A80DAA06C55B46FE7F8962051A4A46E255724681550C679E5039B7B9C3FD6076B24CAC535A3CC8C1C79EAC4D8021B165D07C23EA6DF6AB04F808BC36E04F2D4C44B7C74CE5BC184D8AF5221AC951F8829932F24D59F4900B536E579082C6753B84500DB51F25E5F68EE73B9DAACCA194BE0077EAAFBFFEAEDACA7B8775FA1B0031F8F3173C50D133698441B00F6604504FAE32C64773387683A99C474485C65C20ADBCF6AAFB01DD49C44D91F82ECC79B57EC7D8DC122227560C8813EDBD8222DE9099D1D63E6AE361F4DEA08BB7B1EAA8C436F03F94708451C71476ABEF92AC6CBDA753F1C22CACA998F21ADA8277F9CD26E225710000000000000002030100000A51030200001F40"

  sending HDL-TCP request (version=2.11; oc=1; rc=0; snId=0 caCrt noAuth expires:Thu Nov 30 00:05:39 EST 2023 10427/1 [ ] [ ]) to 130.64.212.44:2641
    received HDL-TCP response: version=2.11; oc=1; rc=1; snId=0 caCrt auth noAuth expires:Thu Nov 30 00:06:13 EST 2023 10427/1
    index=3 type=URL rwr- "https://dl.tufts.edu/concern/images/7p88cq92h"
    index=4 type=EMAIL rwr- "archives@tufts.edu"
    index=100 type=HS_ADMIN rwr- "0FF30000000A302E4E412F31303432370000012C0000"


Got Response:
version=2.11; oc=1; rc=1; snId=0 caCrt auth noAuth expires:Thu Nov 30 00:06:13 EST 2023 10427/1
    index=3 type=URL rwr- "https://dl.tufts.edu/concern/images/7p88cq92h"
    index=4 type=EMAIL rwr- "archives@tufts.edu"
    index=100 type=HS_ADMIN rwr- "0FF30000000A302E4E412F31303432370000012C0000"    
```