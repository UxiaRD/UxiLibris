# ── Etapa 1: compilar el jar con Maven ──────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# Descarga dependencias primero (capa cacheada si pom.xml no cambia)
COPY pom.xml .
RUN mvn dependency:go-offline -B -q

# Compila el proyecto
COPY src ./src
RUN mvn package -DskipTests -q

# ── Etapa 2: imagen de producción (solo JRE, más ligera) ────────────────────
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java -Xms64m -Xmx280m -XX:MaxMetaspaceSize=96m -XX:+UseSerialGC -jar app.jar --server.port=${PORT:-8080}"]