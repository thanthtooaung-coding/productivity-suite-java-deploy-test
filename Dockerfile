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

# Modify build.gradle to comment out buildScan section
RUN sed -i '/buildScan {/,/}/s/^/\/\/ /' /app/build.gradle

# Run the build
RUN /app/gradlew clean build

FROM openjdk:17-jdk-slim
WORKDIR /app

COPY --from=build /app/build/libs/*.war app.war
COPY .env .env

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.war"]