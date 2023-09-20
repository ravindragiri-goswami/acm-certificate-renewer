bootstrap-lambda:
	@dotnet restore

bootstrap:
	@dotnet restore
	@terraform init

build:
	@dotnet build
	@docker-compose build

# lint:
# 	@dotnet build

test:
	@dotnet test

clean:
	@dotnet clean && rm -rf dist
	@cd terraform && rm -rf /.terraform

make pre-commit:
	@pre-commit install && pre-commit run -a