FROM gradle:8.5-jdk17 AS build
WORKDIR /app

# Copy just what's needed for initial dependency resolution
COPY build.gradle settings.gradle gradlew /app/
COPY gradle /app/gradle

# Set executable permission
RUN chmod +x /app/gradlew

# Copy the rest of the application
COPY . /app

# Set executable permission AGAIN after copying all files
RUN chmod +x /app/gradlew

# Modify build.gradle to comment out buildScan section (This step might not be necessary now
# since buildScan is in settings.gradle, but it doesn't hurt if the sed command finds nothing)
RUN sed -i '/buildScan {/,/}/s/^/\/\/ /' /app/build.gradle

# Run the build (This will now produce a JAR)
RUN /app/gradlew clean build

FROM openjdk:17-jdk-slim
WORKDIR /app

# Copy the JAR instead of the WAR
COPY --from=build /app/build/libs/*.jar app.jar
COPY .env .env

EXPOSE 8080

# Update the ENTRYPOINT to run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]