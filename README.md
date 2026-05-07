# SmartBus System

Java EE web application for managing bus operations (buses, routes, trips, schedules, users).

## Tech Stack
- **Java 11**, Maven WAR packaging
- **JPA / Hibernate 6** with JPQL queries
- **Servlets 5** (Jakarta EE 9+)
- **JSP + JSTL** views, Bootstrap 5 UI
- **MySQL 8** database
- **HikariCP** connection pool

## Project Structure
```
src/main/java/com/smartbus/
  entity/       – JPA entities (User, Driver, Passenger, Bus, Route, Trip, Schedule, GpsTracking, Notification)
  dao/          – DAO layer with JPQL queries
  servlet/      – HTTP Servlets (CRUD for each entity)
  listener/     – AppContextListener (JPA init/shutdown)
  util/         – JPAUtil (EntityManagerFactory singleton)
src/main/resources/META-INF/persistence.xml
src/main/webapp/
  index.jsp
  WEB-INF/web.xml
  WEB-INF/views/  – JSP pages
database/smartbus.sql
```

## Deployment Steps

### 1. Prerequisites
- JDK 11+
- Maven 3.6+
- MySQL 8 running on localhost:3306
- Apache Tomcat 10.x (Jakarta EE 9 compatible)

### 2. Create the Database
```sql
mysql -u root -p < database/smartbus.sql
```
This creates the `smartbus` database, all tables, and seed data.

### 3. Configure DB Credentials
Edit `src/main/resources/META-INF/persistence.xml` and set:
```xml
<property name="jakarta.persistence.jdbc.url"      value="jdbc:mysql://localhost:3306/smartbus?..."/>
<property name="jakarta.persistence.jdbc.user"     value="YOUR_DB_USER"/>
<property name="jakarta.persistence.jdbc.password" value="YOUR_DB_PASSWORD"/>
```

### 4. Build
```bash
mvn clean package
```
The WAR is generated at `target/smartbus.war`.

### 5. Deploy to Tomcat
Copy `target/smartbus.war` to `$TOMCAT_HOME/webapps/`.

### 6. Access
```
http://localhost:8080/smartbus/
```
Default login: `admin@smartbus.com` / `admin123`

## Default URLs
| Page | URL |
|------|-----|
| Dashboard | `/smartbus/` |
| Users | `/smartbus/users/list` |
| Buses | `/smartbus/buses/list` |
| Routes | `/smartbus/routes/list` |
| Trips | `/smartbus/trips/list` |
| Schedules | `/smartbus/schedules/list` |
