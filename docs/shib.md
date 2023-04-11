# Setting up mod_shib and shibboleth service

## Getting Started

* Review the current [ESCP (formerly ESAI) documentation](https://tuftswork.atlassian.net/wiki/spaces/EnterpriseSystems/pages/89463785/Setting+Up+An+SP+for+Shibboleth) for setting up mod_shib
* Review the [Known Issues](#known-issues) because they're a bit confusing

## Known Issues
* Shibboleth mirrors wasn't working properly. [INC1038238]
  * Work around:
     - copy `/etc/yum.repos.d/shibboleth.repo` from an existing machine. Also, puppet will actively try to overwrite this so you have to run the yum install pretty quickly after doing the copying, may be best to have a local copy on hand.
* `yum install shibboleth` doesn't work
  * see `Shibboleth mirrors wasn't working properly.`
  * Error is:
  
    ```    
    Cannot find a valid baseurl for repo: shibboleth       
    
    ```   
* Another possible error we saw on RHEL8 is:
Status code: 404 for https://shibboleth.net/downloads/service-provider/RPMS/RPM-GPG-KEY-cantor (IP: 3.213.250.186)

* With the above fixed at least in RHEL7, I hit a cert issue:

```
Could not retrieve mirrorlist https://shibboleth.net/cgi-bin/mirrorlist.cgi/CentOS_7 error was
14: curl#60 - "The certificate issuer's certificate has expired. Check your system date and time."
```

* The same exact repo file on wikis-stage-01 worked fine. I set ssl verify to 0 to temporarily get this working, which got me a bit further:

```
Retrieving key from https://shibboleth.net/downloads/service-provider/RPMS/repomd.xml.key
Importing GPG key 0x7D0A1B3D:
 Userid     : "security:shibboleth OBS Project <security:shibboleth@build.opensuse.org>"
 Fingerprint: 6519 b5db 7c1c 8340 a954 ed00 73c9 3745 7d0a 1b3d
 From       : https://shibboleth.net/downloads/service-provider/RPMS/repomd.xml.key
Is this ok [y/N]: y
Retrieving key from https://shibboleth.net/downloads/service-provider/RPMS/RPM-GPG-KEY-cantor

GPG key retrieval failed: [Errno 14] HTTPS Error 404 - Not Found
```

* Solution here was:
    * I changed the url in the repo file to `https://shibboleth.net/downloads/service-provider/RPMS/cantor.repomd.xml.key` 
   

## Links
* [ESCP (formerly ESAI) documentation](https://tuftswork.atlassian.net/wiki/spaces/EnterpriseSystems/pages/89463785/Setting+Up+An+SP+for+Shibboleth)
* [DCE Cookbook on Shib and Hyrax (for reference, we uses some of this)](https://curationexperts.github.io/recipes/authentication/shibboleth.html)
* [Shib apache docs](https://shibboleth.atlassian.net/wiki/spaces/SP3/pages/2065335062/Apache)

## Notes

* You should be able to look in gitlab.it.tufts.edu puppet repo and see where shib is being used but its a bit unclear at the moment because of the known issues.

* Have not yet set up on RHEL8 hosts which should be easier.

* You can have `mod_shib` completely up and running and not have it interact with the running TDR apps at all so the pieces can be set up independently.

==
## Installation
1. Install mod_shib on your web server using your package manager:
`$ yum install shibboleth`


## Configuration
1. cd `/etc/shibboleth`
1. Get the IdP Metadata, on dev hosts you want shib stage on prod you want shib prod:

Prod:

```
wget https://shib-idp.tufts.edu/idp/shibboleth
mv shibboleth shib-idp-prod-idp-metadata.xml
```

Stage:

```
wget https://shib-idp-stage.uit.tufts.edu/idp/shibboleth
mv shibboleth shib-idp-stage-idp-metadata.xml
```

2. Run keygen.sh generate a new SP Key

2. Open the mod_shib configuration file for editing:
$ vi /etc/shibboleth/shibboleth2.xml

3. Configure the entityID of your SP, below is an example you should use the URL to shibboelth on your actual host and url:
   ```
    <ApplicationDefaults entityID="https://dev-dl.lib.tufts.edu/shibboleth"
   ```
3. Configure the SSO endpoint URL of your identity provider (IdP) depending on dev or prod:
   ```
 <SSO entityID="https://shib-idp-stage.uit.tufts.edu/idp/shibboleth"
                 discoveryProtocol="SAMLDS" discoveryURL="https://ds.example.org/DS/WAYF">
              SAML2
            </SSO>
            
            https://shib-idp.tufts.edu/idp/shibboleth
   ```
4. Configure the metadata provider for your IdP, this is the file you downloaded above:
   ```
        <MetadataProvider type="XML" path="shib-idp-stage-idp-metadata.xml"/>
   ```
5. Save and close the file.

6. Open `attribute-map.xml`
7. Set the attributes you want in the application, for TDL we used:

```
  <Attribute name="urn:oid:0.9.2342.19200300.100.1.1" id="uid"/>
    <Attribute name="urn:oid:0.9.2342.19200300.100.1.3" id="mail"/>
    <Attribute name="urn:oid:2.5.4.4" id="surname"/>
    <Attribute name="urn:oid:2.5.4.42" id="givenName"/>
    <Attribute name="urn:oid:2.16.840.1.113730.3.1.241" id="displayName"/>
```


8. mod_shib config is in `/etc/httpd/conf.d/shib.conf`, these are the changes I made in the TDL config:

```
# https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApacheConfig

# RPM installations on platforms with a conf.d directory will
# result in this file being copied into that directory for you
# and preserved across upgrades.

# For non-RPM installs, you should copy the relevant contents of
# this file to a configuration location you control.

#
# Load the Shibboleth module.
#
LoadModule mod_shib /usr/lib64/shibboleth/mod_shib_24.so

#
# Turn this on to support "require valid-user" rules from other
# mod_authn_* modules, and use "require shib-session" for anonymous
# session-based authorization in mod_shib.
#
ShibCompatValidUser Off

#
# Ensures handler will be accessible.
#
<Location /Shibboleth.sso>
  AuthType None
  Require all granted
</Location>

#
# Used for example style sheet in error templates.
#
<IfModule mod_alias.c>
  <Location /shibboleth-sp>
    AuthType None
    Require all granted
  </Location>
  Alias /shibboleth-sp/main.css /usr/share/shibboleth/main.css
</IfModule>

#
# Configure the module for content.
#
# You MUST enable AuthType shibboleth for the module to process
# any requests, and there MUST be a require command as well. To
# enable Shibboleth but not specify any session/access requirements
# use "require shibboleth".
#


<Location /users/auth/shibboleth/callback>
  AuthType shibboleth
  ShibRequestSetting requireSession 1
  Require shibboleth
  Require valid-user
</Location>

<Location /secure>
  AuthType shibboleth
  ShibRequestSetting requireSession 1
  require shib-session
</Location>

```

	9. Enable service /bin/systemctl enable shibd.service

10. Start service: systemctl restart shibd.service

11. Restart apache httpd: systemctl restart httpd


8. Work with ESCP on making sure they're releasing these attributes to the SP, and that they've added the SP metadata to the IdP, here is a sample request:

```
Hi,
 
I’m trying to set up shibboleth for TDL, right now I’m working on getting dev-dl (https://dev-dl.lib.tufts.edu) set up with stage shib. 
 
I followed this set of directions:
https://wikis.uit.tufts.edu/confluence/display/EnterpriseSystems/Setting+Up+An+SP+for+Shibboleth
 
Here’s my metadata:
https://dev-dl.lib.tufts.edu/Shibboleth.sso/Metadata
 
I'd like these attributes to be released:
<Attribute name="urn:oid:0.9.2342.19200300.100.1.1" id="uid"/>
<Attribute name="urn:oid:0.9.2342.19200300.100.1.3" id="mail"/>
<Attribute name="urn:oid:2.5.4.4" id="sn"/>
<Attribute name="urn:oid:2.5.4.42" id="givenName"/>
<Attribute name="urn:oid:2.16.840.1.113730.3.1.241" id="displayName"/>
 
I haven’t configured the application yet.
 
Thanks,
Mike
 
```

## Troubleshooting RHEL8
* On RHEL8 for the version of passenger we're runnign in MIRA we had to add a location directive to the virtualhost from MIRA to disable Passenger:

```
<Location  /Shibboleth.sso>
  PassengerEnabled off
</Location>
```

## Operational Notes

* service shibd restart -- restart service aftter configuration changes
* systemctl restart shibd.service - depending on RHEL version
* /bin/systemctl enable shibd.service - enable the service so it starts at boot
* these configs aren't in puppet, EI feels they're easy enough to reproduce but we should think about controlling these ourselves in Ansible if EI doesn't want to.


## Usage
Once mod_shib is installed and configured, you can use it to authenticate users via SAML-based SSO.

## Repo Files

* RHEL 7

```
[shibboleth]
name=Shibboleth
type=rpm-md
mirrorlist=https://shibboleth.net/cgi-bin/mirrorlist.cgi/CentOS_7
gpgcheck=1
gpgkey=https://shibboleth.net/downloads/service-provider/RPMS/repomd.xml.key
        https://shibboleth.net/downloads/service-provider/RPMS/cantor.repomd.xml.key
enabled=1

```

* RHEL8

```
[Shibboleth]
async = 1
gpgcheck = 1
gpgkey = https://shibboleth.net/downloads/service-provider/RPMS/repomd.xml.key
         https://shibboleth.net/downloads/service-provider/RPMS/cantor.repomd.xml.key
mirrorlist = https://shibboleth.net/cgi-bin/mirrorlist.cgi/CentOS_8
name = Shibboleth YUM repo
```