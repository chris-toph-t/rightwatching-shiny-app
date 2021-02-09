FROM openjdk:8-jre

RUN mkdir -p /opt/shinyproxy/
RUN mkdir -p /opt/shinyproxy/logs
RUN mkdir -p /opt/shinyproxy/templates
COPY shinyproxy*.jar /opt/shinyproxy/shinyproxy.jar
COPY application.yml /opt/shinyproxy/application.yml
COPY templates/login.html /opt/shinyproxy/templates/login.html
WORKDIR /opt/shinyproxy/
CMD ["java", "-jar", "/opt/shinyproxy/shinyproxy.jar"]