FROM eclipse-temurin:21-jre

WORKDIR /app

# Copy JAR file
COPY target/*.jar app.jar

# Environment variables will be passed via docker-compose
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]