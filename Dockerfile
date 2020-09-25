FROM tomcat:9.0

COPY target/jpetstore.war /usr/local/tomcat/webapps/ROOT.war