# ════════════════════════════════════════
# Stage 1 — Build the JAR
# ════════════════════════════════════════
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
 
# Cache dependencies first (faster rebuilds)
COPY pom.xml .
RUN mvn dependency:go-offline -B
 
# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests
 
# ════════════════════════════════════════
# Stage 2 — Runtime image
# ════════════════════════════════════════
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
 
# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
 
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
