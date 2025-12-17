## Timescale

docker pull timescale/timescaledb-ha:pg17.7-ts2.24.0

docker run -d --name HamShackRadio `
    -p 5432:5432 `
    -e POSTGRES_PASSWORD=*cthulhu1988 `
    -v C:\bu:/var/lib/postgresql/data `
    -e POSTGRES_USER=postgres `
    timescale/timescaledb-ha:pg17.7-ts2.24.0



## for cleanup    
docker stop HamShackRadio
docker rm HamShackRadio


## docker compose
# Start the container
docker compose up -d

# View logs
docker compose logs

# Stop the container
docker compose down

# Stop and remove volumes
docker compose down -v

# Access the container's bash shell
docker exec -it HamShackRadio "bash"

# Create the database
psql -U postgres -c "CREATE DATABASE bluebox;"


# Restore the database from the dump file
pg_restore -U postgres -d bluebox c:\bu\bluebox_v0.3.dump

  