run:
	docker run -it \
	-e POSTGRES_USER="postgres" \
	-e POSTGRES_PASSWORD=${POSTGRES_DB_PASSWORD} \
	-e POSTGRES_DB="spielcrypto" \
	-e PGDATA=/var/lib/postgresql/data/pgdata \
	-v ${POSTGRES_DB_PATH}:/var/lib/postgresql/data \
	-p 5432:5432 \
	postgres:16