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
- A Railway MySQL service with the `smartbus` schema created
- Render account for the Docker deployment

### 2. Create the Railway database
Run `database/smartbus.sql` against your Railway MySQL database first so the tables exist before the app starts.

### 3. Configure Railway connection values
Copy the Railway MySQL URL from the Railway dashboard and set it as `DB_URL` (or `MYSQL_PUBLIC_URL`). The app can read the full URL directly, so you do not need to split out host, port, and database.

Example format:
```text
mysql://root:********@zephyr.proxy.rlwy.net:51546/railway
```

### 4. Deploy with Render
Use `render.yaml` as the Blueprint. Set the secret environment variables in the Render dashboard, especially `DB_URL` (or `MYSQL_PUBLIC_URL`), `SMTP_USER`, `SMTP_PASS`, and any optional API keys.

### 5. Build
```bash
mvn clean package
```
The WAR is generated at `target/smartbus.war`.

### 6. Access
The Docker image serves the app at the root path, so open:
```
https://<your-service>.onrender.com/
```
Default login: `admin@smartbus.com` / `admin123`

## Default URLs
| Page | URL |
|------|-----|
| Dashboard | `/` |
| Users | `/users/list` |
| Buses | `/buses/list` |
| Routes | `/routes/list` |
| Trips | `/trips/list` |
| Schedules | `/schedules/list` |
