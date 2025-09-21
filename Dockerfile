# --- Estágio 1: Build ---
# Usamos uma imagem base que já contém o Maven e o JDK 21 para compilar o projeto.
FROM maven:3.9-eclipse-temurin-21 AS builder

# Define o diretório de trabalho dentro do contêiner.
WORKDIR /app

# Copia primeiro o pom.xml para aproveitar o cache de camadas do Docker.
# As dependências só serão baixadas novamente se o pom.xml mudar.
COPY pom.xml .

# Copia o restante do código fonte do projeto.
COPY src ./src

# Executa o comando do Maven para compilar o projeto e gerar o .jar.
# -DskipTests pula a execução dos testes para um build mais rápido.
RUN mvn clean package -DskipTests


# --- Estágio 2: Run ---
# Usamos uma imagem base enxuta, contendo apenas o Java 21 JRE (Runtime) para rodar a aplicação.
FROM eclipse-temurin:21-jre-jammy

# Define o diretório de trabalho.
WORKDIR /app

# Copia o arquivo .jar que foi gerado no estágio anterior (builder) para o nosso diretório de trabalho.
# O nome do arquivo .jar deve corresponder ao que está definido no seu pom.xml.
COPY --from=builder /app/target/academy-0.0.1-SNAPSHOT.jar app.jar

# Expõe a porta 8080, que é a porta que sua aplicação usa, conforme a variável de ambiente 'PORT' na imagem.
EXPOSE 8080

# Comando para iniciar a aplicação quando o contêiner for executado.
ENTRYPOINT ["java", "-jar", "app.jar"]