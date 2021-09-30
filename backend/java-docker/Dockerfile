FROM maven:3.5.2-jdk-9 AS build
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
#RUN apk --no-cache add ca-certificates

RUN mvn -f /usr/src/app/pom.xml clean package

FROM openjdk:9
COPY --from=build /usr/src/app/target/docker-java-app-example-1.0-SNAPSHOT.jar /usr/app/docker-java-app-example-1.0-SNAPSHOT.jar.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/usr/app/docker-java-app-example-1.0-SNAPSHOT.jar"]