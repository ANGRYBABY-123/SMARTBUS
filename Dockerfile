# ─────────────────────────────────────────────────────────────────────────────
# Stage 1 – Build the WAR with Maven
# ─────────────────────────────────────────────────────────────────────────────
FROM maven:3.9.9-eclipse-temurin-21-alpine AS build

WORKDIR /app

# Cache dependency layer separately (only re-downloads when pom.xml changes)
COPY pom.xml .
RUN mvn dependency:go-offline -q

COPY src ./src
RUN mvn package -DskipTests -q

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2 – Run on Tomcat 10.1 / JRE 21
# ─────────────────────────────────────────────────────────────────────────────
FROM tomcat:10.1-jre21

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy app at root context path (serves at / instead of /smartbus)
COPY --from=build /app/target/smartbus.war /usr/local/tomcat/webapps/ROOT.war

# Render injects a PORT env var – update Tomcat connector to match
# Falls back to 8080 when running locally via `docker run`
CMD ["/bin/sh", "-c", \
     "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/g\" \
       /usr/local/tomcat/conf/server.xml && catalina.sh run"]

EXPOSE 8080
