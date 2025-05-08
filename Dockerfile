FROM gradle:8.5-jdk17 AS build
WORKDIR /app

COPY build.gradle settings.gradle gradlew /app/
COPY gradle /app/gradle

RUN chmod +x /app/gradlew

RUN /app/gradlew build --no-daemon || true

COPY . /app

RUN /app/gradlew clean build -x test --no-daemon

FROM openjdk:17-jdk-slim
WORKDIR /app

COPY --from=build /app/build/libs/*.war app.war
COPY .env .env

ENTRYPOINT ["java", "-jar", "app.war"]