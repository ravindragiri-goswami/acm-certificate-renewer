# Use the public ECR AWS Lambda .NET 6.0 image as the base
FROM public.ecr.aws/lambda/dotnet:6 AS base
RUN yum update -y

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim as build
WORKDIR /src

# Copy the .csproj file and restore dependencies
COPY ["ACM.Certificate.Renewer.Lambda/ACM.Certificate.Renewer.Lambda.csproj", "ACM.Certificate.Renewer.Lambda/"]
RUN dotnet restore "ACM.Certificate.Renewer.Lambda/ACM.Certificate.Renewer.Lambda.csproj"

COPY . .
WORKDIR "/src/ACM.Certificate.Renewer.Lambda"
#COPY ["ACM.Certificate.Renewer.Lambda/.", "ACM.Certificate.Renewer.Lambda/"]
RUN dotnet build "ACM.Certificate.Renewer.Lambda.csproj" --configuration Release --output /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "ACM.Certificate.Renewer.Lambda.csproj" \
            --configuration Release \
            --runtime linux-x64 \
            --self-contained false \
            --output /app/publish \
            -p:PublishReadyToRun=true

# Final image
FROM base AS final
WORKDIR /var/task
COPY --from=publish /app/publish .

CMD [ "ACM.Certificate.Renewer.Lambda::ACM.Certificate.Renewer.Lambda.Function_FunctionHandler_Generated::FunctionHandler" ]