@echo off
set JAVA_HOME=$java.path

call jboss-cli.bat --connect --controller=localhost:$jboss.management.http.port --command=:shutdown