# ─────────────────────────────────────────────────────────────────────────────
# Stage 1 – Build the WAR with Maven
# ─────────────────────────────────────────────────────────────────────────────
# cache-bust: 2026-05-12b
FROM maven:3.9-eclipse-temurin-21-alpine AS build

WORKDIR /app

# Cache dependency layer separately (only re-downloads when pom.xml changes)
COPY pom.xml .
RUN mvn dependency:go-offline -q

COPY src ./src
RUN mvn package -DskipTests -q

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2 – Run on Tomcat 10.1 / JDK 25
# ─────────────────────────────────────────────────────────────────────────────
FROM tomcat:10.1-jdk21-temurin

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy app at root context path (serves at / instead of /smartbus)
COPY --from=build /app/target/smartbus.war /usr/local/tomcat/webapps/ROOT.war

# Render injects PORT env var – patch HTTP connector to bind 0.0.0.0:$PORT
# Also disable the Tomcat shutdown port (8005) – Render probes it with HTTP HEAD
# requests causing "Invalid shutdown command" spam in the logs
CMD ["/bin/sh", "-c", \
     "PORT=${PORT:-8080} && \
      sed -i \"s|<Connector port=\\\"8080\\\" protocol=\\\"HTTP/1.1\\\"|<Connector port=\\\"${PORT}\\\" address=\\\"0.0.0.0\\\" protocol=\\\"HTTP/1.1\\\"|g\" \
        /usr/local/tomcat/conf/server.xml && \
      sed -i 's/port=\"8005\" shutdown=\"SHUTDOWN\"/port=\"-1\" shutdown=\"SHUTDOWN\"/' \
        /usr/local/tomcat/conf/server.xml && \
      catalina.sh run"]

EXPOSE 8080
