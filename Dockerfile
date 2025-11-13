# Use an official OpenJDK runtime as a parent image
FROM eclipse-temurin:21-jdk

# Set working directory
WORKDIR /app

# Copy the jar built by Maven
COPY target/myapp-1.0-SNAPSHOT.jar myapp.jar

# Run the jar
ENTRYPOINT ["java", "-jar", "myapp.jar"]

