# ==========================================
# Stage 1: Build the Application
# ==========================================
FROM maven:3.8.8-eclipse-temurin-17 AS builder
WORKDIR /build

# Copy pom.xml and download project dependencies to cache layer
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy application source code
COPY src ./src

# Build the final deployable package and skip unit testing for speed
RUN mvn clean package -DskipTests

# ==========================================
# Stage 2: Run the Application (Lightweight image)
# ==========================================
FROM eclipse-temurin:17-jre-alpine
WORKDIR /workspace

# Run application as a non-root system user for container runtime protection
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy compiled executable jar file from Stage 1
COPY --from=builder /build/target/NAGP-API-1.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]