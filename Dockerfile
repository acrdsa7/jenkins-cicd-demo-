# Base image with Java 17
FROM eclipse-temurin:17-jdk

# Create working directory inside container
WORKDIR /app

# Copy the built jar from target folder to container
COPY target/*.jar app.jar

# Expose application port
EXPOSE 8080

# Command to run application
ENTRYPOINT ["java", "-jar", "app.jar"]
